//
//  Odds.swift
//  OpenNetLiveOddsTest
//
//  Created by Sharon Chao on 2025/9/2.
//

import Foundation

struct Odds: Codable, Equatable {
    let matchID: Int
    var teamAOdds: Double
    var teamBOdds: Double
}

struct OddsUpdate: Codable {
    let matchID: Int
    let teamAOdds: Double
    let teamBOdds: Double
}
