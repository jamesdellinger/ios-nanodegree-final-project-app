//
//  RecipeCollectionViewController.swift
//  I Can Cook
//
//  Created by James Dellinger on 12/6/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RecipeCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    // MARK: Recipe Fetched Results Controller
    
    lazy var recipeFetchedResultsController: NSFetchedResultsController<Recipe> = { () -> NSFetchedResultsController<Recipe> in
        
        let recipeFetchRequest = NSFetchRequest<Recipe>(entityName: "Recipe")
        recipeFetchRequest.sortDescriptors = []
        
        let recipeFetchedResultsController = NSFetchedResultsController(fetchRequest: recipeFetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        recipeFetchedResultsController.delegate = self
        
        return recipeFetchedResultsController
    }()
    
    // MARK: Core data shared managed object context
    
    var sharedContext = CoreDataStack.sharedInstance().managedObjectContext
    
    // MARK: Properties
    
    // Keep track of collection cell insertions, and deletions.
    var insertedCellIndexPaths: [IndexPath]!
    var deletedCellIndexPaths: [IndexPath]!
    
    // MARK: Outlets
    
    // Collection view
    @IBOutlet weak var collectionView: UICollectionView!
    // Collection View Flow Layout outlet
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    // Outlets for label and arrow image shown when collection view
    // has zero recipes displayed.
    @IBOutlet weak var emptyCollectionImageView: UIImageView!
    @IBOutlet weak var emptyCollectionLabel: UILabel!
    @IBOutlet weak var emptyCollectionStackView: UIStackView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch saved recipes from core data.
        performRecipeFetchRequest(recipeFetchedResultsController)
        
        // Get collection flow layout collection view controller first loads
        if UIDevice.current.orientation.isPortrait {
            setCollectionFlowLayout("Portrait")
        } else {
            setCollectionFlowLayout("Landscape")
        }
        
        // Configure the image and text that will be displayed if user hasn't saved
        // any recipes yet.
        configureEmptyCollectionImageAndText()
        
        // Reveal the empty collection imageview and label if there are no saved recipes.
        // Indicates to users they can add a recipe by tapping the "+" button in the
        // upper right-hand corner.
        if recipeFetchedResultsController.fetchedObjects?.count == 0 {
            collectionView.addSubview(emptyCollectionStackView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        // Determine whether or not user has saved any recipes
        performRecipeFetchRequest(recipeFetchedResultsController)
        
        // Remove the empty collection imageview and label if and only if they are
        // being displayed next time user arrives back at this screen, and if user has
        // one or more recipes saved.
        if let recipes = recipeFetchedResultsController.fetchedObjects, let emptyCollectionStackView = emptyCollectionStackView, recipes.count > 0 {
            emptyCollectionStackView.removeFromSuperview()
        }
    }
    
    // Update collection flow layout if device orientation changes while
    // collection view is still visible.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Use a closure so that current orientation is detected only
        // after orientation has completed its change
        coordinator.animate(alongsideTransition: nil) { _ in
            if UIDevice.current.orientation.isPortrait {
                self.setCollectionFlowLayout("Portrait")
            } else {
                self.setCollectionFlowLayout("Landscape")
            }
        }
    }
    
    // Configure the image and text that will be displayed if user hasn't saved
    // any recipes yet.
    func configureEmptyCollectionImageAndText() {
        // Image that will appear if no recipes have been saved.
        emptyCollectionImageView.image = #imageLiteral(resourceName: "blue_chalk_arrow")
        
        // Text string that will be displayed in label if no recipes have been saved.
        let labelText: String = "Add your first recipe!"
        
        // Label text attributes dictionary
        let labelTextAttributes: [NSAttributedStringKey:Any] = [
            NSAttributedStringKey.foregroundColor: UIColor.init(red: 0.0/255.0, green: 151.0/255.0, blue: 255.0/255.0, alpha: 1.0),
            NSAttributedStringKey.font: UIFont(name: "Chalkduster", size: 20.0)!
        ]
        
         // Apply desired formatting to the label text.
        let attributedLabelText = NSAttributedString(string: labelText, attributes: labelTextAttributes)
        emptyCollectionLabel.attributedText = attributedLabelText
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

// MARK: UICollectionViewDelegate

extension RecipeCollectionViewController {
    
    // MARK: Defining the collection view flow layout
    
    // Call this function from viewDidLoad to get initial flow layout for
    // collection. Also called from closure of viewWillTransition() method to
    // get an updated flow layout when orientation changes from portrait to landscape,
    // or vice-versa.
    func setCollectionFlowLayout(_ currentDeviceOrientation: String) {
        
        let space: CGFloat = 3.0
        
        var dimension: CGFloat { get {
            if currentDeviceOrientation == "Portrait" {
                // Keeps column spacing uniform if device is in portrait orientation
                return (view.frame.size.width - (2 * space)) / 3.0
            } else  {
                // Keeps column spacing uniform if device is in landscape orientation
                return (view.frame.size.width - (4 * space)) / 5.0
            }}
        }
        
        flowLayout?.minimumInteritemSpacing = space
        flowLayout?.minimumLineSpacing = space
        flowLayout?.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    // MARK: Return the number of cells
    
    // Get the number of cells (recipes) that will appear in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let fetchedRecipes = recipeFetchedResultsController.fetchedObjects {
            return fetchedRecipes.count
        } else {
            return 0
        }
    }
    
    // MARK: Display cells
    
    // Dequeue cells as they are displayed in the meme collection view controller
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // The cell to be dequeued
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCollectionViewCell", for: indexPath) as! RecipeCollectionViewCell
        
        // Display the placeholder image in the cell, which will remain visible until the photo
        // that exists at the URL is loaded.
        cell.collectionCellImageView?.image = #imageLiteral(resourceName: "collectionCellPlaceholder")
        
        // If there are one or more saved recipes.
        if let fetchedRecipes = recipeFetchedResultsController.fetchedObjects {
            
            // The recipe whose image and title will be displayed in a particular cell.
            let recipeForCell = fetchedRecipes[(indexPath as NSIndexPath).item]
            
            // If the cell's recipe has a photo saved, display that photo in the cell's imageview.
            if let recipePhotoForCell = recipeForCell.photo {
                cell.collectionCellImageView?.image = UIImage(data: recipePhotoForCell as Data)
            }
            
            // Also set the recipe's title as the cell's label text
            if let recipeTitleForCell = recipeForCell.title {
                
                // Set the cell label's text and apply formatting attributes to it.
                let labelText: String = recipeTitleForCell
                let attributedLabelText = configureCellLabelTextAttributes(labelText: labelText)
                
                // Display the cell's label
                cell.collectionCellLabel?.attributedText = attributedLabelText
            }
        }
        
        return cell
    }
    
    // Configure attributes of each cell's label text
    func configureCellLabelTextAttributes(labelText: String) -> NSAttributedString {
        
        // Text attributes dictionary
        let labelTextAttributes: [NSAttributedStringKey:Any] = [
            NSAttributedStringKey.strokeColor: UIColor.black,
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16),
            NSAttributedStringKey.strokeWidth: -2.0
        ]
        
        let attributedLabelText = NSAttributedString(string: labelText, attributes: labelTextAttributes)
        
        // Return the attributed text string for the cell's label.
        return attributedLabelText
    }
    
    // MARK: Selecting a recipe cell
    
    // Allow user to select one or more photos from a pin's collection of photos.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // If there are one or more saved recipes.
        if let fetchedRecipes = recipeFetchedResultsController.fetchedObjects {
            
            // The recipe that the user selected.
            let selectedRecipe = fetchedRecipes[(indexPath as NSIndexPath).item]
            
            // Get the location of the Recipe Details View Controller from the Storyboard
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "RecipeDetailsViewController") as! RecipeDetailsViewController
            
            // Set the Recipe property of the Recipe Details VC to the recipe that the user
            // selected here.
            controller.recipe = selectedRecipe
            
            // Set this view controller as the delegate for the RecipeDetailsViewControllerDelegate
            // protocol. Doing this ensures that this collection view refreshes whenever the
            // Recipe Details View Controller refreshes (as a result of one or more edits made
            // to a recipe). When user returns to this view controller, the cells displayed in
            // this collection view should reflect any and all recipe edits that a user made
            // while they were away.
            controller.delegate = self
            
            // Finally, push the recipe details view controller.
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: Fetched Results Controller Delegate

extension RecipeCollectionViewController {
    
    // The following three methods are invoked whenever changes are made to Core Data:
    
    // Creates two fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        // Start out with empty arrays for each change type (insert or delete).
        insertedCellIndexPaths = [IndexPath]()
        deletedCellIndexPaths = [IndexPath]()
    }
    
    // Keep track of everytime a Recipe object is added or deleted.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            // Tracking when a new Recipe object has been added to core data.
            insertedCellIndexPaths.append(newIndexPath!)
            break
        case .delete:
            // Tracking when a Recipe object has been deleted from Core Data.
            deletedCellIndexPaths.append(indexPath!)
            break
        default:
            break
        }
    }
    
    // Invoked after all of the changed objects in the current batch have been collected
    // into the two index path arrays (insert,  or delete).
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        // Loop through the arrays and perform the changes in one fell swoop (as a batch).
        collectionView.performBatchUpdates({() -> Void in
            for indexPath in self.insertedCellIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            for indexPath in self.deletedCellIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
        }, completion: nil)
    }
}

// MARK: RecipeDetailsViewControllerDelegate

extension RecipeCollectionViewController: RecipeDetailsViewControllerDelegate {
    func refresh(editedRecipe: Recipe) {
        
        // Fetch the latest from Core Data.
        performRecipeFetchRequest(recipeFetchedResultsController)
        
        // Get the index of the cell whose recipe was edited
        if let index = recipeFetchedResultsController.fetchedObjects?.index(of: editedRecipe){
            performUIUpdatesOnMain {
                // Refresh the cell at this index. If a new picture was added, or if
                // the recipe's title was changed, the cell will now reflect these
                // changes as well.
                self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        }
    }
}
