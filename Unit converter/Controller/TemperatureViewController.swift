//
//  TemperatureViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

class TemperatureViewController:UIViewController, CustomKeyboardDelegate, ConversionHelper, CustomKeyboardHelper  {
    
    /// Defaults
    var activeInputTextField = UITextField()
    var decimalDigit = DecimalSelector.defaultDecimalDigit
    
    /// Used for keyboard handling - When user pressed auto scroll will be enable
    @IBOutlet weak var temperatureMainStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var temperatureScreenScrollView: UIScrollView!
    @IBOutlet weak var temperatureScreenMainStackView: UIStackView!
    
    /// Text input fields
    @IBOutlet weak var celsiusInputTextField: UITextField!
    @IBOutlet weak var fahrenheitInputTextField: UITextField!
    @IBOutlet weak var kelvinInputTextField: UITextField!
    var temperatureInputTextFields: [UITextField] {
        return [celsiusInputTextField, fahrenheitInputTextField,kelvinInputTextField]
    }
    /// Stack views for input fields
    @IBOutlet weak var celsiusStackView: UIStackView!
    @IBOutlet weak var fahrenheitStackView: UIStackView!
    @IBOutlet weak var kelvinStackView: UIStackView!
    
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
        for item in temperatureInputTextFields {
            item.initializeCustomKeyboard(delegate: self)
        }
        
        //Listening to keyboard show events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // Notifying to Enable minus button
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableMinus"), object: nil)
        
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
            loadLastConversion(inputFields: temperatureInputTextFields, conversionUserDefaultsKey:  UserDefaultsKeys.Temperature.LAST_TEMPERATURE_CONVERSION_USER_DEFAULTS_KEY,conversionLastActiveTextFieldKey: UserDefaultsKeys.Temperature.LAST_EDITED_FIELD_TEMPERATURE_CONVERSION_TAG_USER_DEFAULTS_KEY,rightBarButtonItem: self.navigationItem.rightBarButtonItem!)
            
            
            
        }
    }
    
    /**
     This function which input field is pressed and updating the other input fields
     
     - Parameter sender:UITextField
     
     */
     func checkWhichTextFieldPressed(sender:UITextField){
        var temperatureUnit: TemperatureMeasurementUnit?
        
        temperatureUnit = getUnitByTag(tag: sender.tag, unitsArray: TemperatureMeasurementUnit.getAvailableTemperatureUnits)
        
        if temperatureUnit != nil {
            updateInputTextFields(textField: sender, unit: temperatureUnit!)
        }
    }
    
    /**
     This function will be called by the tap gesture recogniser and will hide the keyboard and restore the top constraint back to pervious view
     
     */
    @objc func keyWillHide(){
        hideCustomKeyboard(mainStackTopConstraint: self.temperatureMainStackTopConstraint,view: self.view)
    }
    
    
    /**
     This function will recognise the responder and adjust respectively ui text field.
     The scroll will adjust accordingly.
     
     - Parameter NSNotification: notification object
     
     */
    
     @objc func keyboardWillShow(notification: NSNotification) {
        let responder = findResponder(inView: self.view)
        
        if responder != nil{
            activeInputTextField = responder as! UITextField
            
            showCustomKeyboard(activeInputTextField: activeInputTextField, notification: notification, screenMainStackView: self.temperatureScreenMainStackView, screenScrollView: self.temperatureScreenScrollView, mainStackTopConstraint: self.temperatureMainStackTopConstraint, view: self.view)
        }
    }
    
    /// listening which input was typed
    @IBAction func handleInputTextField(_ sender: UITextField) {
        
        checkWhichTextFieldPressed(sender: sender)
        
        checkAvailabilityRightBarButtons(rightBarButtonItems:self.navigationItem.rightBarButtonItems!,inputFields: temperatureInputTextFields)
    }
    
    /**
     Method will update the other temperature input fields
     
     -  Parameters: textField, temperatureUnit of the changed method
     
     */
    func updateInputTextFields<T: MeasurementUnit>(textField: UITextField, unit: T)-> Void{
        if let input = textField.text{
            if input.isEmpty{
                
                ///Clear the input text fields when its empty
                clearTextFields(inputTextFields:temperatureInputTextFields)
                checkAvailabilityRightBarButtons(rightBarButtonItems:self.navigationItem.rightBarButtonItems!,inputFields: temperatureInputTextFields)
                
            }else{
                if let value = Double(input as String){
                    let temperature = Temperature(unit: unit as! TemperatureMeasurementUnit, value: value)
                    
                    for _unit in TemperatureMeasurementUnit.getAvailableTemperatureUnits{
                        if _unit == unit as! TemperatureMeasurementUnit{
                            continue
                        }
                        let textField = mapUnitToTextField(unit: _unit)
                        let result = temperature.convert(unit: _unit)
                        
                        // Rounding off to decimal digit
                        let roundedResult = result.truncate(places: self.decimalDigit)
                        
                        textField.text = String(roundedResult)
                    }
                }
            }
        }
    }
    
    /**
     This function maps value to temperature unit respectively
     - Parameters: temperatureUnit of the temperature that user input
     - Returns: Respective UITextField
     */
    func mapUnitToTextField<T: MeasurementUnit>(unit: T) -> UITextField {
        var textField = UITextField()
        for index in 1...TemperatureMeasurementUnit.getAvailableTemperatureUnits.count{
            let item = TemperatureMeasurementUnit.getAvailableTemperatureUnits[index-1]
            if unit as! TemperatureMeasurementUnit == item {
                textField = temperatureInputTextFields[index-1]
                return textField
            }
        }
        return textField
    }
    
    /**
     This function handle the save buttons' functionality which only can be save 5 conversions
     */
    @IBAction func handleSaveButton(_ sender: UIBarButtonItem) {
        if !isInputTextFieldEmpty(inputFields: temperatureInputTextFields){
            
            let lastAddData = lastAddedData(inputFields: temperatureInputTextFields) as [String]
            
            let conversion = Temperature.temperatureConversion(inputFields: temperatureInputTextFields)
            
            /// Getting initial history data
            var temperatureHistory = UserDefaults.standard.array(forKey: UserDefaultsKeys.Temperature.TEMPERATURE_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            if (!checkConversionIsAlreadySaved(historyList: temperatureHistory, conversion: conversion)){
                
                /// Check whether there are maximum amount of temperature conversions if so first value will be removed
                temperatureHistory = checkMaximumConversion(conversion: conversion, conversionKey: UserDefaultsKeys.Temperature.TEMPERATURE_CONVERSIONS_USER_DEFAULTS_KEY, conversionsMaxCount: UserDefaultsKeys.Temperature.TEMPERATURE_CONVERSIONS_USER_DEFAULTS_MAX_COUNT) as [String]
                
                /// Add last added conversion
                saveInUserDefaults(data: lastAddData, key: UserDefaultsKeys.Temperature.LAST_TEMPERATURE_CONVERSION_USER_DEFAULTS_KEY)
                
                /// Saving data in user defaults
                saveInUserDefaults(data: temperatureHistory, key: UserDefaultsKeys.Temperature.TEMPERATURE_CONVERSIONS_USER_DEFAULTS_KEY)
                
                /// Saving last active text field in user defaults
                saveInUserDefaults(data: activeInputTextField.tag, key: UserDefaultsKeys.Temperature.LAST_EDITED_FIELD_TEMPERATURE_CONVERSION_TAG_USER_DEFAULTS_KEY)
                
                // Disabling the save button
                self.navigationItem.rightBarButtonItem!.isEnabled = false;
                
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: Alert.Success.title, message: Alert.Success.Temperature.message)
                
            }else{
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: Alert.Warning.title, message:Alert.Warning.Temperature.message)
            }
        }else{
            
            /// showAlert method is defined in the  UIViewControllerHelper
            showAlert(title: Alert.Error.title, message:Alert.Error.message)
            
        }
        
    }
    
    @IBAction func inputTextFieldsResetButton(_ sender: UIBarButtonItem) {
        
        inputTextFieldsClearButton(inputTextFields: temperatureInputTextFields, rightBarButtonItems: self.navigationItem.rightBarButtonItems!)
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
