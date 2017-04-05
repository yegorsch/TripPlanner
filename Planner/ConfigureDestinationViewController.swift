//
//  ConfigureDestinationViewController.swift
//  Planner
//
//  Created by Егор on 3/23/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.


import UIKit
import GoogleMaps
import GooglePlaces
import FSCalendar

class ConfigureDestinationViewController: UIViewController,FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    var destination:Destination!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var placeLabel: UILabel!
    var startPlace:GMSPlace!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var tripNameField: UITextField!
    var endDate:Date! { didSet {endLabel.text = "End: " + Toolkit.formatDate(date: endDate) } }
    var startDate:Date! { didSet {startLabel.text = "Start: " + Toolkit.formatDate(date: startDate) } }
    var todayDate = Date()
    
    //effects
    
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    var effect:UIVisualEffect!
    
    @IBOutlet weak var calendar: FSCalendar!
    
    var dateEditingNow:dateLabel!

    
    enum dateLabel {
        case start
        case end
    }
    
    override func viewDidLoad() {
        // effects
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        effect = blurEffectView.effect
        blurEffectView.effect = nil
        blurEffectView.isUserInteractionEnabled = true
        blurEffectView.isHidden = true
        //
        tripNameField.adjustsFontSizeToFitWidth = true
        initMapView(withPlace: startPlace)
        placeLabel.text = startPlace.name
        //Calendar
        calendar.dataSource = self
        calendar.delegate = self
        startDate = Date()
        endDate = Date().addingTimeInterval(TimeInterval.init(60*60*24))
        //
        placeLabel.adjustsFontSizeToFitWidth = true
        tripNameField.adjustsFontSizeToFitWidth = true
        endLabel.adjustsFontSizeToFitWidth = true
        startLabel.adjustsFontSizeToFitWidth = true
        //
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        startLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.chooseStartDate(sender:))))
        endLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.chooseEndDate(sender:))))
        //
        calendarView.layer.cornerRadius = 5
    
    }
//    func keyboardWillShow(notification: NSNotification) {
//        
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y == 0{
//                self.view.frame.origin.y -= keyboardSize.height + 50
//            }
//        }
//        
//    }
//    
//    func keyboardWillHide(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y != 0{
//                self.view.frame.origin.y += keyboardSize.height
//            }
//        }
//    }
    func chooseStartDate(sender:UIGestureRecognizer){
            self.view.addSubview(calendarView)
        blurEffectView.isHidden = false
        calendarView.center = self.view.center
        calendarView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        calendarView.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.blurEffectView.effect = self.effect
            self.calendarView.alpha = 1
            self.calendarView.transform = CGAffineTransform.identity
        })
        dateEditingNow = dateLabel.start
    }
    
    func chooseEndDate(sender:UIGestureRecognizer){
        self.view.addSubview(calendarView)
        blurEffectView.isHidden = false
        calendarView.center = self.view.center
        calendarView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        calendarView.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.blurEffectView.effect = self.effect
            self.calendarView.alpha = 1
            self.calendarView.transform = CGAffineTransform.identity
        })
        dateEditingNow = dateLabel.end
    }
    
    @IBAction func dateSelected(_ sender: UIButton) {
        if let dates = calendar.selectedDates as? [Date]{
            if dates.count > 0 {
                if calendar.selectedDate! < todayDate{
                    presentAlert(withMessage: "Please choose date no earlier than today")
                    return
                }
                switch dateEditingNow! {
                case .start:
                    if startDate <= endDate{
                    startDate = calendar.selectedDate
                    startLabel.textColor = UIColor.black
                    }else{
                       presentAlert(withMessage: "Please, choose date before " + Toolkit.formatDate(date: endDate))
                    }
                    break
                case .end:
                    if calendar.selectedDate! > startDate {
                        endDate = calendar.selectedDate
                        endLabel.textColor = UIColor.black
                    }else{
                        presentAlert(withMessage: "Please, choose date after " + Toolkit.formatDate(date: startDate))
                    }
                    break
                }
                removeCalendarView()
            }
        }
    }
    
    @IBAction func cancelCalendarView(_ sender: UIButton) {
        removeCalendarView()
    }
    
    
    func initMapView(withPlace: GMSPlace){
        let camera = GMSCameraPosition.camera(withLatitude: withPlace.coordinate.latitude, longitude: withPlace.coordinate.longitude, zoom: 11)
        self.mapView.camera = camera
    }
    
    func donePressed(){
        if (tripNameField.text == "") {
            presentAlert(withMessage: "Please enter your trip name")
            return
        }
       let context = Toolkit.getContext()
       destination = Destination(context: context)
       destination.endDate = NSDate(timeInterval: 0, since: endDate)
       destination.startDate = NSDate(timeInterval: 0, since: startDate)
       destination.isPast = false
       destination.name = tripNameField.text
       destination.startPlaceId = startPlace.placeID
       destination.startPlaceName = startPlace.name
       Toolkit.saveContext()
       self.navigationController?.popViewController(animated: true)
       performSegue(withIdentifier: "showPlaceVC", sender: destination)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.flatBlack

    }

    func presentAlert(withMessage:String){
        let alert = UIAlertController(title: "Hey", message: withMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func removeCalendarView(){
        UIView.animate(withDuration: 0.3, animations: {
            self.calendarView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.calendarView.alpha = 0
            self.blurEffectView.effect = nil
        }) { (done:Bool) in
            self.calendarView.removeFromSuperview()
            self.blurEffectView.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let guest = segue.destination as! placeOverviewViewController
        guest.destination = sender as! Destination
    }
    
}
