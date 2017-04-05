//
//  tripNodeView.swift
//  Planner
//
//  Created by Егор on 3/28/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import UIKit
import ChameleonFramework
class tripNodeView: UICollectionViewCell {
    

    @IBOutlet var view: UIView!
       @IBOutlet weak var arrivalPlaceLabel: UILabel!
       @IBOutlet weak var arrivalTime: UILabel!
       @IBOutlet weak var departurePlaceLabel: UILabel!
       @IBOutlet weak var departureTime: UILabel!
       @IBOutlet weak var infoLabel: UITextView!
    @IBOutlet weak var settingButton: UIButton!
  
    @IBOutlet weak var deleteNodeButton: UIButton!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("tripNodeView", owner: self, options: nil)
        self.addSubview(view)
        let color = UIColor(complementaryFlatColorOf: UIColor.flatRed, withAlpha: 1)
        self.backgroundColor = UIColor(hexString: "A9E3EA")
        self.infoLabel.backgroundColor = UIColor(hexString: "A9E3EA")
        self.layer.borderWidth = 1
        self.layer.cornerRadius  = 5
        view.frame = self.bounds
    }

}
