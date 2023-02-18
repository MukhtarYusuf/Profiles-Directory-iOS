//
//  MukProfile+CoreDataClass.swift
//  MukFinalProject
//
//  Created by Mukhtar Yusuf on 2/2/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(MukProfile)
public class MukProfile: NSManagedObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(mukLatitude, mukLongitude)
    }
    public var title: String? {
        return mukName
    }
    public var subtitle: String? {
        return """
                \(mukAge) Year Old \(mukGender), \(mukCountry)
                """
    }
    public override var description: String {
        let mukString = """
                        \(mukName)
                        \(mukGender)
                        \(mukCountry)
                        \(mukDateFormatter.string(from: mukBirthday))
                        """
        
        return mukString
    }
    var mukHasPhoto: Bool {
        return mukPhotoID != nil
    }
    var mukDocumentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    var mukPhotoURL: URL {
//        assert(mukPhotoID != nil, "No Photo ID") // There's a better way to do this.
        var mukFileName = ""
        if mukPhotoID != nil {
            mukFileName = "Profile-Photo-\(mukPhotoID!.intValue)"
        }
        
        return mukDocumentsDirectory.appendingPathComponent(mukFileName)
    }
    var mukProfileImage: UIImage? {
        return UIImage(contentsOfFile: mukPhotoURL.path)
    }
    var mukAge: Int {
        let mukDifference = mukBirthday.distance(to: Date())
        let mukSecondsInYear = 31536000.0
        let mukAge = Int(mukDifference / mukSecondsInYear)
        
        return mukAge
    }
    lazy var mukDateFormatter: DateFormatter = {
        let mukFormatter = DateFormatter()
        mukFormatter.dateStyle = .long
        mukFormatter.timeStyle = .none
        
        return mukFormatter
    }()
    
    private func mukNextPhotoID() -> Int {
        let mukUserDefaults = UserDefaults.standard
        var mukCurrentID = mukUserDefaults.integer(forKey: "PhotoID")
        mukCurrentID += 1
        mukUserDefaults.set(mukCurrentID, forKey: "PhotoID")
        mukUserDefaults.synchronize()
        
        return mukCurrentID
    }
    
    func mukSavePhoto(mukImage: UIImage?) {
        guard let mukImage = mukImage else { return }
        
        if !mukHasPhoto {
            mukPhotoID = mukNextPhotoID() as NSNumber
        }
        
        if let mukData = mukImage.jpegData(compressionQuality: 0.5) {
            do {
                try mukData.write(to: mukPhotoURL, options: .atomic)
            } catch {
                print("Error saving image \(error)")
            }
        }
    }
    
    func mukDeletePhoto() {
        guard mukHasPhoto else { return }
        
        do {
            try FileManager.default.removeItem(at: mukPhotoURL)
        } catch {
            print("Error deleting image \(mukPhotoID!.intValue)")
        }
    }
}
