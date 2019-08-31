//
//  Meal.swift
//  FoodTracker
//
//  Created by Rishma Mendhekar on 8/30/19.
//

import UIKit

class Meal {
    
    //MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    
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
    
}
