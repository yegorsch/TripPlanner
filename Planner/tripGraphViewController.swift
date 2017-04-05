//
//  tripGraphViewController.swift
//  Planner
//
//  Created by Егор on 3/28/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import UIKit
import CoreData
import DZNEmptyDataSet
import ChameleonFramework

class tripGraphViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate   {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var destination:Destination!
    var hops = [Hop]()
    var infoTexts = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadHops()
        self.collectionView.emptyDataSetSource = self
        self.collectionView.emptyDataSetDelegate = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addHop))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.flatBlack
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.flatBlack

    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hops.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tripNodeView", for: indexPath as IndexPath) as! tripNodeView
        cell.arrivalPlaceLabel.text = hops[indexPath.row].arrivalPlace
        cell.arrivalTime.text = Toolkit.formatDateAndTime(date: hops[indexPath.row].arrivalTime!)
        cell.departurePlaceLabel.text = hops[indexPath.row].departurePlace
        cell.departureTime.text = Toolkit.formatDateAndTime(date: hops[indexPath.row].departureTime!)
        cell.infoLabel.text = hops[indexPath.row].info
        cell.settingButton.addTarget(self, action: #selector(settingButtonPressed(sender:)), for: .touchUpInside)
        cell.deleteNodeButton.addTarget(self, action: #selector(deleteButtonPressed(sender:)), for: .touchUpInside)
        cell.deleteNodeButton.tag = indexPath.row
        cell.settingButton.tag = indexPath.row
        return cell
    }
    
    func settingButtonPressed(sender :UIButton){
        self.performSegue(withIdentifier: "changeHop", sender: sender.tag)
    }
    
    func deleteButtonPressed(sender :UIButton){
    let alert = UIAlertController(title: "Hey", message: "Are you sure you want to delete?", preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alert: UIAlertAction!) in
        let context = Toolkit.getContext()
        context.delete(self.hops[sender.tag])
        self.hops.remove(at: sender.tag)
        Toolkit.saveContext()
        self.collectionView.reloadData()
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
        
    }

    
    // Configuring height based on the info text
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let nbCol = 1
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.minimumLineSpacing = 10
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(nbCol - 1))
        // width for the cell
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(nbCol))
        // adjusting height for the cell
        var cell = self.collectionView.cellForItem(at: indexPath) as? tripNodeView
        return CGSize(width: size, height: heightFor(text: hops[indexPath.row].info!) + 95)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    func heightFor(text:String) -> Int{
        let maxHeight = 1000
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: Int(self.view.bounds.width), height: maxHeight))
        textView.text = text
        textView.font = UIFont(name: "Helvetica", size: 18)
        textView.sizeToFit()
        return Int(textView.frame.size.height)
    }
    //
    // Segues and loads
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NewHopViewController{
            if segue.identifier == "newHop"{
                vc.destination = self.destination
            } else if segue.identifier == "changeHop"{
                vc.destination = self.destination
                let pos = sender as? Int
                vc.hop = self.hops[pos!]
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadHops()
        self.collectionView.reloadData()
    }
    
    func addHop(){
        performSegue(withIdentifier: "newHop", sender: self.destination)
    }
    func loadHops(){
        if let hopsRetrieved = destination.hasHops?.allObjects as? [Hop]{
           self.hops = hopsRetrieved.sorted { Toolkit.dateFromNSDate(date: $0.departureTime!) < Toolkit.dateFromNSDate(date: $1.departureTime!) }
        }
    }
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "emptyTransfer")
    }

    
}
