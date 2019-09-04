//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Rishma Mendhekar on 8/28/19.
// using the following tutorials:
// xcode/swift UI tutorial 1: https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/BuildABasicUI.html
// xcode/swift UI tutorial 2: https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/ConnectTheUIToCode.html#//apple_ref/doc/uid/TP40015214-CH22-SW1
// xcode/swift UI tutorial 3: https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/ConnectTheUIToCode.html#//apple_ref/doc/uid/TP40015214-CH22-SW1
// xcode/swift UI tutorial 8: https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/ImplementNavigation.html#//apple_ref/doc/uid/TP40015214-CH16-SW1


import UIKit
// # import unified logging system to send msgs to console
import os.log
import FirebaseDatabase

// have to add UITextFieldDelegate in order to process user input from text box (tutorial 2)
// UIImagePickerControllerDelegate and UINavigationControllerDelegate were added to allow interaction with the image (tutorial 3)
class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    // # these outlets connect to interface elements

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
 
     This value is either passed by 'MealTableViewController' in 'prepare(for:sender:)'
     or constructed as part of adding a new meal.
     # This is an optional Meal, may be nil at any time. Only want to configure and pass the meal if the Save btn was tapped.
    */
    var meal: Meal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Handle the text field's user input through delegate callbacks.
        // "self refers to ViewController class bc it is referenced inside scope of ViewController class def" - tutorial 2
        nameTextField.delegate = self
        
        // Set up views of editing an existing meal
        // # " If the meal property is non-nil, set each of the views in MealViewController to display data from the meal property. the meal property will only be non-nil when an existing meal is being edited " - tutorial 8
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
        }
        
        // Enable save button only if text field has a valid meal name
        updateSaveButtonState()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard and make the text field resign as first responder
        textField.resignFirstResponder()
        // "returns boolean val that indicates whether the system should process the press of the Return key" - tutorial 2
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the save button while editing
        // # it is very convenient that functions like this and textFieldDidEndEditing exist
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // changes the label above the text field to whatever was in the text field when user hit "return"
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        //Dismiss the picker if the user selects "cancel"
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{
            fatalError("Expected a dictionary containing an image, but was provided the folowing: \(info)")
        }
        
        // Set photoImageView to display the selected image
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // depending on the style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        // # creates boolean which indicates whether view controller that is presenting the scene is UINavController ==> meal detail scene is presented by the user tapping the Add button ==> bc meal detail scene is embedded in own nav controller when it is called/presented this way - tutorial 8
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            // # dismiss the modal scene with animated transition - tutorial 7
            // # no data is stored
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            // # else block called if existing meal is being edited ==> means that meal detail scene was pushed onto a navigation stack when user selected meal from meal list - tutorial 8
            // # popViewController pops current view controller (meal detail scene) off nav stack and animates transition - tutorial 8
            owningNavigationController.popViewController(animated: true)
        } else{
            // # only executes if meal detail scene was not presented in modal nav and if it was not pushed onto nav stack. this should never execute if code is set up correctly
            fatalError("The MealViewController is not inside a navigation controller")
        }
        
        
    }

    
    // This method lets you configure a view controller before it is presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        // # "call to superclass's implementation. good habit to call this line when you override prepare(for:sender:) so you don't orget it when you subclass a different class" - tutorial 7
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        // # "verifies that sender is a button and uses identity operator to check that objects referenced by the sender and the saveButton outlet are the same" - tutorial 7
        guard let button = sender as? UIBarButtonItem, button === saveButton else{
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        // Set the meal to be passed to the MealTableViewController after the unwind segue.
        meal = Meal(name: name, photo: photo, rating: rating)
        
    
            
        // ###### Firebase code ######
        // This code adds the meal that the user has entered into the database. It also keeps track of the number of entries in the database, which is used in the Random Meal Generator.
        // This code inspired by the following tutorial: https://www.youtube.com/watch?v=JV9Oqyle3iE&t=637s
        // And used the following stack overflow references:
        // https://stackoverflow.com/questions/24161336/convert-int-to-string-in-swift
        // https://developer.apple.com/documentation/swift/int/2995648-random
        // https://stackoverflow.com/questions/24180346/append-string-in-swift
        
        // STEP 1: create a database reference
        let ref = Database.database().reference()
        // STEP 2: get the current meal count and add one
        ref.child("count").observeSingleEvent(of: .value) { (snapshot) in
            let count = snapshot.value as! Int
            let newCount = count + 1
            print("ok here's the count:")
            print(newCount as Any)
            
            // STEP 3: update the count in the database
            ref.child("count").setValue(newCount)
            
            // STEP 4: use new count as the key for the next meal entry
            let stringNewCount = String(newCount)
            ref.child(stringNewCount).setValue(["name":name, "rating":rating])
                
        }
        
        
    }
    
    // MARK: Actions
    // created fn by control-dragging tap gesture from scene dock above main storyboard
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard if user taps image view while typing in text field
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo lib
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        // sets the place where image picker controller gets its images --> user's camera roll
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image (applies for next 2 lines of code)
        // "self refers to ViewController class bc it is referenced inside scope of ViewController class def" - tutorial 2
        imagePickerController.delegate = self
        
        // present(_:animated:completion:) is method being called on ViewController
        // asks ViewController to present view controller defined by imagePickerController
        // animated: true passes animates view of image picker controller
        // because we dont need to do anything else, don't need a completion handler, so completion: nil
        present(imagePickerController, animated: true, completion: nil)
        
        
    }
    
    //MARK: Private methods
    private func updateSaveButtonState(){
        //Disable the save button if the text field is empty
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
}

