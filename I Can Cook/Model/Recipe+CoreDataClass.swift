//
//  Recipe+CoreDataClass.swift
//  I Can Cook
//
//  Created by James Dellinger on 12/7/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Recipe)
public class Recipe: NSManagedObject {
    
    convenience init(title: String, ingredients: String, directions: String, photo: NSData, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Recipe", in: context) {
            self.init(entity: entity, insertInto: context)
            self.title = title
            self.ingredients = ingredients
            self.directions = directions
            self.photo = photo
        } else {
            fatalError("Unable to find entity name!")
        }
    }

}
