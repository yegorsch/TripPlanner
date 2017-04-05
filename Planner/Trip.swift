//
//  Trip.swift
//  Planner
//
//  Created by Егор on 3/26/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import Foundation
import GooglePlaces

class Trip {
    
    var tripName:String
    var tripId:String
    var initialPlace:GMSPlace
    var startDate:Date
    var endDate:Date
    init(tName: String, initPlace: GMSPlace, startD:Date, endD:Date, id:String) {
        tripName = tName
        initialPlace = initPlace
        startDate = startD
        endDate = endD
        tripId = id
    }
}
