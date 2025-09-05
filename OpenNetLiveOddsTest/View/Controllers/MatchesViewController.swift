//
//  MatchesViewController.swift
//  OpenNetLiveOddsTest
//
//  Created by Sharon Chao on 2025/9/2.
//

import UIKit
import Combine

class MatchesViewController: UITableViewController {
    
    private let vm = MatchesViewModel()
    enum Section { case main }
    typealias Item = Int
    private var dataSource: UITableViewDiffableDataSource<Section, Item>!
    
    private var reloadCount = 0
    private let statusDot = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Live Odds"
        
        statusDot.layer.cornerRadius = 5
        statusDot.backgroundColor = .systemRed
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: statusDot)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Logs",
            style: .plain,
            target: self,
            action: #selector(showLogs)
        )
        
        FPSMonitor.shared.start()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStatusPrompt()
        }
        
        dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) { [weak self] tableView, indexPath, itemID in
            let cell = tableView.dequeueReusableCell(withIdentifier: "OddsCell", for: indexPath) as! OddsCell
            if let row = self?.vm.row(for: itemID) { cell.configure(row: row) }
            return cell
        }
        
        bindViewModel()
        vm.start()
    }
    
    private func bindViewModel() {
        vm.$rows
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rows in
                guard let self = self else { return }
                var snap = NSDiffableDataSourceSnapshot<Section, Item>()
                snap.appendSections([.main])
                snap.appendItems(rows.map { $0.matchID }, toSection: .main)
                self.dataSource.apply(snap, animatingDifferences: false)
            }
            .store(in: &cancellables)
        
        vm.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { ok in
                self.statusDot.backgroundColor = ok ? .systemGreen : .systemRed
            }
            .store(in: &cancellables)
        
        vm.rowsReconfigured
            .receive(on: DispatchQueue.main)
            .sink { [weak self] changedIDs in
                guard let self = self, !changedIDs.isEmpty else { return }
                var snap = self.dataSource.snapshot()
                snap.reconfigureItems(changedIDs)
                self.dataSource.apply(snap, animatingDifferences: false) { [weak self] in
                    guard let self = self else { return }
                    for case let cell as OddsCell in self.tableView.visibleCells {
                        if let indexPath = self.tableView.indexPath(for: cell),
                           let itemID = self.dataSource.itemIdentifier(for: indexPath),
                           changedIDs.contains(itemID),
                           let row = self.vm.row(for: itemID) {
                            cell.configure(row: row)
                            self.reloadCount += 1
                            Logger.shared.log("Updated cell for \(itemID)")
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func showLogs() {
        let vc = LoggerViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateStatusPrompt() {
        let fps = FPSMonitor.shared.fps
        navigationItem.prompt = "FPS: \(fps)   Reloads: \(reloadCount)"
    }
}
