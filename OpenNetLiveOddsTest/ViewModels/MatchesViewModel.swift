//
//  MatchesViewModel.swift
//  OpenNetLiveOddsTest
//
//  Created by Sharon Chao on 2025/9/3.
//

import Foundation
import Combine

final class MatchesViewModel: OddsSocketDelegate, ObservableObject {
    struct Row: Hashable {
        let matchID: Int
        let title: String
        let start: Date
        var teamAOdds: Double
        var teamBOdds: Double
    }
    
    @Published private(set) var rows: [Row] = []
    @Published private(set) var isConnected: Bool = false
    let rowsReconfigured = PassthroughSubject<[Int], Never>()
    
    private let api: MatchesAPI
    private let repo = OddsRepository()
    private var matches: [Match] = []
    private var socket: OddsSocketMock?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(api: MatchesAPI = MockAPI()) { self.api = api }
    
    func start() {
        Task {
            async let ms = api.fetchMatches()
            async let os = api.fetchInitialOdds()
            var matches = try await ms
            let initialOdds = try await os
            
            matches.sort { $0.startTime < $1.startTime }
            self.matches = matches
            
            await repo.seed(initial: initialOdds)
            await repo.restoreCache()
            
            var rowsDict: [Int: Row] = [:]
            for m in matches {
                let o = await repo.odds(for: m.matchID)
                let row = Row(
                    matchID: m.matchID,
                    title: "\(m.teamA) vs \(m.teamB)",
                    start: m.startTime,
                    teamAOdds: o?.teamAOdds ?? 0,
                    teamBOdds: o?.teamBOdds ?? 0
                )
                rowsDict[m.matchID] = row
            }
            
            await MainActor.run {
                self.rows = Array(rowsDict.values).sorted { $0.start < $1.start }
            }
            
            let s = OddsSocketMock(matchIDs: matches.map { $0.matchID })
            s.delegate = self
            self.socket = s
            s.connect()
            s.simulateDropAndReconnect()
        }
    }
    
    func socketDidChangeConnection(connected: Bool) {
        DispatchQueue.main.async {
            self.isConnected = connected
        }
    }
    
    func socketDidReceive(updates: [OddsUpdate]) {
        Task {
            let changedIDs = await repo.apply(updates: updates)
            guard !changedIDs.isEmpty else { return }
            
            var idToIndex: [Int: Int] = [:]
            for (idx, r) in rows.enumerated() { idToIndex[r.matchID] = idx }
            
            var reconfiguredIDs: Set<Int> = []
            for id in changedIDs {
                if let i = idToIndex[id], let latest = await repo.odds(for: id) {
                    rows[i].teamAOdds = latest.teamAOdds
                    rows[i].teamBOdds = latest.teamBOdds
                    reconfiguredIDs.insert(id)
                }
            }
            
            await repo.persistCache()
            
            await MainActor.run {
                self.rowsReconfigured.send(Array(reconfiguredIDs))
                self.rows = self.rows
            }
        }
    }
    
    func row(for matchID: Int) -> Row? { rows.first { $0.matchID == matchID } }
}
