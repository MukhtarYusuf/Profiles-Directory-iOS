//
//  MukProfile+CoreDataProperties.swift
//  MukFinalProject
//
//  Created by Mukhtar Yusuf on 2/2/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//
//

import Foundation
import CoreData


extension MukProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MukProfile> {
        return NSFetchRequest<MukProfile>(entityName: "MukProfile")
    }

    @NSManaged public var mukName: String
    @NSManaged public var mukBirthday: Date
    @NSManaged public var mukGender: String
    @NSManaged public var mukCountry: String
    @NSManaged public var mukLatitude: Double
    @NSManaged public var mukLongitude: Double
    @NSManaged public var mukPhotoID: NSNumber?

}
