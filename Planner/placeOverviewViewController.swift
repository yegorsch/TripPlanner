//
//  placeOverviewViewController.swift
//  Planner
//
//  Created by Егор on 3/27/17.
//  Copyright © 2017 Yegor's Mac. All rights reserved.
//

import UIKit
import CoreData
import GooglePlaces

class placeOverviewViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate ,UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    let categories = ["Transfer", "Housing", "Places", "Overview"]
    var destination:Destination!
    
    @IBOutlet weak var initialPlaceLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.autoresizingMask.insert(.flexibleHeight)
        self.collectionView.autoresizingMask.insert(.flexibleWidth)
        self.initialPlaceLabel.text = destination.startPlaceName
        self.datesLabel.text = Toolkit.formatDate(date: destination.startDate!) + " - " + Toolkit.formatDate(date: destination.endDate!)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.flatBlack
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.flatBlack

    }
    

    
    
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15, 10, 0, 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath as IndexPath) as! CategoryCell
        cell.nameLabel.text = self.categories[indexPath.item]
        cell.backgroundColor =  UIColor(hexString: "D1FBDD")
        cell.nameLabel.textColor = UIColor(hexString: "008080")
        cell.layer.cornerRadius = 5
        return cell
    }
    
    // Setting size for the cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let nbCol = 2
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(nbCol - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(nbCol))
        return CGSize(width: Int(size  - 20 ), height:Int( self.collectionView.bounds.height / 2.5))
    }
    
    // Configuring segues
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "showTripGraph", sender: self.destination)
        case 1:
            performSegue(withIdentifier: "showHousing", sender: self.destination)
        case 2:
            performSegue(withIdentifier: "showPlaces", sender: self.destination)
        case 3:
            performSegue(withIdentifier: "showOverview", sender: self.destination)
        default:
            print("lol")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? tripGraphViewController{
            vc.destination = self.destination
        }else if let vc = segue.destination as?
            HousingGraphViewController{
            vc.destination = self.destination
        }
        else if let vc = segue.destination as?
            PlacesToVisitViewController{
            vc.destination = self.destination
        }else if let vc = segue.destination as?
            MapOverviewViewController{
            vc.destination = self.destination
        }
    }
    
    
}
