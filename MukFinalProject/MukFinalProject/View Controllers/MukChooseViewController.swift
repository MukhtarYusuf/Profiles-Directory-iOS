//
//  MukChooseViewController.swift
//  MukFinalProject
//
//  Created by Mukhtar Yusuf on 2/2/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

class MukChooseViewController: UITableViewController {

    var mukChosenIndex = 0
    let mukGenders = ["Male", "Female", "Other"]
    lazy var mukCountries: [String] = {
        var mukCountries: [String] = []
        for mukCode in NSLocale.isoCountryCodes {
            let mukID = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue : mukCode])
            print("Identifier: \(mukID)")
            let mukName = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier,
                                                                          value: mukID)
            mukCountries.append(mukName ?? "Invalid Country Code")
        }
        
        return mukCountries
    }()
    var mukChosenGender: String?
    var mukChosenCountry: String?
    var mukChoices: [String] = []
//    var mukCountries1 = ["Australia", "Canada", "United Kingdom", "United States"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let mukChosenGender = mukChosenGender {
            title = "Choose Gender"
            mukChoices = mukGenders
            mukChosenIndex = mukChoices.firstIndex(of: mukChosenGender) ?? 0
        } else if let mukChosenCountry = mukChosenCountry {
            title = "Choose Country"
            mukChoices = mukCountries
            mukChosenIndex = mukChoices.firstIndex(of: mukChosenCountry) ?? 0
        }
        
        tableView.reloadData()
    }

    // MARK: UITableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mukChoices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mukCell = tableView.dequeueReusableCell(withIdentifier: "MukCell", for: indexPath)
        mukCell.textLabel?.text = mukChoices[indexPath.row]
        
        if mukChosenIndex == indexPath.row {
            mukCell.accessoryType = .checkmark
        } else {
            mukCell.accessoryType = .none
        }

        return mukCell
    }

    // MARK: UITableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var mukCell = tableView.cellForRow(at: IndexPath(row: mukChosenIndex,
                                                         section: indexPath.section))
        mukCell?.accessoryType = .none
        
        mukChosenIndex = indexPath.row // No need?
        mukCell = tableView.cellForRow(at: indexPath)
        mukCell?.accessoryType = .checkmark
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChooseOption" {
            if let mukCell = sender as? UITableViewCell,
                let mukIndexPath = tableView.indexPath(for: mukCell) {
                if mukChosenGender != nil {
                    mukChosenGender = mukChoices[mukIndexPath.row]
                } else {
                    mukChosenCountry = mukChoices[mukIndexPath.row]
                }
            }
        }
    }

}
