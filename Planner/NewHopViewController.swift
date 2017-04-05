//
//  NewHopViewController.swift
//  Planner
//
//  Created by Егор on 3/30/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import UIKit
import DateTimePicker
import GooglePlaces
import GoogleMaps
import CoreData

class NewHopViewController: UIViewController, GMSAutocompleteViewControllerDelegate, UIScrollViewDelegate {
    
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var tableViewController:TransferTableVIewController!
    var depPlace:GMSPlace! { didSet {
        tableViewController.departurePlaceField.text = depPlace.name
        depMarker.map = nil
        depMarker = GMSMarker(position: depPlace.coordinate)
        depMarker.map = mapView
        }
    }
    var arrPlace:GMSPlace! { didSet {
        tableViewController.arrivalPlaceField.text = arrPlace.name
        arrMarker.map = nil
        arrMarker.position = arrPlace.coordinate
        arrMarker = GMSMarker(position: arrPlace.coordinate)
        arrMarker.map = mapView
        }
    }
    var depTime:Date! { didSet { tableViewController.departureTimeField.text = Toolkit.formatDateAndTime(date: depTime)}}
    var arrTime:Date! { didSet { tableViewController.arrivalTimeField.text = Toolkit.formatDateAndTime(date: arrTime)}}
    var info:String!
    enum TimePart {
        case departure
        case arrival
    }
    var path = GMSMutablePath()
    var rectangle = GMSPolyline()
    
    var destination:Destination!
    var hop:Hop!
    var timeEditingNow:TimePart!
    var depMarker = GMSMarker()
    var arrMarker = GMSMarker()
    var depPlaceMap:GMSMapView!
    var arrPlaceMap:GMSMapView!
    var picker = DateTimePicker()
    var Frame:CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.flatBlack
        Frame = self.view.frame
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: UIScreen.main.bounds.height * 1.5)
        loadDataFromHop()
        depMarker.snippet = "Departure"
        arrMarker.snippet = "Arrival"
        tableViewController.departurePlaceField.allowsEditingTextAttributes = false
        tableViewController.departureTimeField.allowsEditingTextAttributes = false
        tableViewController.arrivalTimeField.allowsEditingTextAttributes = false
        tableViewController.arrivalPlaceField.allowsEditingTextAttributes = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveHop))
        tableViewController.departurePlaceField.addTarget(self, action: #selector(showDepPlacePicker), for: UIControlEvents.editingDidBegin)
        tableViewController.arrivalPlaceField.addTarget(self, action: #selector(showArrPlacePicker), for: UIControlEvents.editingDidBegin)
        tableViewController.arrivalTimeField.addTarget(self, action: #selector(showArrTimePicker), for: UIControlEvents.editingDidBegin)
        tableViewController.departureTimeField.addTarget(self, action: #selector(showDepTimePicker), for: UIControlEvents.editingDidBegin)
        self.view.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(dismissViews)))
                self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height * 1.5)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.flatBlack

    }
    
        func keyboardWillShow(notification: NSNotification) {
    
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                  self.view.frame.origin.y -= self.mapView.bounds.height
            }
            
        }
        func keyboardWillHide(notification: NSNotification) {
            print("here")
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y != 0{
                    self.view.frame = Frame
                    print("here")
                }
            }
        }
    func dismissViews(){
        picker.removeFromSuperview()
        self.view.endEditing(true)
        tableViewController.additionalInfoTextField.resignFirstResponder()
    }
    @IBOutlet weak var scrollVIew: UIScrollView!
 
    func loadDataFromHop(){
        if hop != nil {
            let placesClient = GMSPlacesClient()
            placesClient.lookUpPlaceID(hop.departurePlaceID!, callback: { (place, error) -> Void in
                if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    return
                }
                self.depPlace = place
            })
            placesClient.lookUpPlaceID(hop.arrivalPlaceID!, callback: { (place, error) -> Void in
                if let error = error {
                    print("lookup place id query error: \(error.localizedDescription)")
                    return
                }
                self.arrPlace = place
            })
            tableViewController.departurePlaceField.text = Toolkit.formatDateAndTime(date: hop.departureTime!)
            tableViewController.arrivalTimeField.text = Toolkit.formatDateAndTime(date: hop.arrivalTime!)
            self.depTime = Toolkit.dateFromNSDate(date: hop.departureTime!)
            self.arrTime = Toolkit.dateFromNSDate(date: hop.arrivalTime!)
            self.tableViewController.additionalInfoTextField.text = hop.info
        }
    }
    
    func addToScrollView(place:GMSPlace, part:TimePart){
        switch part {
        case .arrival:
            arrMarker.position = place.coordinate
            let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 4)
            mapView.camera = camera
        case .departure:
            depMarker.position = place.coordinate
            let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 4)
            mapView.camera = camera
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.tableViewController = segue.destination
            as! TransferTableVIewController
    }
    
    // Configuring place autocomplete
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        switch timeEditingNow! {
        case .arrival:
            arrPlace = place
            addToScrollView(place: place,part: .arrival)
        case .departure:
            depPlace = place
            addToScrollView(place: place,part: .departure)
        }
        if (self.arrPlace != nil && self.depPlace != nil){
            path.removeAllCoordinates()
            rectangle.path = nil
            path.add(arrPlace.coordinate)
            path.add(depPlace.coordinate)
            rectangle = GMSPolyline(path: path)
            rectangle.strokeWidth = 2.0
            rectangle.map = mapView
        }
        dismiss(animated: true, completion: nil)
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
    // Confinging text field actions
    func showDepPlacePicker(){
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        timeEditingNow = .departure
    }
    func showArrPlacePicker(){
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        timeEditingNow = .arrival
    }
    func showDepTimePicker(){
        picker = DateTimePicker.show()
        picker.selectedDate = Toolkit.dateFromNSDate(date: destination.startDate!)
        self.view.endEditing(true)
        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.completionHandler = { date in
            self.depTime = date
        }
    }
    func showArrTimePicker(){
        picker.selectedDate = Date()
        picker = DateTimePicker.show()
        picker.selectedDate = Toolkit.dateFromNSDate(date: destination.startDate!)
        self.view.endEditing(true)
        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.completionHandler = { date in
            self.arrTime = date
        }
    }
    func saveHop(){
        if self.arrTime == nil || self.arrPlace == nil || self.depTime == nil || self.arrTime == nil{
            let alert = UIAlertController(title: "Hey", message: "Fill all the neccesary fields", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let context = Toolkit.getContext()
        if hop != nil{
        context.delete(hop)
        }
        hop = Hop(context: context)
        hop.arrivalPlace = arrPlace.name
        hop.arrivalTime = NSDate(timeInterval: 0, since: arrTime)
        hop.departurePlace = depPlace.name
        hop.departureTime = NSDate(timeInterval: 0, since: depTime)
        hop.info = tableViewController.additionalInfoTextField.text
        hop.destination = destination
        hop.arrivalPlaceID = arrPlace.placeID
        hop.departurePlaceID = depPlace.placeID
        Toolkit.saveContext()
        self.navigationController?.popViewController(animated: true)
    }
    
}
