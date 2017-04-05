//
//  PlacesToVisitViewController.swift
//  Planner
//
//  Created by Егор on 4/2/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker
import MGSwipeTableCell

class PlacesToVisitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var destination:Destination!
    var places:[Place]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Places to visit"
        loadPlaces()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pickPlace(_:)))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceViewCell
        cell.placeName?.text = places[indexPath.row].placeName
        cell.doneButton.tag = indexPath.row
        cell.doneButton.addTarget(self, action: #selector(doneButtonPressed(sender:)), for: .touchUpInside)
        if places[indexPath.row].isCompleted {
            cell.backgroundColor = UIColor(hexString: "4CD964")
            cell.doneButton.setTitle("Completed", for: .normal)
        }else{
              cell.backgroundColor = UIColor.flatRed
             cell.doneButton.setTitle("Seen", for: .normal)
        }
        cell.doneButton.layer.cornerRadius = 5
        return cell

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    // sorry for the govnokod
    func pickPlace(_ sender: UIButton) {
        
        let placesClient = GMSPlacesClient()
        placesClient.lookUpPlaceID(destination.startPlaceId!, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            let viewport = GMSCoordinateBounds(coordinate: (place?.coordinate)!, coordinate: (place?.coordinate)!)
            let config = GMSPlacePickerConfig(viewport: viewport)
            let placePicker = GMSPlacePicker(config: config)
            placePicker.pickPlace(callback: { (place, error) -> Void in
                if let error = error {
                    print("Pick Place error: \(error.localizedDescription)")
                    return
                }
                
                guard let place = place else {
                    print("No place selected")
                    return
                }
            let context = Toolkit.getContext()
            let placeToAdd = Place(context: context)
                placeToAdd.isCompleted = false
                placeToAdd.destination = self.destination
                placeToAdd.placeID = place.placeID
                placeToAdd.placeName = place.name
                Toolkit.saveContext()
                self.loadPlaces()
                self.tableView.reloadData()
               
            })
        })
        
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        loadPlaces()
        self.tableView.reloadData()
    }
    func loadPlaces(){
        if let placesRetrieved = destination.hasPlaces?.allObjects as? [Place]{
            self.places = placesRetrieved.sorted { !$0.isCompleted && $1.isCompleted }
        }
    }
    
    func doneButtonPressed(sender :UIButton){
        let context = Toolkit.getContext()
        places[sender.tag].isCompleted = true
       var cell =  self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? PlaceViewCell
        cell?.doneButton.setTitle("Completed", for: .normal)
        Toolkit.saveContext()
        loadPlaces()
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let dest = places[indexPath.row]
            Toolkit.getContext().delete(dest)
            Toolkit.saveContext()
            loadPlaces()
            self.tableView.reloadData()
        }else if editingStyle == .insert{
            
        }
    }
    
}
