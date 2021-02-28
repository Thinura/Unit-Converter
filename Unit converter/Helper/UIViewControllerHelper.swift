//
//  UIViewControllerHelper.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-27.
//

import UIKit

// MARK: This extension is used to hide keyboard and show alert if success any method
extension UIViewController{
    
    // This function hides the keyboard when tapped on the view
    func hideKeyboardOnClick() {
        self.view.addGestureRecognizer(self.checkEndEditing())
        self.navigationController?.navigationBar.addGestureRecognizer(self.checkEndEditing())
    }
    
    // This function dismisses the keyboard from view
    private func checkEndEditing()-> UIGestureRecognizer{
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap    }
    
    /**
     This function shows an alert with an action function
     - Parameters : message - message that needs to show in the alert box
     title - title that needs to show in the alert box
     */
    func showAlert(title: String, message: String) {
        
        /// Initialising success alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        /// Defining the alert action
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        /// Initialising alert to the view
        self.present(alert, animated: true, completion: nil)
    }
}

