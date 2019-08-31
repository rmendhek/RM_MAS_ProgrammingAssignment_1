//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Rishma Mendhekar on 8/30/19.
// Created using tutorial 6: https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/CreateATableView.html#//apple_ref/doc/uid/TP40015214-CH8-SW1
// Created using tutorial 7: https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/ImplementNavigation.html#//apple_ref/doc/uid/TP40015214-CH16-SW1
// Created using tutorial 8: https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/ImplementEditAndDeleteBehavior.html#//apple_ref/doc/uid/TP40015214-CH9-SW1
// Created using tutorial 9: https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/PersistData.html#//apple_ref/doc/uid/TP40015214-CH14-SW1
// Debugged using stack overflow:  http://resolved-error.com/questions/53347426/ios-editor-bug-archiveddata-renamed

import UIKit
// sends msgs to console
import os.log

class MealTableViewController: UITableViewController {
    
    //MARK: Properties
    // # initializes property with empty array of Meal objects as default value
    var meals = [Meal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        let savedMeals = loadMeals()
        
        if savedMeals?.count ?? 0 > 0 {
            meals = savedMeals ?? [Meal]()
        } else {
            loadSampleMeals()
        }
    }
    
    /* BEFORE STACK OVERFLOW
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        // # creates bar button item that has editing behavior built into it, adds it onto the left side of nav bar in meal list scene - tutorial 8
        navigationItem.leftBarButtonItem = editButtonItem
        

        //Load the sample data.
        loadSampleMeals()
    } */

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // # table view data source method which supplies table view with data it needs to display
        // # "makes table view 1 section instead of 0" - tutorial 6
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // # table view data source method which supplies table view with data it needs to display
        // # "tells table view how many rows to display in a given section" - tutorial 6
        // # .count fn counts the number of objects in the meals array
        return meals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell else{
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let meal = meals[indexPath.row]
        

        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating

        return cell
    }
 

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            // # this is the only only line that has been added, otherwise just uncommented existing function
            // # removes Meal object to be deleted from meals array. tableView.deleteRows deletes display from table - tutorial 8
            meals.remove(at: indexPath.row)
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // if editing an existing meal, need to display meal's data in meal detail scene. first get destination view controller, selected meal cell, and index path of selected cell.
        
        switch(segue.identifier ?? ""){
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? MealTableViewCell else{
                fatalError("The selected cell is not being displayed by the table")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else{
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = meals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
        
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
            
        }
    }
    
    
    // MARK: Actions ~ tutorial 7
    @IBAction func unwindToMealList(sender: UIStoryboardSegue){
        // # segue's source view gets downcast to a MealViewController instance bc sender.sourceViewController is of type UIViewController and we need to work with a MealViewController
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal{
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                // # update meal array: replate old meal object with edited meal object
                meals[selectedIndexPath.row] = meal
                // reloads table view with updated meal data
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
            //Add a new meal. "computes the location in the table where the new table view cell representing the new meal will be inserted, and stores it in a local constant called the newIndexPath" - tutorial 7
            let newIndexPath = IndexPath(row: meals.count, section: 0)
            meals.append(meal)
            // # "animates the addition of a new row to the table view for the cell that contains info about the new meal." - tutorial 7 .automatic chooses best animation
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                
            }
            
            saveMeals()
        }
    }
    

    //MARK: Private Methods
    
    private func loadSampleMeals() {
        // # "helper method to load sample data into app" - tutorial 6
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        
        // # create 3 meal objects
        guard let meal1 = Meal(name: "Caprese Salad", photo: photo1, rating: 4) else{
            fatalError("Unable to instantiate meal1")
        }
        
        guard let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2, rating: 5) else {
            fatalError("Unable to instantiate meal2")
        }
        
        guard let meal3 = Meal(name: "Pasta with Meatballs", photo: photo3, rating: 3) else {
            fatalError("Unable to instantiate meal2")
        }
        
        // # add Meal objects to array after creation
        meals += [meal1, meal2, meal3]
    }
    
    private func saveMeals() {
        
        let fullPath = getDocumentsDirectory().appendingPathComponent("meals")
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: meals, requiringSecureCoding: false)
            try data.write(to: fullPath)
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } catch {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func loadMeals() -> [Meal]? {
        let fullPath = getDocumentsDirectory().appendingPathComponent("meals")
        if let nsData = NSData(contentsOf: fullPath) {
            do {
                
                let data = Data(referencing:nsData)
                
                if let loadedMeals = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Array<Meal> {
                    return loadedMeals
                }
            } catch {
                print("Couldn't read file.")
                return nil
            }
        }
        return nil
    }
    
  /* BEFORE STACK OVERFLOW   //MARK: Private Methods
    
    private func loadSampleMeals() {
        // # "helper method to load sample data into app" - tutorial 6
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        
        // # create 3 meal objects
        guard let meal1 = Meal(name: "Caprese Salad", photo: photo1, rating: 4) else{
            fatalError("Unable to instantiate meal1")
        }
        
        guard let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2, rating: 5) else {
            fatalError("Unable to instantiate meal2")
        }
        
        guard let meal3 = Meal(name: "Pasta with Meatballs", photo: photo3, rating: 3) else {
            fatalError("Unable to instantiate meal2")
        }
        
        // # add Meal objects to array after creation
        meals += [meal1, meal2, meal3]
    }
    
    private func saveMeals(){
        // # archives the meals array to specific location, returns true if it is successful - tutorial 9
        // # meal.archiveURL was defined in Meal class - tutorial 9
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Meals successfuly saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
        
    }
    
    private func loadMeals() -> [Meal]? {
        // # this method unarchives the poject stored at meal.archiveurl.path and downcasts it to an array of meal objects
        return NSKeyedUnarchiver.unarchivedObject(ofClasses: <#T##NSCoding.Protocol#>, from: Meal.ArchiveURL.path)
    }
 */
}
