//
//  Meal.swift
//  FoodTracker
//
//  Created by Rishma Mendhekar on 8/30/19.
// Created using Tutorial 5
// Created using Tutorial 9

import UIKit
import os.log

// # have to subclass NSObject and conform to NSCoding
class Meal: NSObject, NSCoding {
    
    
    //MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    
    //MARK: Types
    // # this code will be used to store data
    struct PropertyKey{
        // # static means constants belong to structure and not instances of structure ~ access these constants using structure's name
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
    }
    
    //MARK: Initialization
    
    init?(name: String, photo: UIImage?, rating: Int){
        
        // The name must not be empty
        // guard declares condition that must be true in order for following code to execute. if condition is false, "else branch must exist the current code block" - tutorial 5
        guard  !name.isEmpty else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else{
            return nil
        }
        
        // Initialize stored properties
        self.name = name
        self.photo = photo
        self.rating = rating
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder){
        // # any class that adopts NSCoding needs this so that instances of the class can be encoded - tutorial 9
        // # this method prepares the class's information to be archived - tutorial 9
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(rating, forKey: PropertyKey.rating)
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        // # any class that adopts NSCoding needs this so that instances of the class can be decoded - tutorial 9
        // # this method unarchives data when class is created
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Meal, just use the conditional cast
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        
        // must call designated initializer
        self.init(name:name, photo:photo, rating: rating)
        
    }
}
