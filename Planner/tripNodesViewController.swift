//
//  tripNodesViewController.swift
//  Planner
//
//  Created by Егор on 3/27/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import UIKit

class tripNodesViewController: UIViewController {
    
    @IBOutlet weak var graphView: tripNodePlacerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graphView.addTripNode(node: tripNodeView(frame: CGRect.zero, arrivalPlace: "googlelogo", arrivalTime: Date(), departurePlace: "lol", departureTime: Date()))
    }
  
}
