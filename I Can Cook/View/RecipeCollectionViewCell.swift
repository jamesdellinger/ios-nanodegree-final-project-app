//
//  RecipeCollectionViewCell.swift
//  I Can Cook
//
//  Created by James Dellinger on 12/6/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation
import UIKit

class RecipeCollectionViewCell: UICollectionViewCell {

    // MARK: Outlets
    
    // Imageview that displays a picture of the recipe's dish
    @IBOutlet weak var collectionCellImageView: UIImageView!
    
    // The title of the recipe
    @IBOutlet weak var collectionCellLabel: UILabel!
}
