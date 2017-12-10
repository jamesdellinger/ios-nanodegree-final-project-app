//
//  AddToYourRecipesButton.swift
//  I Can Cook
//
//  Created by James Dellinger on 12/10/17.
//  Copyright © 2017 James Dellinger. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class AddToYourRecipesButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
}
