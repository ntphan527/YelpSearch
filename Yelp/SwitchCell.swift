//
//  OfferingDealCell.swift
//  Yelp
//
//  Created by Phan, Ngan on 9/22/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell {
    @IBOutlet weak var optionSwitch: UISwitch!
    @IBOutlet weak var optionLabel: UILabel!
    
    var handleOption: ((UISwitch) -> Void)?

    @IBAction func updateOption(_ sender: Any) {
        handleOption?(optionSwitch)
    }
}
