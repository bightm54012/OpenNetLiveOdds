//
//  MockAPI.swift
//  OpenNetLiveOddsTest
//
//  Created by Sharon Chao on 2025/9/2.
//

import Foundation

protocol MatchesAPI {
    func fetchMatches() async throws -> [Match]
    func fetchInitialOdds() async throws -> [Odds]
}

final class MockAPI: MatchesAPI {
    func fetchMatches() async throws -> [Match] {
        var arr: [Match] = []
        let now = Date()
        for i in 0..<100 {
            let start = now.addingTimeInterval(Double(i) * 180)
            arr.append(Match(matchID: 1000 + i, teamA: "Eagles_\(i)", teamB: "Tigers_\(i)", startTime: start))
        }
        return arr
    }

    func fetchInitialOdds() async throws -> [Odds] {
        var arr: [Odds] = []
        for i in 0..<100 {
        arr.append(Odds(matchID: 1000 + i, teamAOdds: Double.random(in: 1.50...2.50), teamBOdds: Double.random(in: 1.50...2.50)))
        }
        return arr
    }
}
