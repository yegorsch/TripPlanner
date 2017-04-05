//
//  TripViewCell.swift
//  Planner
//
//  Created by Егор on 3/23/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import UIKit

class TripViewCell: UITableViewCell {

    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var initialPlaceName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
