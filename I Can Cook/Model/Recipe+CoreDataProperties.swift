//
//  Recipe+CoreDataProperties.swift
//  I Can Cook
//
//  Created by James Dellinger on 12/7/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//
//

import Foundation
import CoreData


extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var title: String?
    @NSManaged public var ingredients: String?
    @NSManaged public var directions: String?

}
