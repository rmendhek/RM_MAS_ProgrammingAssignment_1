//
//  FoodTrackerTests.swift
//  FoodTrackerTests
//
//  Created by Rishma Mendhekar on 8/28/19.
// This code based on tutorial 5: https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/DefineYourDataModel.html#//apple_ref/doc/uid/TP40015214-CH20-SW1

import XCTest
@testable import FoodTracker

class FoodTrackerTests: XCTestCase {

    //MARK: Meal Class Tests
    
    // Confirm that the Meal initializer returns a meal object when passed valid parameters.
    func testMealInitializationSucceeds(){
        // Zero rating
        let zeroRatingMeal = Meal.init(name:"Zero", photo: nil, rating: 0)
        // # XCTAssertNotNil verifies that returned Meal object is not nil
        XCTAssertNotNil(zeroRatingMeal)
        
        // Highest positive rating
        let positiveRatingMeal = Meal.init(name: "Positive", photo: nil, rating: 5)
        XCTAssertNotNil(positiveRatingMeal)
    }
    
    // Confirm that Meal initializer returns nil when passed a negative rating or an empty name.
    func testMealInitializationFails(){
        
        // Negative rating
        let negativeRatingMeal = Meal.init(name: "negative", photo: nil, rating: -1)
        XCTAssertNil(negativeRatingMeal)
        
        // Rating exceeds maximum
        let largeRatingMeal = Meal.init(name: "Large", photo: nil, rating: 6)
        XCTAssertNil(largeRatingMeal)
        
        // Empty string
        let emptyStringMeal = Meal.init(name: "", photo: nil, rating: 0)
        XCTAssertNil(emptyStringMeal)
        
    }
}
