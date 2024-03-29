//
//  ConversionsHelper.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-03-06.
//

import Foundation
import UIKit
protocol MeasurementUnit {
}

protocol ConversionHelper {
    
    /// This function read the decimal digit from user defaults
    func settingUpDecimal()
    
    /**
     This function which input field is pressed and updating the other input fields
     - Parameter sender:UITextField
     */
    func checkWhichTextFieldPressed(sender:UITextField)
    
    func updateInputTextFields<T: MeasurementUnit>(textField: UITextField, unit: T)->Void
    
    func mapUnitToTextField<T: MeasurementUnit>(unit: T) -> UITextField
}

extension ConversionHelper{
    
    /**
     This function finds the first responder in a UIView
     - Parameter inView: The corresponding UIView.
     - Returns: A UIView or a subview will be returned.
     */
    func findResponder(inView view: UIView) -> UIView? {
        for subView in view.subviews{
            if subView.isFirstResponder{
                return subView
            }
            if let recursiveSubView = self.findResponder(inView: subView){
                return recursiveSubView
            }
        }
        return nil
    }
    
    /// Checking whether the input is field is empty if so save button needs to be disabled
    func checkAvailabilityRightBarButtons(rightBarButtonItems: [UIBarButtonItem],inputFields:[UITextField]) {
        
        let rightBarButtons = rightBarButtonItems.prefix(2)
        for button in rightBarButtons {
            if isInputTextFieldEmpty(inputFields:inputFields) {
                button.isEnabled = false
            }else{
                button.isEnabled = true
            }
        }
    }
    
    /**
     Method returns a boolean after checking whether input fields are empty or not
     
     - Returns: Boolean
     
     */
    func isInputTextFieldEmpty(inputFields: [UITextField]) -> Bool {
        for inputField in inputFields {
            if !(inputField.text?.isEmpty)! {
                return false
            }
        }
        return true
        
    }
    
    /// This function clears all the text fields
    func clearTextFields(inputTextFields:[UITextField]) {
        for textInputField in inputTextFields{
            textInputField.text = ""
        }
    }
    
    // Load last conversion from user defaults
    func loadLastConversion(inputFields:[UITextField],conversionUserDefaultsKey:String,conversionLastActiveTextFieldKey:String,rightBarButtonItem: UIBarButtonItem){
        /// Read from user defaults
        let lastSavedConversion = UserDefaults.standard.value(forKey: conversionUserDefaultsKey) as? [String]
        
        if lastSavedConversion?.count ?? 0 > 0 {
            
            // Setting the conversion to the input text fields
            for index in 1...inputFields.count {
                for inputField in inputFields {
                    if (inputField.tag == index) {
                        inputField.text = lastSavedConversion![index-1]
                    }
                    
                }
            }
            
            /// Reading from user defaults
            let lastActiveTag = UserDefaults.standard.value(forKey: conversionLastActiveTextFieldKey) as? NSInteger ?? 0
            
            let lastActiveTextField = getTextFieldByTag(tag: lastActiveTag, textFieldArray: inputFields)
            
            if lastActiveTextField != nil {
                checkWhichTextFieldPressed(sender: lastActiveTextField!)
                
                // Disabling the save button
                rightBarButtonItem.isEnabled = false;
            }
            
        }
        
        
        
    }
    
    /// Check whether there are maximum amount of weight conversions if so first value will be removed
    func checkMaximumConversion(conversion:String,conversionKey:String,conversionsMaxCount:Int) -> [String] {
        var history = UserDefaults.standard.array(forKey: conversionKey) as? [String] ?? []
        /// Check whether there are maximum amount of weight conversions if so first value will be removed
        if history.count >= conversionsMaxCount {
            history = Array(history.suffix(conversionsMaxCount - 1))
        }
        history.append(conversion)
        return history
    }
    
    // Save in user defaults by key and value
    func saveInUserDefaults(data:Any,key:String) {
        UserDefaults.standard.set(data, forKey: key)
    }
    
    // Checking with pervious conversions
    func checkConversionIsAlreadySaved(historyList:[String],conversion:String)->Bool{
        for historyListConversion in historyList {
            if (historyListConversion == conversion){
                return true
            }
        }
        return false
    }
    
    // Formatting the last added conversion to and [String] array
    func lastAddedData(inputFields:[UITextField])-> [String]{
        var lastAddData = [String]()
        for index in 1...inputFields.count {
            lastAddData.append(inputFields[index-1].text ?? "0")
        }
        return lastAddData
    }
    
    // Reading decimal digits
    func readingDecimalDigitInUserDefaults() -> Int{
        /// Reading from user defaults
        let userDefaultDecimalDigit = UserDefaults.standard.value(forKey: UserDefaultsKeys.Settings.DECIMAL_DIGIT_USER_DEFAULTS_KEY) as? NSString
        /// Default value will be set to 4 decimal points
        let decimal = ((userDefaultDecimalDigit ?? DecimalSelector.defaultDecimal as NSString) as NSString).integerValue
        return decimal
    }
    
    /**
     This function return the unit according to tag
     - Parameter tag: Int,
     - Parameter unitsArray: Array of the unit
     */
    func getUnitByTag<T: MeasurementUnit>(tag:Int, unitsArray:[T]) -> T? {
        var unit:T?
        for index in 1...unitsArray.count {
            /// Checking whether which input field is pressed
            if(tag == index){
                unit = unitsArray[index-1]
                return unit
            }
        }
        return unit
    }
    
    /**
     This function return the unit according to tag
     - Parameter tag: Int,
     - Parameter textFieldArray: Array of the input text fields
     */
    func getTextFieldByTag(tag:Int, textFieldArray:[UITextField]) -> UITextField? {
        var textField = UITextField()
        for index in 1...textFieldArray.count {
            /// Checking whether which input field is pressed
            if(tag == index){
                textField = textFieldArray[index-1]
                return textField
            }
        }
        return nil
    }
    
    /** This function delete text from all the text fields
     - Parameter inputTextFields : input text fields array
     - Parameter rightBarButtonItems : right navigation buttons
     */
    func inputTextFieldsClearButton(inputTextFields:[UITextField],rightBarButtonItems: [UIBarButtonItem]){
        if !isInputTextFieldEmpty(inputFields: inputTextFields){
            ///Clear the input text fields when its empty
            clearTextFields(inputTextFields: inputTextFields)
            checkAvailabilityRightBarButtons(rightBarButtonItems:rightBarButtonItems, inputFields: inputTextFields)
        }
    }
}
