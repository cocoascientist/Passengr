//
//  PassDetailCell.swift
//  Passengr
//
//  Created by Andrew Shepard on 10/18/14.
//  Copyright (c) 2014 Andrew Shepard. All rights reserved.
//

import UIKit

final class PassDetailCell: UICollectionViewCell {
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var conditionsTitleLabel: UILabel!
    @IBOutlet weak var eastboundTitleLabel: UILabel!
    @IBOutlet weak var westboundTitleLabel: UILabel!
    
    @IBOutlet weak var eastboundLabel: UILabel!
    @IBOutlet weak var westboundLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!
    
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    static let reuseIdentifier = "\(PassDetailCell.self)"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.text = ""
        self.lastUpdatedLabel.text = ""
        
        self.eastboundLabel.text = ""
        self.westboundLabel.text = ""
        self.conditionsLabel.text = ""
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.lightGray.setStroke()
        UIBezierPath(rect: rect).stroke()
    }
    
    func setup() {
        self.titleLabel.numberOfLines = 0
        self.titleLabel.preferredMaxLayoutWidth = 280.0
        self.eastboundLabel.preferredMaxLayoutWidth = 280.0
        self.conditionsLabel.preferredMaxLayoutWidth = 280.0
        self.westboundLabel.preferredMaxLayoutWidth = 280.0
        
        self.conditionsTitleLabel.font = AppStyle.Font.copperplate
        self.eastboundTitleLabel.font = AppStyle.Font.copperplate
        self.westboundTitleLabel.font = AppStyle.Font.copperplate
        
        self.westboundTitleLabel.textColor = UIColor.darkGray
        self.eastboundTitleLabel.textColor = UIColor.darkGray
        self.conditionsTitleLabel.textColor = UIColor.darkGray
        
        self.lastUpdatedLabel.textColor = UIColor.lightGray
        
        self.containerView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.white
    }
}
