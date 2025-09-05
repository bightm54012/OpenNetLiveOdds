//
//  LoggerViewController.swift
//  OpenNetLiveOddsTest
//
//  Created by Sharon Chao on 2025/9/5.
//

import UIKit

final class LoggerViewController: UITableViewController {
    private var logs: [String] { Logger.shared.logs }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Logs"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        logs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = logs[indexPath.row]
        return cell
    }
}
