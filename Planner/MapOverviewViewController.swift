//
//  MapOverviewViewController.swift
//  Planner
//
//  Created by Егор on 4/2/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapOverviewViewController: UIViewController {
    
    var destination:Destination!
    var markersArr = [GMSMarker]()
    var markersDep = [GMSMarker]()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaces()
        loadHousing()
        addPath()
    }
    
    func addPath(){
        for marker in markersDep{
        var path = GMSMutablePath()
        path.add(marker.position)
        path.add(markersDep[markersArr.index(of: marker)!].position)
        let rect = GMSPolyline(path: path)
            rect.strokeWidth = 2
            rect.map = self.mapView
        }
    }
    func loadHousing(){
        if let hopsRetrieved = destination.hasHousing?.allObjects as? [House]{
            for hop in hopsRetrieved{
                let placesClient = GMSPlacesClient()
                placesClient.lookUpPlaceID(hop.placeID!, callback: { (place, error) -> Void in
                    if let error = error {
                        print("lookup place id query error: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let place = place else {
                        print("No place selected")
                        return
                    }
                    var marker = GMSMarker(position: place.coordinate )
                    marker.snippet = "Housing " + place.name + Toolkit.formatDateAndTime(date: hop.checkInDate!) + " - "  + Toolkit.formatDateAndTime(date: hop.checkOutDate!)
                    marker.map = self.mapView
                    self.markersArr.append(marker)
                })}
        }
    }

    @IBOutlet weak var mapView: GMSMapView!
    func loadPlaces() -> Bool{
        if let hopsRetrieved = destination.hasHops?.allObjects as? [Hop]{
            for hop in hopsRetrieved{
                let placesClient = GMSPlacesClient()
                placesClient.lookUpPlaceID(hop.arrivalPlaceID!, callback: { (place, error) -> Void in
                    if let error = error {
                        print("lookup place id query error: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let place = place else {
                        print("No place selected")
                        return
                    }
                   var marker = GMSMarker(position: place.coordinate )
                    marker.snippet = "Departure " + place.name + Toolkit.formatDateAndTime(date: hop.arrivalTime!)
                    marker.map = self.mapView
                    self.markersArr.append(marker)
                })
            }
            if let hopsRetrieved = destination.hasHops?.allObjects as? [Hop]{
                for hop in hopsRetrieved{
                    let placesClient = GMSPlacesClient()
                    placesClient.lookUpPlaceID(hop.departurePlaceID!, callback: { (place, error) -> Void in
                        if let error = error {
                            print("lookup place id query error: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let place = place else {
                            print("No place selected")
                            return
                        }
                        var marker = GMSMarker(position: place.coordinate )
                        marker.snippet = "Arrival " + place.name + Toolkit.formatDateAndTime(date: hop.arrivalTime!)
                        marker.map = self.mapView
                        self.markersDep.append(marker)
                    })
                }
                

        }
           
    }
        return true
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
