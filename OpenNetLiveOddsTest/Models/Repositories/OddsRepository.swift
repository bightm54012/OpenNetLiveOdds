//
//  OddsRepository.swift
//  OpenNetLiveOddsTest
//
//  Created by Sharon Chao on 2025/9/3.
//

import Foundation

actor OddsRepository {
    private var oddsMap: [Int: Odds] = [:]
    
    func seed(initial: [Odds]) {
        for o in initial { oddsMap[o.matchID] = o }
    }
    
    func apply(updates: [OddsUpdate]) -> [Int] {
        var changedIDs: [Int] = []
        for u in updates {
            let new = Odds(matchID: u.matchID, teamAOdds: u.teamAOdds, teamBOdds: u.teamBOdds)
            if oddsMap[u.matchID] != new {
                oddsMap[u.matchID] = new
                changedIDs.append(u.matchID)
            }
        }
        return changedIDs
    }
    
    func odds(for matchID: Int) -> Odds? { oddsMap[matchID] }
    
    func persistCache() {
        let arr = Array(oddsMap.values)
        if let data = try? JSONEncoder().encode(arr) {
            UserDefaults.standard.set(data, forKey: "odds.cache")
        }
    }
    
    func restoreCache() {
        if let data = UserDefaults.standard.data(forKey: "odds.cache"),
           let arr = try? JSONDecoder().decode([Odds].self, from: data) {
            seed(initial: arr)
        }
    }
}
