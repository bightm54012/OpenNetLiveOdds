//
//  MatchesViewModelTests.swift
//  OpenNetLiveOddsTestTests
//
//  Created by Sharon Chao on 2025/9/5.
//

import XCTest
import Combine
@testable import OpenNetLiveOddsTest

final class MatchesViewModelTests: XCTestCase {
    var viewModel: MatchesViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = MatchesViewModel(api: MockAPI())
        cancellables = []
        UserDefaults.standard.removeObject(forKey: "odds.cache")
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testStartFetchesMatchesAndOdds() async throws {
        let expectation = XCTestExpectation(description: "rows updated after start()")
        
        viewModel.$rows
            .dropFirst()
            .sink { rows in
                if !rows.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.start()
        
        wait(for: [expectation], timeout: 2.0)
        
        XCTAssertFalse(viewModel.rows.isEmpty, "rows should not be empty after start()")
        
        let sorted = viewModel.rows.sorted { $0.start < $1.start }
        XCTAssertEqual(viewModel.rows, sorted, "rows should be sorted by start time")
    }

    // MARK: - Test socket connection updates isConnected
    func testSocketConnectionUpdatesIsConnected() {
        let expectation = XCTestExpectation(description: "isConnected updated")
        
        viewModel.socketDidChangeConnection(connected: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.isConnected, "isConnected should be true")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSocketReceiveUpdatesModifiesRows() throws {
        let rowsReady = XCTestExpectation(description: "rows ready")
        let rowsUpdated = XCTestExpectation(description: "rowsReconfigured sends IDs")
        var firstMatchID: Int?
        
        viewModel.$rows
            .dropFirst()
            .sink { rows in
                if let first = rows.first {
                    firstMatchID = first.matchID
                    rowsReady.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.start()
        
        wait(for: [rowsReady], timeout: 2.0)
        guard let matchID = firstMatchID else {
            XCTFail("No rows to update")
            return
        }
        
        var receivedIDs: [Int] = []
        
        viewModel.rowsReconfigured
            .sink { ids in
                receivedIDs = ids
                rowsUpdated.fulfill()
            }
            .store(in: &cancellables)
        
        let update = OddsUpdate(matchID: matchID, teamAOdds: 9.99, teamBOdds: 8.88)
        viewModel.socketDidReceive(updates: [update])
        
        wait(for: [rowsUpdated], timeout: 1.0)
        
        let updatedRow = viewModel.row(for: matchID)!
        XCTAssertEqual(updatedRow.teamAOdds, 9.99)
        XCTAssertEqual(updatedRow.teamBOdds, 8.88)
        XCTAssertEqual(receivedIDs, [matchID])
    }
    
    func testCachePersistAndRestore() async throws {
        await viewModel.start()
        
        guard let first = viewModel.rows.first else { return }
        let matchID = first.matchID
        let newOdds = OddsUpdate(matchID: matchID, teamAOdds: 5.55, teamBOdds: 6.66)
        
        viewModel.socketDidReceive(updates: [newOdds])
        
        let newViewModel = MatchesViewModel(api: MockAPI())
        await newViewModel.restoreCache()
        
        let restoredOdds = await newViewModel.odds(for: matchID)
        XCTAssertEqual(restoredOdds?.teamAOdds, 5.55)
        XCTAssertEqual(restoredOdds?.teamBOdds, 6.66)
    }
}
