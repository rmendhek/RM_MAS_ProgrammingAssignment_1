//
//  ViewController.swift
//  FoodTracker
//
//  Created by Rishma Mendhekar on 8/28/19.
// using the following tutorials:
// xcode/swift tutorial 1: https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/BuildABasicUI.html
// xcode/swift tutorial 2: https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/ConnectTheUIToCode.html#//apple_ref/doc/uid/TP40015214-CH22-SW1
// xcode/swift tutorial 3: https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/ConnectTheUIToCode.html#//apple_ref/doc/uid/TP40015214-CH22-SW1


import UIKit

// have to add UITextFieldDelegate in order to process user input from text box (tutorial 2)
// UIImagePickerControllerDelegate and UINavigationControllerDelegate were added to allow interaction with the image (tutorial 3)
class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Handle the text field's user input through delegate callbacks.
        // "self refers to ViewController class bc it is referenced inside scope of ViewController class def" - tutorial 2
        nameTextField.delegate = self
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard and make the text field resign as first responder
        textField.resignFirstResponder()
        // "returns boolean val that indicates whether the system should process the press of the Return key" - tutorial 2
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // changes the label above the text field to whatever was in the text field when user hit "return"
        mealNameLabel.text = textField.text
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
    
    @IBAction func setDefaultLabelText(_ sender: UIButton) {
        
        mealNameLabel.text = "Default Text"
    }
}

