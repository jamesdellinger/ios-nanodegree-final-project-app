//
//  AddRecipeViewController.swift
//  I Can Cook
//
//  Created by James Dellinger on 12/6/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol AddRecipeViewControllerDelegate: class {
    func dismissAndRefresh(editedRecipe: Recipe)
}

class AddRecipeViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Recipe Fetched Results Controller
    
    lazy var recipeFetchedResultsController: NSFetchedResultsController<Recipe> = { () -> NSFetchedResultsController<Recipe> in
        
        let recipeFetchRequest = NSFetchRequest<Recipe>(entityName: "Recipe")
        recipeFetchRequest.sortDescriptors = []
        
        // Retrieve from core data the recipe whose title is the same as
        // the recipe that the user has chosen to edit. If user is editing
        // a recipe, the recipe property won't be nil.
        if let title = recipe?.title {
            let predicate = NSPredicate(format: "title == %@", title)
            recipeFetchRequest.predicate = predicate
            
        } else if let title = recipeTitleTextField.text {
            // Otherwise, if the user is adding a new recipe, the recipe
            // property will be nil. However, we will need to search Core
            // Data to make sure that the user isn't trying to create a
            // new recipe that has the same title as a recipe they've
            // previously added. Setting the fetched results controller's
            // predicate as the title of the text in the text field
            // will allow us to check for this.
            
            let predicate = NSPredicate(format: "title == %@", title)
            recipeFetchRequest.predicate = predicate
        }
        
        let recipeFetchedResultsController = NSFetchedResultsController(fetchRequest: recipeFetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        recipeFetchedResultsController.delegate = self
        
        return recipeFetchedResultsController
    }()
    
    // MARK: Core data shared managed object context
    
    var sharedContext = CoreDataStack.sharedInstance().managedObjectContext
    
    // MARK: Properties
    
    // Textview placeholder text labels
    var ingredientsPlaceholderLabel: UILabel = UILabel()
    var directionsPlaceholderLabel: UILabel = UILabel()
    
    // Imageview placeholder text label
    var addRecipeImageViewPlaceholderLabel: UILabel = UILabel()
    
    // The tinted overlay that we will show underneath imageview placeholder text label.
    var tintedOverlay: UIView!
    
    // Gesture recognizer used to present imagepickercontroller when user taps inside
    // this view controller's imageview.
    var photoAddTapGesture: UIGestureRecognizer!
    
    // Gesture recognizer used to dismiss keyboard when user taps outside a textview.
    var keyboardDismissTapGesture: UIGestureRecognizer?
    
    // User's keyboard height:
    var keyboardHeight: CGFloat?
    
    // Recipe that user wants to edit (if this controller is being presented by the
    // Recipe Details VC).
    var recipe: Recipe?
    
    // Delegate property for the AddRecipeViewControllerDelegate protocol.
    weak var delegate: AddRecipeViewControllerDelegate? = nil
    
    // When user is adding a recipe that's based on a YouTube video (if this controller is
    // being presented by the YouTubeVideoViewController).
    var youtubeVideo: YoutubeVideo?
    
    // MARK: Outlets
    
    @IBOutlet weak var addRecipeImageView: UIImageView!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var directionsTextView: UITextView!
    @IBOutlet weak var recipeTitleTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the UI:
        
        // Display the placeholder image in the cell.
        addRecipeImageView.image = #imageLiteral(resourceName: "collectionCellPlaceholder")
        
        // Set the recipe title (top) text field delegate
        recipeTitleTextField.delegate = self
        
        // Ensure both text views display a thin gray border.
        ingredientsTextView.layer.borderWidth = 0.3
        ingredientsTextView.layer.borderColor = UIColor.black.cgColor
        directionsTextView.layer.borderWidth = 0.3
        directionsTextView.layer.borderColor = UIColor.black.cgColor
        
        // Set textview placeholder label text and format
        ingredientsTextView.delegate = self
        directionsTextView.delegate = self
        ingredientsPlaceholderLabel.text = "Tap here to enter your recipe's ingredients"
        directionsPlaceholderLabel.text = "Tap here to enter your recipe's steps"
        configureTextViewPlaceholderLabel(textView: ingredientsTextView, label: ingredientsPlaceholderLabel)
        configureTextViewPlaceholderLabel(textView: directionsTextView, label: directionsPlaceholderLabel)
        
        // Display a black tint and white text label over recipe photo (or its placeholder).
        // Will indicate to user that they can tap on the imageview to change to a different photo.
        configureImageViewTintedOverlayAndLabel()
        
        // Finally, add a tap gesture recognizer to the imageview. When user
        // taps on it, they will be prompted to add a new photo.
        configureAddPhotoGestureRecognizer()
        
        // If user is editing an existing recipe:
        
        if let recipe = recipe {
            
            // Fetch from core data the recipe that is being edited.
            performRecipeFetchRequest(recipeFetchedResultsController)
            
            // Populate this controller's views and fields with the recipe's attributes.
            // Also configure UI to reflect fact that the user is at this screen because
            // they're updating an existing recipe.
            configureUIForEditRecipe(recipe: recipe)
        }
        
        // If user is adding a recipe from a YouTube Video:
        
        if let youtubeVideo = youtubeVideo {
            // Set title textfield and imageview to YouTube video's title and high quality thumbnail
            // image, respectively.
            configureUIForAddRecipeFromYoutube(youtubeVideo: youtubeVideo)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Save button is only enabled when view appears if recipe already has a title
        if let recipeTitleText = recipeTitleTextField.text, recipeTitleText.count > 0 {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
        
        // When text is recipe title text field, the save button will
        // become enabled. Adding target to the text field here in order
        // to detect when this happens.
        recipeTitleTextField.addTarget(self, action: #selector(textFieldHasText), for: .editingChanged)
        
        // Subscribe to keyboard notifications
        subscribeToKeyboardNotifications()        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unsubscribe from keyboard notifications when view will disappear
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Dismiss without saving
    
    @IBAction func dismissWithoutSaving(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Add a photo
    
    @objc func addPhoto(tapGestureRecognizer: UITapGestureRecognizer) {

        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            // If device camera isn't available, take the user directly to the device's
            // photo library.
            self.presentImagePicker(sourceType: .photoLibrary)
        } else {
            // Create an action sheet
            let newPhotoActionSheet = UIAlertController(title: "Add a Photo", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            // Configure the "Take a Picture" action (opens device's camera)
            let takePicture = UIAlertAction(title: "Take a Picture", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                self.presentImagePicker(sourceType: .camera)
            })
            
            // Configure the "Choose from Album" action (opens device's photo album)
            let chooseFromExisting = UIAlertAction(title: "Choose from Album", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                self.presentImagePicker(sourceType: .photoLibrary)
            })
            
            // Configure the "Cancel" action
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            
            // Add each action to the action sheet
            newPhotoActionSheet.addAction(takePicture)
            newPhotoActionSheet.addAction(chooseFromExisting)
            newPhotoActionSheet.addAction(cancel)
            
            // Present the action sheet
            present(newPhotoActionSheet, animated: true, completion: nil)
        }
    }
    
    // MARK: Save the Recipe
    
    @IBAction func saveRecipe(_ sender: Any) {
        
        // Make sure keyboard is dimissed if it had been visible (user
        // had been editing the title text field) when user tapped "Save."
        recipeTitleTextField.resignFirstResponder()
        
        // If user came to this screen from either the Recipe Collection view, or
        // YouTube video view controllers, the user is trying to add a brand new
        // recipe. In the case of the former, the recipe property would be nil.
        // If the later is the case, the youtubeVideo property would not be nil.
        // If either is true, we are in a situation where we can't allow the user
        // to save a recipe with duplicate title to Core Data.
            
        if recipe == nil || youtubeVideo != nil {

            // Make sure that user isn't re-adding a recipe they've already
            // added before (ensure that all new recipes have unique titles).
            // If it's possible to fetch from Core Data a recipe that has the
            // same title as that which the user has already entered, then
            // display a pop-up alert informing user of this. And don't overwrite
            // the previously saved recipe.
            
            performRecipeFetchRequest(recipeFetchedResultsController)
     
            if let previouslySavedRecipeList = recipeFetchedResultsController.fetchedObjects, previouslySavedRecipeList.count > 0 {
                displayDuplicateRecipeAlert()
                
                // After displaying the pop-up alert, return, so that a duplicate
                // recipe is not saved to Core Data.
                return
            }
            
            // If the tite is unique, we can save this recipe. Make sure that
            // updates to Core Data happen on the main thread.
            self.sharedContext.performAndWait {
                // Create a new recipe object in Core Data
                let recipeToSave = Recipe(context: self.sharedContext)
                // Set the recipe's attributes in Core Data
                saveRecipeAttributes(recipeToUpdate: recipeToSave)
                // Save the context after the recipe has been created and all its attributes
                // have been added.
                CoreDataStack.sharedInstance().saveContext()
            }
            
            // Dismiss the view controller after creating and saving a
            // brand new recipe.
            dismiss(animated: true, completion: nil)
            
        } else {
            // Otherwise, the user came to this screen from the Recipe Detail View Controller, and
            // they are attempting to edit a recipe they have already saved.
            
            // Locate in Core Data the recipe that the user is editing.
            if let fetchedRecipeList = recipeFetchedResultsController.fetchedObjects {
                
                let editedRecipe = fetchedRecipeList[0]
                
                // Make sure that updates to Core Data happen on the main thread.
                self.sharedContext.performAndWait {
                    // Update the recipe's attributes in Core Data
                    saveRecipeAttributes(recipeToUpdate: editedRecipe)
                    // Save the context after the recipe's attributes
                    // have been updated.
                    CoreDataStack.sharedInstance().saveContext()
                }
                
                // When dismissing this controller after updating a recipe, user will be taken
                // back to recipe details view controller. Must ensure that attributes displayed
                // there reflect any and all edits that the user saved in this screen. The delegate
                // protocol defined above ensures that this will happen.
                delegate?.dismissAndRefresh(editedRecipe: editedRecipe)
            }
        }
    }
    
    // Save a recipe's title, photo, ingredients, and directions attributes to Core Data
    func saveRecipeAttributes(recipeToUpdate: Recipe) {
        // Add the title to the newly created Recipe object
        if let recipeTitle = recipeTitleTextField.text {
            recipeToUpdate.title = recipeTitle
        }
        
        // Add the photo, if it exists
        if let recipePhoto = addRecipeImageView.image {
            // First convert the UIImage to NSData for storage in Core Data
            let recipePhotoData = UIImagePNGRepresentation(recipePhoto) as NSData?
            recipeToUpdate.photo = recipePhotoData
        }
        
        // Add the ingredients, if any
        if let recipeIngredients = ingredientsTextView.text {
            recipeToUpdate.ingredients = recipeIngredients
        }
        
        // Add the directions, if any
        if let recipeDirections = directionsTextView.text {
            recipeToUpdate.directions = recipeDirections
        }
    }
    
    // MARK: Perform recipe fetch request
    
    func performRecipeFetchRequest(_ recipeFetchedResultsController: NSFetchedResultsController<Recipe>?) {
        if let recipeFetchedResultsController = recipeFetchedResultsController {
            var error: NSError?
            do {
                try recipeFetchedResultsController.performFetch()
            } catch let recipeFetchError as NSError {
                error = recipeFetchError
            }
            
            if let error = error {
                print("Error performing recipe fetch: \(error)")
            }
        }
    }
    
}

// MARK: Initial UI Config

extension AddRecipeViewController {
    
    // Configure the format of the textview placeholder text label
    func configureTextViewPlaceholderLabel(textView: UITextView, label: UILabel) {
        label.font = UIFont.systemFont(ofSize: (textView.font?.pointSize)!)
        label.sizeToFit()
        textView.addSubview(label)
        label.frame.origin = CGPoint(x: 5, y: (textView.font?.pointSize)! / 2)
        label.textColor = UIColor.init(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0)
    }
    
    // Configure the imageview tinted overlay
    func configureImageViewTintedOverlayAndLabel() {
        // Force the view to layout
        self.view.layoutIfNeeded()
        // Configure black tinted overlay to cover imageview
        tintedOverlay = UIView(frame: addRecipeImageView.bounds)
        tintedOverlay?.alpha = 0.75
        tintedOverlay?.backgroundColor = UIColor.black
        // Add the overlay
        addRecipeImageView.addSubview(tintedOverlay)
        // Add the white text label
        configureImageViewPlaceholderLabel(imageView: addRecipeImageView, label: addRecipeImageViewPlaceholderLabel)
    }
    
    // Configure the format of the imageview placeholder text label.
    // (This label informs user they can tap on the imageview to add a
    // a new photo.)
    func configureImageViewPlaceholderLabel(imageView: UIImageView, label: UILabel) {
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Tap here to add a picture of your dish"
        label.sizeToFit()
        label.center = tintedOverlay.center
        // Add the white text label as a subview of the tinted overlay.
        tintedOverlay.addSubview(label)
    }
    
    // Add a tap gesture recognizer to the imageview so that user can tap it and
    // add a new photo.
    func configureAddPhotoGestureRecognizer() {
        photoAddTapGesture = UITapGestureRecognizer(target: self, action: #selector(addPhoto(tapGestureRecognizer:)))
        addRecipeImageView.isUserInteractionEnabled = true
        addRecipeImageView.addGestureRecognizer(photoAddTapGesture)
    }
}

// MARK: Config UI for editing existing recipe

extension AddRecipeViewController {
    
    func configureUIForEditRecipe(recipe: Recipe) {
        // Make navbar title text display as "Edit Recipe" (because user
        // is updating an existing recipe, rather than adding a brand new
        // one from scratch.
        navBarTitle.title = "Edit Recipe"
        
        if let recipeTitle = recipe.title {
            recipeTitleTextField.text = recipeTitle
        }
        
        if let recipePhoto = recipe.photo {
            addRecipeImageView.image = UIImage.init(data: recipePhoto as Data)
            // Change imageview text label to indicate that user can "update,"
            // rather than "add" a photo for their recipe.
            addRecipeImageViewPlaceholderLabel.text = "Tap to update your dish's picture"
        }
        
        if let recipeIngredients = recipe.ingredients {
            ingredientsTextView.text = recipeIngredients
            // Remove the textview's placeholder text
            ingredientsPlaceholderLabel.removeFromSuperview()
        }
        
        if let recipeDirections = recipe.directions {
            directionsTextView.text = recipeDirections
            // Remove the textview's placeholder text
            directionsPlaceholderLabel.removeFromSuperview()
        }
    }
}

// MARK: Configure UI for adding recipe from YouTube

extension AddRecipeViewController {
    
    func configureUIForAddRecipeFromYoutube(youtubeVideo: YoutubeVideo) {
        
        // Fill title text field with the title of the YouTube video
        recipeTitleTextField.text = youtubeVideo.title
        
        // Download the YouTube video's default quality thumbnail image and display
        // inside the cell's image view.
        let imageUrl = URL(string: youtubeVideo.highQualityThumbnailUrl)
        
        // Image downloading happens on the background thread.
        DispatchQueue.global(qos: .background).async {
            if let imageData = try? Data(contentsOf: imageUrl!) {
                
                // If image data downloaded successfully, conver to
                // a UIImage and display inside cell's imageview.
                performUIUpdatesOnMain {
                    self.addRecipeImageView.image = UIImage(data: imageData)
                    
                    // Since we are automatically filling the image view with the YouTube video's
                    // thumbnail image, we can remove the gray overlay and text overlay from the
                    // image view:
                    
                    // Remove the placeholder text overlay from the imageview
                    self.addRecipeImageViewPlaceholderLabel.removeFromSuperview()
                    
                    // And remove the dark tinted overlay covering the imageview
                    self.tintedOverlay.removeFromSuperview()
                }
            } else {
                print("Unable to download default quality thumbnail image for video \"\(youtubeVideo.title)\" from URL: \(imageUrl!)")
            }
        }
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension AddRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Present the proper image picker, depending on whether user chose
    // camera or photo library
    func presentImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // Place the image inside the imageview
            addRecipeImageView.image = image
        }
        
        // When controller is dismissed after an image has been selected:
        dismiss(animated: true, completion: {
            
            // Remove the placeholder text overlay from the imageview
            self.addRecipeImageViewPlaceholderLabel.removeFromSuperview()
            
            // And remove the dark tinted overlay covering the imageview
            self.tintedOverlay.removeFromSuperview()
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: UITextViewDelegate

extension AddRecipeViewController: UITextViewDelegate {
    
    // Solves corner case where user taps into one of the text views
    // directly from editing the top text field. If this happens, the
    // keyboard will already be visible and the screen position will not
    // raise (as it should whenever user begins editing one of the two
    // text views).
    func textViewDidBeginEditing(_ textView: UITextView) {
        if view.frame.origin.y >= 0 {
            if let keyboardHeight = keyboardHeight {
                view.frame.origin.y -= keyboardHeight
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        // Remove placeholder text from ingredients textview if user has entered text into it
        if textView == ingredientsTextView {
            ingredientsPlaceholderLabel.isHidden = !textView.text.isEmpty
        }
        
        // Remove placeholder text from directions textview if user has entered text into it
        if textView == directionsTextView {
            directionsPlaceholderLabel.isHidden = !textView.text.isEmpty
        }
    }
}

// MARK: UITextFieldDelegate

extension AddRecipeViewController: UITextFieldDelegate {
    
    // MARK: Check if textfield has text entered
    
    // Defining the selector that will be used to determine whether the
    // top text field has had text entered, and if the save button should
    // correspondingly be enabled.
    @objc func textFieldHasText(_ textField: UITextField) {
        // Making sure that text in text field doesn't begin with a space.
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let recipeTitleText = recipeTitleTextField.text, !recipeTitleText.isEmpty
            else {
                // If top text field is empty, save button is disabled
                self.saveButton.isEnabled = false
                return
        }
        // Enable save button if top text field not empty.
        saveButton.isEnabled = true
    }

    // Ensures keyboard is dismissed when user taps "Return" on soft
    // keyboard after having entered text into the top text field.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
}

// MARK: Methods to adjust the keyboard

extension AddRecipeViewController {
    
    func subscribeToKeyboardNotifications() {
        //Know when the keyboard will appear
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        //Know when the keyboard will hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    // When the keyboardWillShow notification is received, shift the view's frame up
    @objc func keyboardWillShow(_ notification:Notification) {
        
        // Update the keyboardHeight property to be the height of the user's
        // keyboard. Will need this value if user taps directly into one
        // of the text views from the top text field.
        keyboardHeight = getKeyboardHeight(notification)
        
        // We don't need to raise the view's position if the top text field is the first responder.
        if !recipeTitleTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
        // Editing in text fied or text view will begin, so must be initiated, so that we can
        // know when user taps outside of text field or text view (so we can know when keyboard
        // should be dismissed).
        if keyboardDismissTapGesture == nil {
            keyboardDismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:)))
            self.view.addGestureRecognizer(keyboardDismissTapGesture!)
        }
        
        // Remove gesture recognizer from this view controller's imageview whenever keyboard
        // is present. We don't want user to inadvertently load the imagepickercontroller
        // when they are just trying to dismiss the keyboard by tapping outside it.
        self.addRecipeImageView.removeGestureRecognizer(photoAddTapGesture)
    }
    
    // When keyboardWillHide notification is received, then
    // shift the view's frame back down
    @objc func keyboardWillHide(_ notification: Notification) {
        // We don't need to lower the view's position if the top text field was the first responder.
        if !recipeTitleTextField.isFirstResponder {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
        
        // Editing in text field or text view will end, so keyboardDismissTapGesture
        // can be disabled as well.
        if keyboardDismissTapGesture != nil {
            self.view.removeGestureRecognizer(keyboardDismissTapGesture!)
            keyboardDismissTapGesture = nil
        }
        
        // When the keyboard has been dismissed, we can add back the gesture recognizer
        // to this view controller's imageview. Tapping on the imageview will present
        // the imagepickercontroller only when the keyboard is not active.
        self.addRecipeImageView.addGestureRecognizer(photoAddTapGesture)
    }
    
    // Determine height of user's keyboard, so we know how much to raise, and then
    // lower the view
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // Resign first responder status for text field and both text views. Is called
    // when user taps outside of text field or text views.
    @objc func dismissKeyboard(sender: AnyObject) {
        ingredientsTextView.resignFirstResponder()
        directionsTextView.resignFirstResponder()
        recipeTitleTextField.resignFirstResponder()
    }
}

// MARK: Duplicate Existing Recipe Alert Popup

extension AddRecipeViewController {
    
    func displayDuplicateRecipeAlert() {
        
        let errorMessage = "You've already saved a recipe with this title."
        
        let alert = UIAlertController(title: "Duplicate Recipe", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            print("The \"Duplicate Recipe\" alert occured.")
        }))
        self.present(alert, animated: true, completion: {
            // Clear the recipe title text field, so user can enter
            // a unique title, if they desire.
            self.recipeTitleTextField.text = ""
        })
    }
}
