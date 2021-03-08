//
//  CustomKeyboardHelper.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-03-08.
//

import Foundation
import UIKit

@objc protocol CustomKeyboardHelper{
    @objc func keyWillHide()
    @objc func keyboardWillShow(notification: NSNotification)
}

extension CustomKeyboardHelper{
    func hideCustomKeyboard(mainStackTopConstraint:NSLayoutConstraint,view:UIView){
        // Remove listening the first responder
        view.endEditing(true)
        
        UIView.animate(withDuration: 0.50, animations: {
            // Putting the view back to previous state
            mainStackTopConstraint.constant = CustomKeyboardDefaults.topConstraintDefaultHeight
            view.layoutIfNeeded()
        })
    }
    
    func showCustomKeyboard(activeInputTextField:UITextField,notification: NSNotification,screenMainStackView: UIStackView,screenScrollView: UIScrollView,mainStackTopConstraint: NSLayoutConstraint,view:UIView)  {
        
        //activeInputTextField = responder as! UITextField
        
        var activeInputTextFieldSuperView = activeInputTextField.superview!
        if activeInputTextField.tag == 5 || activeInputTextField.tag == 6{
            activeInputTextFieldSuperView = activeInputTextField.superview!.superview!
        }
        
        if let info = notification.userInfo{
            let keyboard:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            
            let targetY = view.frame.size.height - keyboard.height - 15 - activeInputTextField.frame.size.height
            
            let initialY = screenMainStackView.frame.origin.y + activeInputTextFieldSuperView.frame.origin.y + activeInputTextField.frame.origin.y
            
            
            if initialY > targetY {
                let diff = targetY - initialY
                let targetOffsetForTopConstraint = mainStackTopConstraint.constant + diff
                view.layoutIfNeeded()
                
                UIView.animate(withDuration: 0.25, animations: {
                    mainStackTopConstraint.constant = targetOffsetForTopConstraint
                    view.layoutIfNeeded()
                })
            }
            
            var contentInset:UIEdgeInsets = screenScrollView.contentInset
            contentInset.bottom = keyboard.size.height
            screenScrollView.contentInset = contentInset
        }
        
    }
}
