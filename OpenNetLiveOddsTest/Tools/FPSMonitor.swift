//
//  FPSMonitor.swift
//  OpenNetLiveOddsTest
//
//  Created by Sharon Chao on 2025/9/5.
//

import UIKit

final class FPSMonitor {
    static let shared = FPSMonitor()
    private var link: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount: Int = 0
    private(set) var fps: Int = 0

    func start() {
        stop()
        lastTimestamp = 0
        frameCount = 0
        link = CADisplayLink(target: self, selector: #selector(tick))
        link?.add(to: .main, forMode: .common)
    }

    func stop() {
        link?.invalidate()
        link = nil
    }

    @objc private func tick(_ link: CADisplayLink) {
        if lastTimestamp == 0 { lastTimestamp = link.timestamp; return }
        frameCount += 1
        let delta = link.timestamp - lastTimestamp
        if delta >= 1.0 {
            fps = Int(Double(frameCount) / delta)
            Logger.shared.log("FPS: \(fps))")
            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }
}
