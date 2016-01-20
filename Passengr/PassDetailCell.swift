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
    
    override func drawRect(rect: CGRect) {
        UIColor.lightGrayColor().setStroke()
        UIBezierPath(rect: rect).stroke()
    }
    
    func setup() {
        self.titleLabel.numberOfLines = 0
        self.titleLabel.preferredMaxLayoutWidth = 280.0
        self.eastboundLabel.preferredMaxLayoutWidth = 280.0
        self.conditionsLabel.preferredMaxLayoutWidth = 280.0
        self.westboundLabel.preferredMaxLayoutWidth = 280.0
        
        self.conditionsTitleLabel.font = UIFont(name: "Copperplate", size: 14.0)
        self.eastboundTitleLabel.font = UIFont(name: "Copperplate", size: 14.0)
        self.westboundTitleLabel.font = UIFont(name: "Copperplate", size: 14.0)
        
        self.westboundTitleLabel.textColor = UIColor.darkGrayColor()
        self.eastboundTitleLabel.textColor = UIColor.darkGrayColor()
        self.conditionsTitleLabel.textColor = UIColor.darkGrayColor()
        
        self.lastUpdatedLabel.textColor = UIColor.lightGrayColor()
        
        self.containerView.backgroundColor = UIColor.clearColor()
        self.backgroundColor = UIColor.whiteColor()
    }
}
