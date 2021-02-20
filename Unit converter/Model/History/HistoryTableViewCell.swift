//
//  HistoryTableViewCell.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-21.
//
import Foundation
import UIKit

class HistoryTableViewCell: UITableViewCell {
     
    @IBOutlet weak var historyConversionIcon: UIImageView!
    @IBOutlet weak var historyConversionText: UILabel!
    
    /// Creating a subview
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
}
