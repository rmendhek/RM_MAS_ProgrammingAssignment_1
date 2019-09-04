//
//  WhatToEatViewController.swift
//  FoodTracker
//
//  Created by Rishma Mendhekar on 9/3/19.
//

import UIKit
import FirebaseDatabase

class WhatToEatViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var randomMealLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Actions
    @IBAction func setMealText(_ sender: UIButton) {
        
        // ###### Firebase code ######
        // This code pulls a random meal from the database to display to the user.
        // This code inspired by the following tutorial: https://www.youtube.com/watch?v=JV9Oqyle3iE&t=637s
        // And used the following stack overflow references:
        // https://stackoverflow.com/questions/24161336/convert-int-to-string-in-swift
        // https://developer.apple.com/documentation/swift/int/2995648-random
        // https://stackoverflow.com/questions/24180346/append-string-in-swift
        
        // create a database reference
        let ref = Database.database().reference()
        // get the current meal count and add one
        ref.child("count").observeSingleEvent(of: .value) { (snapshot) in
            let count = snapshot.value as! Int
            print("ok here's how many random meals you can choose from:")
            print(count as Any)
            // choose a random int to display
            let randomEntry = String(Int.random(in: 1..<count+1))
            print(randomEntry)
            
            // update the count in the database
            ref.child("count").setValue(count)
            
            // call the entry from the random value and display the random meal name
            let path = "/name"
            let getRandomEntry = randomEntry + path
            let exclamation = "!"
            print(getRandomEntry)
            ref.child(getRandomEntry).observeSingleEvent(of: .value) {
                (snapshot) in
                let randomMeal = snapshot.value as! String
                let mealRec = randomMeal + exclamation
                self.randomMealLabel.text = mealRec
            }
            
        }
    }
    

}
