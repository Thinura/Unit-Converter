//
//  UITextFieldHelper.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-27.
//

import UIKit

fileprivate var customKeyboardDelegate: CustomKeyboardDelegate? = nil

// MARK: This extension is used to combine UITextFields and custom keyboard
extension UITextField: CustomKeyboardDelegate{
    
    /** This function combine the text input field and custom keyboard
     - Parameter customKeyboardDelegate: the delegate of the custom keyboard
     */
    func initializeCustomKeyboard(delegate: CustomKeyboardDelegate?) {
        let customKeyboard = CustomKeyboard(frame: CGRect(x: 0, y: 0, width: 0, height: CustomKeyboardDefaults.defaultHeight))
        self.inputView = customKeyboard
        customKeyboardDelegate = delegate
        customKeyboard.delegate = self
    }
    
    /**
     This function handles the numeric key on clicks and inserts the
     corresponding numeric value to the text field text.
     - Parameter key: The numeric key pressed.
     */
    internal func customKeyboardNumericKeysHandle(key: Int) {
        self.insertText(String(key))
        customKeyboardDelegate?.customKeyboardNumericKeysHandle(key: key)
    }
    
    
    /// This function handles the backspace key press on click and remove the character from text fields.
    internal func customKeyboardBackspaceKeyHandle() {
        self.deleteBackward()
        customKeyboardDelegate?.customKeyboardBackspaceKeyHandle()
    }
    
    
    /**
     This function handles the symbol key press. It inserts the
     corresponding symbol to the text field text.
     
     - Parameter symbol: The symbol pressed.
     */
    internal func customKeyboardSymbolKeyHandle(symbol: String) {
        var currentText = String(self.text!)
        if !(currentText.contains("-")),symbol == "-"{
            
            // Clearing the current text
            self.text = ""
            // Adding "-" in front of the current text
            currentText.insert(contentsOf: "-", at:  (currentText.index(currentText.startIndex, offsetBy: 0)))
            // Initialising it to the current view
            self.insertText(currentText)
        }else if !(currentText.contains(".")),symbol == "."{
            self.insertText(symbol)
        }
        customKeyboardDelegate?.customKeyboardSymbolKeyHandle(symbol: symbol)
    }
    
    
    /**
     This function handles the minimus key on click. It invokes
     the customKeyboardMinimusKeyHandle() method in the customKeyboardDelegate.
     */
    internal func customKeyboardMinimusKeyHandle() {
        customKeyboardDelegate?.customKeyboardMinimusKeyHandle()
    }
    
}
