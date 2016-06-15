//
//  PassEditCell.swift
//  Passengr
//
//  Created by Andrew Shepard on 12/1/15.
//  Copyright © 2015 Andrew Shepard. All rights reserved.
//

import UIKit

class PassEditCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var swtch: UISwitch!
    
    static let reuseIdentifier = "\(PassEditCell.self)"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
