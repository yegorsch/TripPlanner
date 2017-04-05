//
//  ViewController.swift
//  Planner
//
//  Created by Егор on 3/23/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import UIKit
import GooglePlaces
import DZNEmptyDataSet
import CoreData
import ChameleonFramework

class ViewController: UIViewController,GMSAutocompleteViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    var isPastTable = false
    var resultsToReturn = [Destination]()
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfDestinationsExpired()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
    }

    // Configuring table view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let dest = resultsToReturn[indexPath.row]
            Toolkit.getContext().delete(dest)
            Toolkit.saveContext()
            self.tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        getDestionations(isPast: isPastTable)
        return resultsToReturn.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath) as! TripViewCell
        cell.destinationLabel.text = resultsToReturn[indexPath.row].name
        cell.initialPlaceName.text = resultsToReturn[indexPath.row].startPlaceName
        let date1 = resultsToReturn[indexPath.row].startDate
        let date2 = resultsToReturn[indexPath.row].endDate
        cell.durationLabel.text = Toolkit.formatDate(date: date1!) + " - " + Toolkit.formatDate(date: date2!)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showTripOverview", sender: resultsToReturn[indexPath.row])
    }
    

    
    // Switching tables
    @IBAction func switchTables(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            getDestionations(isPast: false)
            isPastTable = false
        case 1:
            getDestionations(isPast: true)
            isPastTable = true
        default:
            getDestionations(isPast: true)
        }
        self.tableView.reloadData()
    }
    
    
    //Adding destinations
    @IBAction func explore(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }



    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: {self.performSegue(withIdentifier: "showDestinationConfig", sender: place)})
    }
    

    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    // Core data functions
    func getDestionations(isPast:Bool){
        resultsToReturn.removeAll()
        let request:NSFetchRequest<Destination> = Destination.fetchRequest()
        do{
            let searchResults = try Toolkit.getContext().fetch(request)
            for result in searchResults as [Destination]{
                if result.isPast == isPast{
                    resultsToReturn.append(result)
                }
            }
        }catch{
            print(error)
        }
    }
    func checkIfDestinationsExpired(){
        let request:NSFetchRequest<Destination> = Destination.fetchRequest()
        do{
            let searchResults = try Toolkit.getContext().fetch(request)
            for result in searchResults as [Destination]{
                if result.isPast == false{
                    if (result.endDate?.timeIntervalSinceReferenceDate)! < NSDate().timeIntervalSinceReferenceDate{
                        result.isPast = true
                    }
                }
            }
        }catch{
            print(error)
        }
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "emptyImage")
    }
    
    // segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let guest  = segue.destination as? ConfigureDestinationViewController{
            guest.startPlace = sender as! GMSPlace
        } else if let guest  = segue.destination as? placeOverviewViewController{
            guest.destination = sender as! Destination
        }
    }
    
}

