//
//  OddsCell.swift
//  OpenNetLiveOddsTest
//
//  Created by Sharon Chao on 2025/9/2.
//

import UIKit

class OddsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var aLabel: UILabel!
    @IBOutlet weak var bLabel: UILabel!
    
    func configure(row: MatchesViewModel.Row) {
        titleLabel.text = row.title
        timeLabel.text = DateFormatter.localizedString(from: row.start, dateStyle: .none, timeStyle: .short)
        aLabel.text = "A: \(String(format: "%.2f", row.teamAOdds))"
        bLabel.text = "B: \(String(format: "%.2f", row.teamBOdds))"
        
        contentView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2) {
            self.aLabel.alpha = 0.3
            self.bLabel.alpha = 0.3
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.aLabel.alpha = 1.0
                self.bLabel.alpha = 1.0
            }
        }
    }
    
}
