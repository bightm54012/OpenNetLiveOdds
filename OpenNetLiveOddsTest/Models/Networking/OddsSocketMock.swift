//
//  OddsSocketMock.swift
//  OpenNetLiveOddsTest
//
//  Created by Sharon Chao on 2025/9/2.
//

import Foundation

protocol OddsSocketDelegate: AnyObject {
    func socketDidReceive(updates: [OddsUpdate])
    func socketDidChangeConnection(connected: Bool)
}

final class OddsSocketMock {
    weak var delegate: OddsSocketDelegate?
    
    private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "socket.mock.queue")
    private var connected = false
    private let matchIDs: [Int]
    
    init(matchIDs: [Int]) {
        self.matchIDs = matchIDs
    }
    
    func connect() {
        guard !connected else { return }
        connected = true
        delegate?.socketDidChangeConnection(connected: true)
        
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + 1, repeating: 1.0)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            let count = Int.random(in: 0...10)
            var batch: [OddsUpdate] = []
            for _ in 0..<count {
                if let id = self.matchIDs.randomElement() {
                    let a = Double.random(in: 1.40...2.60)
                    let b = Double.random(in: 1.40...2.60)
                    batch.append(OddsUpdate(matchID: id, teamAOdds: a, teamBOdds: b))
                }
            }
            if !batch.isEmpty { self.delegate?.socketDidReceive(updates: batch) }
        }
        timer.resume()
        self.timer = timer
    }
    
    func disconnect() {
        guard connected else { return }
        connected = false
        timer?.cancel()
        timer = nil
        delegate?.socketDidChangeConnection(connected: false)
    }
    
    func simulateDropAndReconnect(after seconds: TimeInterval = 8) {
        queue.asyncAfter(deadline: .now() + seconds) { [weak self] in
            guard let self = self else { return }
            self.disconnect()
            self.queue.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.connect()
            }
        }
    }
}
