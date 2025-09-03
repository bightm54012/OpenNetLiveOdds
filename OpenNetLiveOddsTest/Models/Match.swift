//
//  Match.swift
//  OpenNetLiveOddsTest
//
//  Created by Sharon Chao on 2025/9/2.
//

import Foundation

struct Match: Hashable, Codable {
    let matchID: Int
    let teamA: String
    let teamB: String
    let startTime: Date
}
