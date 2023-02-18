//
//  MukProfileCell.swift
//  MukFinalProject
//
//  Created by Mukhtar Yusuf on 2/2/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

class MukProfileCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var mukImageView: UIImageView!
    @IBOutlet weak var mukNameLabel: UILabel!
    @IBOutlet weak var mukBirthdayLabel: UILabel!
    @IBOutlet weak var mukGenderLabel: UILabel!
    @IBOutlet weak var mukCountryLabel: UILabel!
    
    // MARK: Properties
    lazy var mukDateFormatter: DateFormatter = {
        let mukDateFormatter = DateFormatter()
        mukDateFormatter.dateStyle = .medium
        mukDateFormatter.timeStyle = .none
        
        return mukDateFormatter
    }()
    
    // MARK: Utilities
    func mukConfigure(with mukProfile: MukProfile) {
        mukNameLabel.text = mukProfile.mukName
        mukBirthdayLabel.text = "Born on \(mukDateFormatter.string(from: mukProfile.mukBirthday))"
        mukGenderLabel.text = mukProfile.mukGender
        mukCountryLabel.text = "Lives in \(mukProfile.mukCountry)"
        
        if mukProfile.mukHasPhoto {
            mukImageView.image = mukProfile.mukProfileImage
        } else {
            mukImageView.image = UIImage(named: "Placeholder")
        }
    }
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        mukImageView.layer.cornerRadius = mukImageView.frame.width / 2.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
