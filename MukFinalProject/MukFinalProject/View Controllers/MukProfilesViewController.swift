//
//  MukProfilesViewController.swift
//  MukFinalProject
//
//  Created by Mukhtar Yusuf on 2/2/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MukProfilesViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukTableView: UITableView!
    @IBOutlet weak var mukMapView: MKMapView!
    @IBOutlet weak var mukSearchBar: UISearchBar!
    
    // MARK: Properties
    var mukCoreDataStack: CoreDataStack! {
        didSet {
            NotificationCenter.default.addObserver(forName:
                    Notification.Name.NSManagedObjectContextObjectsDidChange,
                                                       object: mukManagedObjectContext,
                                                       queue: OperationQueue.main)
            { [weak self] notification in
                if self?.isViewLoaded ?? false { // No need?
                    self?.mukLoadProfiles()
                    self?.mukUpdateUI()
                }
            }
        }
    }
    lazy var mukManagedObjectContext: NSManagedObjectContext = {
        return mukCoreDataStack.managedContext
    }()
    var mukProfiles: [MukProfile] = [] // For Fetching
    var mukFilteredProfiles: [MukProfile] = [] // For Searching and Display
    
    // MARK: Action Methods
    @IBAction func mukChangeMainContent(_ sender: UISegmentedControl) {
        let mukIndex = sender.selectedSegmentIndex
        if mukIndex == 0 {
            mukShowList()
        } else if mukIndex == 1 {
            mukShowMap()
        }
    }
    
    @objc func mukEditProfile(_ sender: UIButton) {
        performSegue(withIdentifier: "EditProfile", sender: sender)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddProfile" || segue.identifier == "EditProfile" {
            if let mukProfileDetailsVC = segue.destination as? MukProfileDetailsViewController {
                mukProfileDetailsVC.mukCoreDataStack = mukCoreDataStack
                
                if segue.identifier == "EditProfile" {
                    var mukEditIndex = -1
                    if let mukProfileCell = sender as? MukProfileCell,
                        let mukIndexPath = mukTableView.indexPath(for: mukProfileCell) {
                        mukEditIndex = mukIndexPath.row
                    } else if let mukButton = sender as? UIButton {
                        mukEditIndex = mukButton.tag
                    }
                        
                    let mukProfileToEdit = mukFilteredProfiles[mukEditIndex]
                    mukProfileDetailsVC.mukProfileToEdit = mukProfileToEdit
                }
            }
        }
    }
    
    // MARK: Utilities
    func mukLoadProfiles() {
        let mukFetchRequest: NSFetchRequest<MukProfile> = MukProfile.fetchRequest()
        let mukSortDescriptor = NSSortDescriptor(key: #keyPath(MukProfile.mukName),
                                                  ascending: true)
        mukFetchRequest.sortDescriptors = [mukSortDescriptor]
        do {
            try mukProfiles = mukManagedObjectContext.fetch(mukFetchRequest)
//            for profile in mukProfiles {
//                if profile.mukPhotoID == nil {
//                    mukManagedObjectContext.delete(profile)
//                    mukCoreDataStack.saveContext()
//                }
//            }
            mukFilteredProfiles = mukProfiles
        } catch let error as NSError {
            mukHandleFetchError(error: error)
        }
    }
    
    func mukUpdateUI() {
        mukUpdateTableView()
        mukUpdateMapView()
    }
    
    func mukUpdateTableView() {
        mukTableView.reloadData()
    }
    
    func mukUpdateMapView() {
        let mukCurAnnotations = mukMapView.annotations
        mukMapView.removeAnnotations(mukCurAnnotations)
        mukMapView.addAnnotations(mukFilteredProfiles)
        
        let mukMapRegion = region(for: mukFilteredProfiles)
        mukMapView.setRegion(mukMapRegion, animated: true)
    }
    
    func mukHandleFetchError(error: NSError) {
        print("Fetching Error \(error), \(error.userInfo)")
    }
    
    func mukShowList() {
        mukTableView.isHidden = false
        mukMapView.isHidden = true
    }
    
    func mukShowMap() {
        mukTableView.isHidden = true
        mukMapView.isHidden = false
    }
    
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        switch annotations.count {
        case 0:
            region = MKCoordinateRegion( center: mukMapView.userLocation.coordinate,
                                         latitudinalMeters: 1000, longitudinalMeters: 1000)
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegion(center: annotation.coordinate,
                                        latitudinalMeters: 1000, longitudinalMeters: 1000)
        default:
            var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)
    
            for annotation in annotations {
                topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude)
                topLeft.longitude = min(topLeft.longitude, annotation.coordinate.longitude)
                bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
            }
    
            let centerLatitude = topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2
            let centerLongitude = topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2
            let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
    
            let extraSpace = 1.1
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) *
                                            extraSpace,
                                        longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
        
        return mukMapView.regionThatFits(region)
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        linkedStuff()
        
        mukSearchBar.delegate = self
        mukMapView.delegate = self
        
        mukTableView.rowHeight = 110
        let mukProfileNib = UINib(nibName: MukTableViewCellIdentifiers.mukProfileCell, bundle: nil)
        let mukNoResultsNib = UINib(nibName: MukTableViewCellIdentifiers.mukNoResultsCell, bundle: nil)
        
        mukTableView.register(mukProfileNib,
                              forCellReuseIdentifier: MukTableViewCellIdentifiers.mukProfileCell)
        mukTableView.register(mukNoResultsNib,
                              forCellReuseIdentifier: MukTableViewCellIdentifiers.mukNoResultsCell)
        
        
        mukTableView.dataSource = self
        mukTableView.delegate = self
        
        mukShowList()
        mukLoadProfiles()
        mukUpdateUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        mukSearchBar.text = ""
        mukFilterProfiles(with: "")
        mukUpdateUI()
        mukSearchBar.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    struct MukTableViewCellIdentifiers {
        static let mukProfileCell = "MukProfileCell"
        static let mukNoResultsCell = "MukNoResultsCell"
    }
    
    private func linkedStuff() {
        let nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        
        let list1 = populateList(nums: nums, index: 0)
        print("Before reversal")
        displayList(linkedNode: list1)
        
        let list2 = reverseList(prev: nil, cur: list1)
        print("After reversal")
        displayList(linkedNode: list2)
    }
    
    private func populateList(nums: [Int], index: Int) -> LinkedNode? {
        if nums.count == 0 || index >= nums.count {
            return nil
        }
        
        let node = LinkedNode(value: nums[index])
        node.next = populateList(nums: nums, index: index + 1)
        
        return node
    }
    
    private func reverseList(prev: LinkedNode?, cur: LinkedNode?) -> LinkedNode? {
        guard let cur = cur else {
            return prev
        }
        
        let next = cur.next
        cur.next = prev
        
        return reverseList(prev: cur, cur: next)
    }
    
    private func displayList(linkedNode: LinkedNode?) {
        var current = linkedNode
        
        while let cur = current {
            print("\(cur.value) -> ")
            current = current?.next
        }
    }
}

// MARK: UITableView DataSource and Delegate Methods
extension MukProfilesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mukCount = mukFilteredProfiles.count
        if mukCount == 0 {
            return 1
        } else {
            return mukCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var mukCell: UITableViewCell
        if mukFilteredProfiles.count == 0 {
            mukCell = tableView.dequeueReusableCell(withIdentifier: MukTableViewCellIdentifiers.mukNoResultsCell,
                                                    for: indexPath)
        } else {
            mukCell = tableView.dequeueReusableCell(withIdentifier: MukTableViewCellIdentifiers.mukProfileCell,
                                                    for: indexPath)
        }
        
        if let mukCell = mukCell as? MukProfileCell {
            let mukProfile = mukFilteredProfiles[indexPath.row]
            mukCell.mukConfigure(with: mukProfile)
            print("Profile Pic ID: \(mukProfile.mukPhotoID?.intValue ?? -1)")
        }
        
        return mukCell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if mukFilteredProfiles.count == 0 {
            return nil
        }
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let mukProfileCell = tableView.cellForRow(at: indexPath) as? MukProfileCell {
            performSegue(withIdentifier: "EditProfile", sender: mukProfileCell)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let mukProfile = mukFilteredProfiles[indexPath.row]
            mukManagedObjectContext.delete(mukProfile)
            mukCoreDataStack.saveContext()
            
//            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Profiles"
        return nil
    }
}

extension MukProfilesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        mukFilterProfiles(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        mukFilterProfiles(with: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
    
    // MARK: Utilities
    func mukFilterProfiles(with mukText: String) {
        if mukText.isEmpty {
            mukFilteredProfiles = mukProfiles
        } else {
            mukFilteredProfiles = mukProfiles.filter { mukProfile in
                mukProfile.description.contains(mukText)
            }
        }
        
        mukUpdateUI()
    }
}

// MARK: MKMapView Delegate
extension MukProfilesViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MukProfile else {
            return nil
        }
        
        let mukIdentifier = "MukProfile"
        var mukAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: mukIdentifier)
        if mukAnnotationView == nil {
            let mukPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: mukIdentifier)
            mukPinView.isEnabled = true
            mukPinView.canShowCallout = true
            mukPinView.animatesDrop = false
            // Color R: 0, G: 186, B: 135, A: 50
            mukPinView.pinTintColor = UIColor(red: 0.0, green: 186/255, blue: 135/255, alpha: 1.0)
            
            let mukEditProfileButton = UIButton(type: .detailDisclosure)
            mukEditProfileButton.addTarget(self, action: #selector(mukEditProfile), for: .touchUpInside)
            mukPinView.rightCalloutAccessoryView = mukEditProfileButton
            
            mukAnnotationView = mukPinView
        }
        
        if let mukAnnotationView = mukAnnotationView {
            mukAnnotationView.annotation = annotation
            if let mukButton = mukAnnotationView.rightCalloutAccessoryView as? UIButton,
                let mukIndex = mukFilteredProfiles.firstIndex(of: annotation as! MukProfile) {
                mukButton.tag = mukIndex
            }
        }
        
        return mukAnnotationView
    }
}

class LinkedNode {
    var value: Int
    var next: LinkedNode?
    
    init(value: Int) {
        self.value = value
    }
}

/*
 1. Bill Gates (Microsoft)
    Male, October 28, 1955, United States
    37.792881072292666, -122.40404543716319
 
 2. Mark Zuckerberg (Facebook)
    Male, May 14, 1984, United States
    37.78978741636388, -122.39476394564849
 
 3. Larry Page (Google)
    Male, March 26, 1973, United States
    37.78988546654101, -122.39009787392145
 
 4. Jeff Bezos (Amazon)
    Male, January 12, 1964, United States
    37.79209735742592, -122.39195400450167
 
 5. Jack Dorsey (Twitter)
    Male, November 19, 1976, United States
    37.77670592339799, -122.41713602974508
 
 6. Jeff Weiner (LinkedIn)
    Male, February 21, 1970, United States
    37.786696354317414, -122.3981173739215
 
 7. Brian Chesky (Airbnb)
    Male, August 29, 1981, United States
    37.77198684199061, -122.4054090892633
    
 8. Michael Dell (Dell)
    Male, February 23, 1965, United States
    37.771228187196265, -122.40361044508666
 
 9. Marissa Mayer (Yahoo)
    Female, May 30, 1975, United States
    37.78228636696698, -122.40593801625099
 
 10. Ben Silbermann (Pinterest)
    Male, July 14, 1982, United States
    37.7756066242826, -122.39943528982558
 
 11. Elon Musk (Tesla)
    Male, June 28, 1971, United States
    37.78479281820518, -122.42143514508626
 */
