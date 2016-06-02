//
//  PassDetailCell.swift
//  Passengr
//
//  Created by Andrew Shepard on 10/18/14.
//  Copyright (c) 2014 Andrew Shepard. All rights reserved.
//

import UIKit

class PassDetailCell: UICollectionViewCell {
    @IBOutlet var statusView: UIView!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var conditionsTitleLabel: UILabel!
    @IBOutlet var eastboundTitleLabel: UILabel!
    @IBOutlet var westboundTitleLabel: UILabel!
    
    @IBOutlet var eastboundLabel: UILabel!
    @IBOutlet var westboundLabel: UILabel!
    @IBOutlet var conditionsLabel: UILabel!
    
    @IBOutlet var lastUpdatedLabel: UILabel!
    
    @IBOutlet var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = ""
        
        self.eastboundLabel.text = ""
        self.westboundLabel.text = ""
        self.conditionsLabel.text = ""
        
        self.lastUpdatedLabel.text = ""
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.lightGray().setStroke()
        UIBezierPath(rect: rect).stroke()
    }
    
    func setup() {
        self.titleLabel.numberOfLines = 0
        self.titleLabel.preferredMaxLayoutWidth = 280.0
        self.eastboundLabel.preferredMaxLayoutWidth = 280.0
        self.conditionsLabel.preferredMaxLayoutWidth = 280.0
        self.westboundLabel.preferredMaxLayoutWidth = 280.0
        
        self.conditionsTitleLabel.font = AppStyle.Font.Copperplate
        self.eastboundTitleLabel.font = AppStyle.Font.Copperplate
        self.westboundTitleLabel.font = AppStyle.Font.Copperplate
        
        self.westboundTitleLabel.textColor = UIColor.darkGray()
        self.eastboundTitleLabel.textColor = UIColor.darkGray()
        self.conditionsTitleLabel.textColor = UIColor.darkGray()
        
        self.lastUpdatedLabel.textColor = UIColor.lightGray()
        
        self.containerView.backgroundColor = UIColor.clear()
        self.backgroundColor = UIColor.white()
    }
}
