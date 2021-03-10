//
//  UIColorHelper.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-28.
//

import UIKit

extension UIColor{
    
    // Keyboard Button default colour
    static var defaultKeyColor: UIColor {
        return UIColor { (traits) -> UIColor in
            // Return one of two colours depending on light or dark mode
            return traits.userInterfaceStyle == .dark ?
                // Dark mode colour
                UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1.00) :
                // Light mode colour
                UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1.00)
        }
    }
    
    // Keyboard button pressed colour
    static var pressedKeyColor: UIColor {
        return UIColor { (traits) -> UIColor in
            // Return one of two colours depending on light or dark mode
            return traits.userInterfaceStyle == .dark ?
                // Dark mode colour
                UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1.00)  :
                // Light mode colour
                UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1.00)
        }
    }
    
    static var dropDownBackground: UIColor {
        return UIColor(named: "SystemBackground") ?? .systemBackground
    }
    
    static var dropDownText: UIColor {
        return UIColor(named: "Custom") ?? .label
    }
    
}
