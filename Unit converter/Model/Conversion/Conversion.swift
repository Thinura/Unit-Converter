//
//  Conversion.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-18.
//

import Foundation
import UIKit

/**
  This is used to render the cell in the conversion main screen.
    - Parameters:
            name - conversion name
            icon - image of the conversion
            segueIdentifier - segue identifier in storyboard
*/

class Conversion {
    let name: String
    let icon: UIImage
    let segueIdentifier: String
    
    init(name: String, icon: UIImage, segueIdentifier: String) {
        self.name = name
        self.icon = icon
        self.segueIdentifier = segueIdentifier
    }
    
    func getConversionName() -> String {
        return name
    }
    
    func getConversionIcon() -> UIImage {
        return icon
    }
    
    func getSegueIdentifier() -> String {
        return segueIdentifier
    }
    
}
