//
//  LengthViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

class LengthViewController:UIViewController, CustomKeyboardDelegate, ConversionHelper, CustomKeyboardHelper {
    
    /// Defaults
    var activeInputTextField = UITextField()
    var decimalDigit = DecimalSelector.defaultDecimalDigit
    
    /// Used for keyboard handling - When user pressed auto scroll will be enable
    @IBOutlet weak var lengthMainStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lengthScreenScrollView: UIScrollView!
    @IBOutlet weak var lengthScreenMainStackView: UIStackView!
    
    /// Text input fields
    @IBOutlet weak var millimetreInputTextField: UITextField!
    @IBOutlet weak var centimetreInputTextField: UITextField!
    @IBOutlet weak var inchInputTextField: UITextField!
    @IBOutlet weak var metreInputTextField: UITextField!
    @IBOutlet weak var kilometreInputTextField: UITextField!
    @IBOutlet weak var mileInputTextField: UITextField!
    @IBOutlet weak var yardInputTextField: UITextField!
    var lengthInputTextFields: [UITextField] {
        return [millimetreInputTextField, centimetreInputTextField, inchInputTextField, metreInputTextField, kilometreInputTextField, mileInputTextField, yardInputTextField]
    }
    
    /// Stack views for input fields
    @IBOutlet weak var millimetreStackView: UIStackView!
    @IBOutlet weak var centimetreStackView: UIStackView!
    @IBOutlet weak var inchStackView: UIStackView!
    @IBOutlet weak var metreStackView: UIStackView!
    @IBOutlet weak var kilometreStackView: UIStackView!
    @IBOutlet weak var mileStackView: UIStackView!
    @IBOutlet weak var yardStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(keyWillHide)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        settingUpCustomKeyboard()
        
        settingUpDecimal()
    }
    
    /// This function setting up the custom keyboard
    func settingUpCustomKeyboard() {
        
        // Setting up the custom keyboard with the text input fields
        for item in lengthInputTextFields {
            item.initializeCustomKeyboard(delegate: self)
        }
        
        //Listening to keyboard show events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    /// This function read the decimal digit from user defaults
    func settingUpDecimal() {
        /// Inililzing user default decimal digit
        self.decimalDigit = readingDecimalDigitInUserDefaults()
        
        if !activeInputTextField.text!.isEmpty {
            // Change according to the decimal digit but not active input field
            checkWhichTextFieldPressed(sender: activeInputTextField)
            
        }else{
            
            // Load last saved data
            loadLastConversion(inputFields: lengthInputTextFields, conversionUserDefaultsKey:  UserDefaultsKeys.Length.LAST_LENGTH_CONVERSION_USER_DEFAULTS_KEY,conversionLastActiveTextFieldKey: UserDefaultsKeys.Length.LAST_EDITED_FIELD_LENGTH_CONVERSION_TAG_USER_DEFAULTS_KEY,rightBarButtonItem: self.navigationItem.rightBarButtonItem!)
            
        }
    }
    
    /**
     This function which input field is pressed and updating the other input fields
     - Parameter sender:UITextField
     */
    func checkWhichTextFieldPressed(sender:UITextField){
        var lengthUnit: LengthMeasurementUnit?
        
        lengthUnit = getUnitByTag(tag: sender.tag, unitsArray: LengthMeasurementUnit.getAvailableLengthUnits)
        
        if lengthUnit != nil {
            updateInputTextFields(textField: sender, unit: lengthUnit!)
        }
    }
    
    /**
     This function will be called by the tap gesture recogniser and will hide the keyboard and restore the top constraint back to pervious view
     
     */
    @objc func keyWillHide(){
        hideCustomKeyboard(mainStackTopConstraint: self.lengthMainStackTopConstraint,view: self.view)
    }
    
    
    /**
     This function will recognise the responder and adjust respectively ui text field.
     The scroll will adjust accordingly.
     - Parameter NSNotification: notification object
     
     */
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let responder = self.findResponder(inView: self.view)
        
        if responder != nil{
            activeInputTextField = responder as! UITextField
            
            showCustomKeyboard(activeInputTextField: activeInputTextField, notification: notification, screenMainStackView: self.lengthScreenMainStackView, screenScrollView: self.lengthScreenScrollView, mainStackTopConstraint: self.lengthMainStackTopConstraint, view: self.view)
        }
    }
    
    /// listening which input was typed
    @IBAction func handleInputTextField(_ sender: UITextField) {
        
        checkWhichTextFieldPressed(sender: sender)
        checkAvailabilityRightBarButtons(rightBarButtonItems:self.navigationItem.rightBarButtonItems!,inputFields: lengthInputTextFields)
    }
    
    /**
     Method will update the other length input fields
     
     -  Parameters: textField, lengthUnit of the changed method
     
     */
    func updateInputTextFields<T: MeasurementUnit>(textField: UITextField, unit: T) -> Void{
        if let input = textField.text{
            if input.isEmpty{
                
                ///Clear the input text fields when its empty
                clearTextFields(inputTextFields: lengthInputTextFields)
                checkAvailabilityRightBarButtons(rightBarButtonItems:self.navigationItem.rightBarButtonItems!,inputFields: lengthInputTextFields)
            }else{
                if let value = Double(input as String){
                    let length = Length(unit: unit as! LengthMeasurementUnit, value: value)
                    
                    for _unit in LengthMeasurementUnit.getAvailableLengthUnits{
                        if _unit == unit as! LengthMeasurementUnit{
                            continue
                        }
                        let textField = mapUnitToTextField(unit: _unit)
                        let result = length.convert(unit: _unit)
                        
                        // Rounding off to decimal digit
                        let roundedResult = result.truncate(places: self.decimalDigit)
                        
                        textField.text = String(roundedResult)
                    }
                }
            }
        }
    }
    
    /**
     This function maps value to length unit respectively
     - Parameters: lengthUnit of the length that user input
     - Returns: Respective UITextField
     */
    func mapUnitToTextField<T: MeasurementUnit>(unit: T) -> UITextField {
        var textField = UITextField()
        
        for index in 1...LengthMeasurementUnit.getAvailableLengthUnits.count {
            let item = LengthMeasurementUnit.getAvailableLengthUnits[index-1]
            if unit as! LengthMeasurementUnit == item {
                textField = lengthInputTextFields[index-1]
                return textField
            }
            
        }
        return textField
    }
    
    /**
     This function handle the save buttons' functionality which only can be save 5 conversions
     */
    @IBAction func handleSaveButton(_ sender: UIBarButtonItem) {
        if !isInputTextFieldEmpty(inputFields: lengthInputTextFields){
            let lastAddData = lastAddedData(inputFields: lengthInputTextFields) as [String]
            
            let conversion = Length.lengthConversion(inputFields: lengthInputTextFields)
            
            /// Getting initial history data
            var lengthHistory = UserDefaults.standard.array(forKey: UserDefaultsKeys.Length.LENGTH_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            if (!checkConversionIsAlreadySaved(historyList: lengthHistory, conversion: conversion)){
                
                /// Check whether there are maximum amount of temperature conversions if so first value will be removed
                lengthHistory = checkMaximumConversion(conversion: conversion, conversionKey: UserDefaultsKeys.Length.LAST_LENGTH_CONVERSION_USER_DEFAULTS_KEY, conversionsMaxCount: UserDefaultsKeys.Length.LENGTH_CONVERSIONS_USER_DEFAULTS_MAX_COUNT) as [String]
                
                /// Add last added conversion
                saveInUserDefaults(data: lastAddData, key: UserDefaultsKeys.Length.LAST_LENGTH_CONVERSION_USER_DEFAULTS_KEY)
                
                /// Saving data in user defaults
                saveInUserDefaults(data: lengthHistory, key: UserDefaultsKeys.Length.LENGTH_CONVERSIONS_USER_DEFAULTS_KEY)
                
                /// Saving last active text field in user defaults
                saveInUserDefaults(data: activeInputTextField.tag, key: UserDefaultsKeys.Length.LAST_EDITED_FIELD_LENGTH_CONVERSION_TAG_USER_DEFAULTS_KEY)
                
                // Disabling the save button
                self.navigationItem.rightBarButtonItem!.isEnabled = false;
                
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: Alert.Success.title, message: Alert.Success.Length.message)
                
            }else{
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: Alert.Warning.title, message: Alert.Warning.Length.message)
            }
        }else{
            
            /// showAlert method is defined in the  UIViewControllerHelper
            showAlert(title: Alert.Error.title, message: Alert.Error.message)
            
        }
    }
    
    @IBAction func inputTextFieldsResetButton(_ sender: UIBarButtonItem) {
        
        inputTextFieldsClearButton(inputTextFields: lengthInputTextFields, rightBarButtonItems: self.navigationItem.rightBarButtonItems!)
    }
    
    /**
     This function will only trigger when custom keyboard in use
     - Parameter key:Int
     */
    func customKeyboardNumericKeysHandle(key: Int) {
        print("Number pressed is \(key)")
    }
    
    /**
     This function will only trigger when custom keyboard in use
     */
    func customKeyboardBackspaceKeyHandle() {
        print("Backspace is triggered.")
    }
    
    /**
     This function will only trigger when custom keyboard in use
     - Parameter symbol:String
     */
    func customKeyboardSymbolKeyHandle(symbol: String) {
        print("Symbol button triggered is \(symbol)")
    }
    
    /**
     This function will only trigger when custom keyboard in use and hide the keyboard
     */
    func customKeyboardMinimusKeyHandle() {
        print("Minimus button pressed.")
        keyWillHide()
    }
}
