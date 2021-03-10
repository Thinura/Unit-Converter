//
//  SpeedViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

class SpeedViewController: UIViewController, CustomKeyboardDelegate, ConversionHelper, CustomKeyboardHelper {
    
    /// Defaults
    var activeInputTextField = UITextField()
    var decimalDigit = DecimalSelector.defaultDecimalDigit
    
    /// Used for keyboard handling - When user pressed auto scroll will be enable
    @IBOutlet weak var speedMainStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var speedScreenScrollView: UIScrollView!
    @IBOutlet weak var speedScreenMainStackView: UIStackView!
    
    /// Text input fields
    @IBOutlet weak var metresSecondInputTextField: UITextField!
    @IBOutlet weak var kilometreHourInputTextField: UITextField!
    @IBOutlet weak var milesHourInputTextField: UITextField!
    @IBOutlet weak var knotInputTextField: UITextField!
    var speedInputTextFields:[UITextField] {
        return [metresSecondInputTextField, kilometreHourInputTextField, milesHourInputTextField, knotInputTextField ]
    }
    /// Stack views for input fields
    @IBOutlet weak var metresSecondStackView: UIStackView!
    @IBOutlet weak var kilometreHourStackView: UIStackView!
    @IBOutlet weak var milesHourStackView: UIStackView!
    @IBOutlet weak var knotStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding gesture recogniser listener
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
        for item in speedInputTextFields {
            item.initializeCustomKeyboard(delegate: self)
        }
        
        //Listening to keyboard show events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    /// This function read the decimal digit from user defaults
    func settingUpDecimal() {
        
        // Inililzing user default decimal digit
        self.decimalDigit = readingDecimalDigitInUserDefaults()
        
        if !activeInputTextField.text!.isEmpty {
            // Change according to the decimal digit but not active input field
            checkWhichTextFieldPressed(sender: activeInputTextField)
            
        }else{
            
            // Load last saved data
            loadLastConversion(inputFields: speedInputTextFields, conversionUserDefaultsKey:  UserDefaultsKeys.Speed.LAST_SPEED_CONVERSION_USER_DEFAULTS_KEY,conversionLastActiveTextFieldKey: UserDefaultsKeys.Speed.LAST_EDITED_FIELD_SPEED_CONVERSION_TAG_USER_DEFAULTS_KEY,rightBarButtonItem: self.navigationItem.rightBarButtonItem!)
            
        }
    }
    
    func checkWhichTextFieldPressed(sender:UITextField){
        var speedUnit: SpeedMeasurementUnit?
        
        speedUnit = getUnitByTag(tag: sender.tag, unitsArray: SpeedMeasurementUnit.getAvailableSpeedUnits)
        
        if speedUnit != nil {
            updateInputTextFields(textField: sender, unit: speedUnit!)
        }
    }
    
    /**
     This function will be called by the tap gesture recogniser and will hide the keyboard and restore the top constraint back to pervious view
     
     */
    @objc func keyWillHide(){
        hideCustomKeyboard(mainStackTopConstraint: self.speedMainStackTopConstraint,view: self.view)
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
            
            showCustomKeyboard(activeInputTextField: activeInputTextField, notification: notification, screenMainStackView: self.speedScreenMainStackView, screenScrollView: self.speedScreenScrollView, mainStackTopConstraint: self.speedMainStackTopConstraint, view: self.view)
        }
    }
    
    /// listening which input was typed
    @IBAction func handleInputTextField(_ sender: UITextField) {
        
        checkWhichTextFieldPressed(sender: sender)
        
        checkAvailabilityRightBarButtons(rightBarButtonItems:self.navigationItem.rightBarButtonItems!,inputFields: speedInputTextFields)
    }
    
    /**
     Method will update the other speed input fields
     
     -  Parameters: textField, speedUnit of the changed method
     
     */
    func updateInputTextFields<T: MeasurementUnit>(textField: UITextField, unit: T) -> Void{
        if let input = textField.text{
            if input.isEmpty{
                
                ///Clear the input text fields when its empty
                clearTextFields(inputTextFields: speedInputTextFields)
                checkAvailabilityRightBarButtons(rightBarButtonItems:self.navigationItem.rightBarButtonItems!,inputFields: speedInputTextFields)
            }else{
                
                if let value = Double(input as String){
                    let speed = Speed(unit: unit as! SpeedMeasurementUnit, value: value)
                    
                    for _unit in SpeedMeasurementUnit.getAvailableSpeedUnits{
                        if _unit == unit as! SpeedMeasurementUnit{
                            continue
                        }
                        let textField = mapUnitToTextField(unit: _unit)
                        let result = speed.convert(unit: _unit)
                        
                        // Rounding off to decimal digit
                        let roundedResult = result.truncate(places: self.decimalDigit)
                        
                        textField.text = String(roundedResult)
                    }
                }
            }
        }
    }
    
    /**
     This function maps value to speed unit respectively
     - Parameters: speedUnit of the speed that user input
     - Returns: Respective UITextField
     */
    func mapUnitToTextField<T: MeasurementUnit>(unit: T) -> UITextField {
        var textField = UITextField()
        
        for index in 1...SpeedMeasurementUnit.getAvailableSpeedUnits.count {
            let item = SpeedMeasurementUnit.getAvailableSpeedUnits[index-1]
            if unit as! SpeedMeasurementUnit == item {
                textField = speedInputTextFields[index-1]
                return textField
            }
            
        }
        return textField
    }
    
    /**
     This function handle the save buttons' functionality which only can be save 5 conversions
     */
    @IBAction func handleSaveButton(_ sender: UIBarButtonItem) {
        if !isInputTextFieldEmpty(inputFields: speedInputTextFields){
            let lastData = lastAddedData(inputFields: speedInputTextFields) as [String]
            
            let conversion = Speed.speedConversion(inputFields: speedInputTextFields) as String
            
            /// Getting initial history data
            var speedHistory = UserDefaults.standard.array(forKey: UserDefaultsKeys.Speed.SPEED_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            if (!checkConversionIsAlreadySaved(historyList: speedHistory, conversion: conversion)){
                
                /// Check whether there are maximum amount of speed conversions if so first value will be removed
                speedHistory = checkMaximumConversion(conversion: conversion, conversionKey: UserDefaultsKeys.Speed.LAST_SPEED_CONVERSION_USER_DEFAULTS_KEY, conversionsMaxCount: UserDefaultsKeys.Speed.SPEED_CONVERSIONS_USER_DEFAULTS_MAX_COUNT) as [String]
                
                /// Add last added conversion
                saveInUserDefaults(data: lastData, key: UserDefaultsKeys.Speed.LAST_SPEED_CONVERSION_USER_DEFAULTS_KEY)
                
                
                /// Saving data in user defaults
                saveInUserDefaults(data: speedHistory, key: UserDefaultsKeys.Speed.SPEED_CONVERSIONS_USER_DEFAULTS_KEY)
                
                /// Saving last active text field in user defaults
                saveInUserDefaults(data: activeInputTextField.tag, key: UserDefaultsKeys.Speed.LAST_EDITED_FIELD_SPEED_CONVERSION_TAG_USER_DEFAULTS_KEY)
                
                // Disabling the save button
                self.navigationItem.rightBarButtonItem!.isEnabled = false;
                
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: Alert.Success.title, message:Alert.Success.Speed.message)
                
            }else{
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: Alert.Warning.title, message: Alert.Warning.Speed.message)
            }
        }else{
            
            /// showAlert method is defined in the  UIViewControllerHelper
            showAlert(title: Alert.Error.title, message:Alert.Error.message)
            
        }
    }
    
    @IBAction func inputTextFieldsResetButton(_ sender: UIBarButtonItem) {
        
        inputTextFieldsClearButton(inputTextFields: speedInputTextFields, rightBarButtonItems: self.navigationItem.rightBarButtonItems!)
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

