//
//  MukProfileDetailsViewController.swift
//  MukFinalProject
//
//  Created by Mukhtar Yusuf on 2/2/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import CoreData

class MukProfileDetailsViewController: UITableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukNameTextField: UITextField!
    @IBOutlet weak var mukLatitudeTextField: UITextField!
    @IBOutlet weak var mukLongitudeTextField: UITextField!
    @IBOutlet weak var mukGenderLabel: UILabel!
    @IBOutlet weak var mukCountryLabel: UILabel!
    @IBOutlet weak var mukBirthdayDatePicker: UIDatePicker!
    @IBOutlet weak var mukProfileImageView: UIImageView!
    @IBOutlet weak var mukDeleteButton: UIBarButtonItem!
    
    // MARK: Properties
    var mukCoreDataStack: CoreDataStack!
    lazy var mukManagedObjectContext: NSManagedObjectContext = {
        return mukCoreDataStack.managedContext
    }()
    var mukProfileToEdit: MukProfile? {
        didSet {
            if let mukProfile = mukProfileToEdit {
                mukName = mukProfile.mukName
                mukLatitude = mukProfile.mukLatitude
                mukLongitude = mukProfile.mukLongitude
                mukGender = mukProfile.mukGender
                mukCountry = mukProfile.mukCountry
                mukBirthday = mukProfile.mukBirthday
                mukProfileImage = mukProfile.mukProfileImage
            }
        }
    }
    var mukName = ""
    var mukLatitude = 0.0
    var mukLongitude = 0.0
    var mukGender = "Other"
    var mukCountry = "Canada"
    var mukBirthday = Date()
    var mukProfileImage: UIImage?
    
    // MARK: UITableView Delegate Methods
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch(indexPath.section, indexPath.row) {
        case (1, _):
            return indexPath
        case (2, 3):
            return indexPath
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2, indexPath.row == 3 {
            mukChoosePhoto()
        }
    }
    
    // MARK: Action Methods
    @IBAction func mukSaveProfile(_ sender: UIBarButtonItem) {
        guard mukValidateForm() else { return }
        
        let mukHudView = HudView.hud(inView: navigationController!.view, animated: true)
        
        var mukProfile: MukProfile
        if let mukProfileToEdit = mukProfileToEdit {
            mukProfile = mukProfileToEdit
            mukHudView.text = "Updated"
        } else {
            mukProfile = MukProfile(context: mukManagedObjectContext)
            mukProfile.mukPhotoID = nil
            mukHudView.text = "Added"
        }
        
        mukProfile.mukName = mukName
        mukProfile.mukLatitude = mukLatitude
        mukProfile.mukLongitude = mukLongitude
        mukProfile.mukGender = mukGender
        mukProfile.mukCountry = mukCountry
        mukProfile.mukBirthday = mukBirthday
        mukProfile.mukSavePhoto(mukImage: mukProfileImage)
        
        mukCoreDataStack.saveContext()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            mukHudView.hide()
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func mukDeleteProfile(_ sender: UIBarButtonItem) {
        if let mukProfileToEdit = mukProfileToEdit {
            let mukHudView = HudView.hud(inView: navigationController!.view, animated: true)
            mukHudView.text = "Deleted"
            
            mukManagedObjectContext.delete(mukProfileToEdit)
            mukCoreDataStack.saveContext()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                mukHudView.hide()
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func mukDidChooseOption(_ sender: UIStoryboardSegue) {
        if sender.identifier == "ChooseOption" {
            if let mukChooseVC = sender.source as? MukChooseViewController {
                if let mukChosenGender = mukChooseVC.mukChosenGender {
                    mukGender = mukChosenGender
                    mukGenderLabel.text = mukChosenGender
                } else if let mukChosenCountry = mukChooseVC.mukChosenCountry {
                    mukCountry = mukChosenCountry
                    mukCountryLabel.text = mukChosenCountry
                }
            }
        }
    }
    
    // MARK: Utilities
    func mukValidateForm() -> Bool {
        var mukIsValid = true
        var mukMessage = ""
        
        // Get and Validate Name
        if let mukName = mukNameTextField.text, !mukName.isEmpty {
            self.mukName = mukName
        } else {
            mukMessage = "Please Enter a Valid Name!"
            mukIsValid = false
        }
        
        // Get and Validate Latitude
        if let mukLatitudeString = mukLatitudeTextField.text,
            let mukLatitude = Double(mukLatitudeString) {
            self.mukLatitude = mukLatitude
        } else {
            if mukMessage.isEmpty {
                mukMessage = "Please Enter a Valid Latitude!"
            }
            mukIsValid = false
        }
        
        // Get and Validate Longitude
        if let mukLongitudeString = mukLongitudeTextField.text,
            let mukLongitude = Double(mukLongitudeString) {
            self.mukLongitude = mukLongitude
        } else {
            if mukMessage.isEmpty {
                mukMessage = "Please Enter a Valid Longitude!"
            }
            mukIsValid = false
        }
        
        // Get Birthday
        mukBirthday = mukBirthdayDatePicker.date
        
        // -- Don't Really Need the Rest --
        // Get Gender
        if let mukGenderString = mukGenderLabel.text, !mukGenderString.isEmpty {
            self.mukGender = mukGenderString
        }
        
        // Get Country
        if let mukCountryString = mukCountryLabel.text, !mukCountryString.isEmpty {
            self.mukCountry = mukCountryString
        }
        
        // Get Profile Image
        mukProfileImage = mukProfileImageView.image
        
        if !mukIsValid {
            mukShowAlert(mukMessage: mukMessage)
        }
        
        return mukIsValid
    }
    
    func mukShowAlert(mukMessage: String) {
        let mukAlert = UIAlertController(title: mukMessage,
                                         message: nil,
                                         preferredStyle: .alert)
        let mukAction = UIAlertAction(title: "Ok", style: .default)
        mukAlert.addAction(mukAction)
        
        present(mukAlert, animated: true)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChooseGender" {
            if let mukChooseVC = segue.destination as? MukChooseViewController {
                mukChooseVC.mukChosenGender = mukGender
            }
        } else if segue.identifier == "ChooseCountry" {
            if let mukChooseVC = segue.destination as? MukChooseViewController {
                mukChooseVC.mukChosenCountry = mukCountry
            }
        }
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Profile"
        
        // Must be at least 10 years old to use
        let mukTenYearAgo = Date(timeIntervalSinceNow: TimeInterval(-31536000*10))
        mukBirthdayDatePicker.date = mukTenYearAgo
        mukBirthdayDatePicker.maximumDate = mukTenYearAgo
        
        mukGenderLabel.text = mukGender
        mukCountryLabel.text = mukCountry
        
        if mukProfileToEdit != nil {
            title = "Edit Profile"
            mukDeleteButton.isEnabled = true
            
            mukNameTextField.text = mukName
            mukLatitudeTextField.text = "\(mukLatitude)"
            mukLongitudeTextField.text = "\(mukLongitude)"
            mukGenderLabel.text = mukGender
            mukCountryLabel.text = mukCountry
            mukBirthdayDatePicker.date = mukBirthday
            mukProfileImageView.image = mukProfileImage
        }
    }
}

extension MukProfileDetailsViewController:
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    // MARK: Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info:
        [UIImagePickerController.InfoKey : Any]) {
        
        let mukChosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        mukProfileImageView.image = mukChosenImage
        mukProfileImage = mukChosenImage
//        tableView.reloadData()
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Utilities
    func mukTakePhotoWithCamera() {
        let mukImagePicker = UIImagePickerController()
        mukImagePicker.sourceType = .camera
        mukImagePicker.delegate = self
        mukImagePicker.allowsEditing = true
        
        present(mukImagePicker, animated: true, completion: nil)
    }
    
    func mukChoosePhotoFromLibrary() {
        let mukImagePicker = UIImagePickerController()
        mukImagePicker.sourceType = .photoLibrary
        mukImagePicker.delegate = self
        mukImagePicker.allowsEditing = true
        
        present(mukImagePicker, animated: true, completion: nil)
    }
    
    func mukChoosePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            mukShowPhotoMenu()
        } else {
            mukChoosePhotoFromLibrary()
        }
    }
    
    func mukShowPhotoMenu() {
        let mukAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let mukCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        mukAlert.addAction(mukCancelAction)
        
        let mukPhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {_ in
            self.mukTakePhotoWithCamera()
        })
        mukAlert.addAction(mukPhotoAction)
        
        let mukLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: {_ in
            self.mukChoosePhotoFromLibrary()
        })
        mukAlert.addAction(mukLibraryAction)
        
        present(mukAlert, animated: true, completion: nil)
     }
}

/*
// Coordinates
1). Lambton: 43.773580791681646, -79.33599846022913
2). Toronto Airport: 43.67853196389666, -79.62464807792082
3). Costco: 43.76004279881852, -79.29763946511994
4). Casa Loma: 43.678168989401975, -79.40942244489115
5.  Michael Garron Hospital: 43.69011635260322, -79.32482648722
*/
