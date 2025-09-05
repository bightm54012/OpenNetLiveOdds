//
//  Logger.swift
//  OpenNetLiveOddsTest
//
//  Created by Sharon Chao on 2025/9/5.
//

import Foundation

final class Logger {
    static let shared = Logger()
    private init() {}

    private(set) var logs: [String] = []

    func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let entry = "[\(timestamp)] \(message)"

        logs.insert(entry, at: 0)
        print(entry)
    }
}
