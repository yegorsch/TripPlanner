//
//  TransferTableVIewController.swift
//  Planner
//
//  Created by Егор on 3/30/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import DateTimePicker

class TransferTableVIewController: UITableViewController {
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var noteCell: UITableViewCell!
    var destination:Destination!
    @IBOutlet weak var additionalInfoTextField: UITextView!
    @IBOutlet weak var departurePlaceField: UITextField!
    @IBOutlet weak var departureTimeField: UITextField!
    @IBOutlet weak var arrivalPlaceField: UITextField!
    @IBOutlet weak var arrivalTimeField: UITextField!
    var previousOffset:CGFloat = 0.0;
    enum TimePart {
        case departure
        case arrival
    }
    var timeEditingNow:TimePart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentSize = CGSize(width: self.tableView.bounds.width, height: self.tableView.bounds.height * 1.5)
        updateWidthsForLabels(labels: labels)
        self.view.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.flatBlack
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.flatBlack

    }
    
    
    // Making labels equal
    private func calculateLabelWidth(label: UILabel) -> CGFloat {
        let labelSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: label.frame.height))
        
        return labelSize.width
    }
    private func calculateMaxLabelWidth(labels: [UILabel]) -> CGFloat {
        var max = calculateLabelWidth(label: labels[0])
        for label in labels{
            if calculateLabelWidth(label: label) > max{
                max = calculateLabelWidth(label: label)
            }
        }
        return max
    }
    
    
    private func updateWidthsForLabels(labels: [UILabel]) {
        let maxLabelWidth = calculateMaxLabelWidth(labels: labels)
        for label in labels {
            let constraint = NSLayoutConstraint(item: label,
                                                attribute: .width,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .notAnAttribute,
                                                multiplier: 1,
                                                constant: maxLabelWidth)
            label.addConstraint(constraint)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func configureKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.tableView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 4{
            return self.view.bounds.height / 3
        }
        return  self.view.bounds.height / 6.0
        
    }
    
    
    
}
