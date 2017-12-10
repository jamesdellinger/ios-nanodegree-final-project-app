//
//  RecipeDetailsViewController.swift
//  I Can Cook
//
//  Created by James Dellinger on 12/7/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation
import UIKit

protocol RecipeDetailsViewControllerDelegate: class {
    func refresh(editedRecipe: Recipe)
}

class RecipeDetailsViewController: UIViewController {
    
    // MARK: Properties
    
    var recipe: Recipe?
    
    // Delegate property for the RecipeDetailsViewControllerDelegate protocol.
    weak var delegate: RecipeDetailsViewControllerDelegate? = nil
    
    // MARK: Outlets
    
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var ingredientsTextView: UITextView!
    @IBOutlet weak var directionsTextView: UITextView!
    @IBOutlet weak var navbarTitle: UINavigationItem!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate the view controller's UI with all the recipe's details.
        if let recipe = recipe {
            displayRecipeAttributes(recipe: recipe)
        }
    }
    
    func displayRecipeAttributes(recipe: Recipe) {
        if let recipeTitle = recipe.title {
            navbarTitle.title = recipeTitle
        }
        
        if let recipePhoto = recipe.photo {
            recipeImageView.image = UIImage.init(data: recipePhoto as Data)
        }
        
        if let recipeIngredients = recipe.ingredients {
            ingredientsTextView.text = recipeIngredients
        }
        
        if let recipeDirections = recipe.directions {
            directionsTextView.text = recipeDirections
        }
    }
    
    // MARK: Edit recipe
    
    // When user taps the edit button, modally present the Add Recipe View Controller.
    // This segue's identifier in storyboard is "ShowAddRecipeViewController"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAddRecipeViewController" {
            let destinationController = segue.destination as! AddRecipeViewController
            
            // Set the Recipe property of the Add Recipe VC to the recipe that the user
            // selected here.
            destinationController.recipe = recipe
            
            // Set this (Recipe Details) view controller as the destination controller's
            // delegate. We need to do this in order to this view controller to be able
            // to display refreshed recipe attributes when the user returns here after
            // editing the recipe in the (modally presented) Add Recipe View Controller.
            destinationController.delegate = self
        }
    }
}

extension RecipeDetailsViewController: AddRecipeViewControllerDelegate {
    func dismissAndRefresh(editedRecipe: Recipe) {
        // Dismiss the presented Add Recipe View Controller
        dismiss(animated: true, completion: nil)
        // Make sure this presenting view controller (Recipe Details View Controller)
        // displays the attributes that reflect any and all edits that the user made.
        displayRecipeAttributes(recipe: editedRecipe)
        
        // Also ensure that the collection view in the Recipe Collection View Controller is refreshed
        delegate?.refresh(editedRecipe: editedRecipe)
    }
}
