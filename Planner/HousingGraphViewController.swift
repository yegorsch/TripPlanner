//
//  HousingGraphViewController.swift
//  Planner
//
//  Created by Егор on 4/1/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import DateTimePicker
import GooglePlaces

class HousingGraphViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,GMSAutocompleteViewControllerDelegate  {
    
    @IBOutlet var addHousingView: UIView!
    @IBOutlet weak var tableView: UITableView!
    //coredata vars
    var housings = [House]()
    var destination:Destination!
    var checkInDate:Date! { didSet {
        self.checkInButton.setTitle(Toolkit.formatDateAndTime(date: checkInDate), for: .normal)
        }
    }
    var checkOutDate:Date! { didSet {
        self.checkOutButton.setTitle(Toolkit.formatDateAndTime(date: checkOutDate), for: .normal)
        }
    }
    var housingPlace:GMSPlace! { didSet {
        self.placeButton.setTitle( housingPlace.name, for: .normal)
        }
    }
    
    @IBOutlet weak var additionalInfoLabel: UITextView!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    var effect:UIVisualEffect!
    var picker = DateTimePicker()
    // blur view outlets
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var placeButton: UIButton!
    @IBOutlet weak var checkInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Housing"
        loadHousing()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // effects
        effect = blurEffectView.effect
        blurEffectView.effect = nil
        blurEffectView.isUserInteractionEnabled = true
        blurEffectView.isHidden = true
        //
        loadHousing()
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addHousing))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(hexString: "D1FBDD")
        // outlets
        placeButton.addTarget(self, action: #selector(addPlace(sender:)), for: .touchUpInside)
        checkInButton.addTarget(self, action: #selector(selectCheckInDate(sender:)), for: .touchUpInside)
        checkOutButton.addTarget(self, action: #selector(selectCheckOutDate(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.flatBlack
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.flatBlack

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "housingCell", for: indexPath) as! HousingViewCell
        
        cell.placeNameLabel.text = housings[indexPath.row].placeName
        cell.checkInLabel.text = Toolkit.formatDateAndTime(date: housings[indexPath.row].checkInDate!)
        cell.checkOutLabel.text = Toolkit.formatDateAndTime(date: housings[indexPath.row].checkInDate!)
        cell.infoLabel.text = housings[indexPath.row].info
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = heightFor(text: housings[indexPath.row].info ?? "")
        return CGFloat(height) + 80.0
    }
    
    func heightFor(text:String) -> Int{
        let maxHeight = 1000
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: Int(self.view.bounds.width), height: maxHeight))
        textView.text = text
        textView.font = UIFont(name: "Helvetica", size: 18)
        textView.sizeToFit()
        return Int(textView.frame.size.height)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return housings.count
    }
    
    func loadHousing(){
        if let housingRetrieved = destination.hasHousing?.allObjects as? [House]{
            self.housings = housingRetrieved.sorted { Toolkit.dateFromNSDate(date: $0.checkInDate!) < Toolkit.dateFromNSDate(date: $1.checkInDate!) }
        }
    }
    func addHousing(){
        self.view.addSubview(addHousingView)
        blurEffectView.isHidden = false
        addHousingView.center = self.view.center
        addHousingView.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.blurEffectView.effect = self.effect
            self.addHousingView.alpha = 1
            self.addHousingView.transform = CGAffineTransform.identity
        })
    }
    @IBAction func saveButtonTapped(_ sender: UIButton)
    {
        if (housingPlace != nil && checkInDate != nil && checkOutDate != nil){
            let context = Toolkit.getContext()
            let housing = House(context: context)
            housing.checkInDate = NSDate(timeInterval: 0, since: checkInDate)
            housing.checkOutDate = NSDate(timeInterval: 0, since: checkOutDate)
            housing.placeName = housingPlace.name
            housing.placeID = housingPlace.placeID
            housing.destination = destination
            housing.info = additionalInfoLabel.text
            Toolkit.saveContext()
            loadHousing()
            self.tableView.reloadData()
            UIView.animate(withDuration: 0.3, animations: {
                self.addHousingView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                self.addHousingView.alpha = 0
                self.blurEffectView.effect = nil
            }) { (done:Bool) in
                self.addHousingView.removeFromSuperview()
                self.blurEffectView.isHidden = true
            }
        }else{
            let alert = UIAlertController(title: "Hey", message: "Please enter all information", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.addHousingView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.addHousingView.alpha = 0
            self.blurEffectView.effect = nil
        }) { (done:Bool) in
            self.addHousingView.removeFromSuperview()
            self.blurEffectView.isHidden = true
        }
    }
    func selectCheckInDate(sender:UIGestureRecognizer){
        picker = DateTimePicker.show()
        picker.selectedDate = Toolkit.dateFromNSDate(date: destination.startDate!)
        self.view.endEditing(true)
        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.completionHandler = { date in
            self.checkInDate = date
        }
    }
    func selectCheckOutDate(sender:UIGestureRecognizer){
        picker = DateTimePicker.show()
        picker.selectedDate = Toolkit.dateFromNSDate(date: destination.startDate!)
        self.view.endEditing(true)
        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.completionHandler = { date in
            self.checkOutDate = date
        }
    }
    
    // Searching for place
    func addPlace(sender:UIGestureRecognizer){
        print("lol")
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    // Configuring place autocomplete
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.housingPlace = place
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
    
    
    
    
}
