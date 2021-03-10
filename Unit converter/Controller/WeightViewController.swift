//
//  WeightViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

class WeightViewController: UIViewController, CustomKeyboardDelegate, ConversionHelper, CustomKeyboardHelper {
    
    /// Defaults
    var activeInputTextField = UITextField()
    var decimalDigit = DecimalSelector.defaultDecimalDigit
    
    /// Used for keyboard handling - When user pressed auto scroll will be enable
    @IBOutlet weak var weightMainStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var weightScreenScrollView: UIScrollView!
    @IBOutlet weak var weightScreenMainStackView: UIStackView!
    
    /// Text input fields
    @IBOutlet weak var kilogramInputTextField: UITextField!
    @IBOutlet weak var gramInputTextField: UITextField!
    @IBOutlet weak var ounceInputField: UITextField!
    @IBOutlet weak var poundInputField: UITextField!
    @IBOutlet weak var spStoneInputField: UITextField!
    @IBOutlet weak var spPoundInputField: UITextField!
    var weightInputTextFields: [UITextField] { return [gramInputTextField, kilogramInputTextField, ounceInputField, poundInputField, spStoneInputField, spPoundInputField]}
    ///Stack views for Input Fields
    @IBOutlet weak var kilogramStackView: UIStackView!
    @IBOutlet weak var gramStackView: UIStackView!
    @IBOutlet weak var ounceStackView: UIStackView!
    @IBOutlet weak var poundStackView: UIStackView!
    @IBOutlet weak var stonePoundStackView: UIStackView!
    
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
        for item in weightInputTextFields {
            if(item == weightInputTextFields[5]){
                // disable the interactivity pound is already on the input text
                item.isUserInteractionEnabled = false
            }
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
            loadLastConversion(inputFields: weightInputTextFields, conversionUserDefaultsKey:  UserDefaultsKeys.Weight.LAST_WEIGHT_CONVERSION_USER_DEFAULTS_KEY,conversionLastActiveTextFieldKey: UserDefaultsKeys.Weight.LAST_EDITED_FIELD_WEIGHT_CONVERSION_TAG_USER_DEFAULTS_KEY,rightBarButtonItem: self.navigationItem.rightBarButtonItem!)
            
        }
    }
    
    
    
    /**
     This function which input field is pressed and updating the other input fields
     
     - Parameter sender:UITextField
     
     */
    func checkWhichTextFieldPressed(sender:UITextField){
        var weightUnit: WeightMeasurementUnit?
        
        weightUnit = getUnitByTag(tag: sender.tag, unitsArray: WeightMeasurementUnit.getAvailableWeightUnits)
        
        if weightUnit != nil {
            updateInputTextFields(textField: sender, unit: weightUnit!)
        }
    }
    
    /**
     This function will be called by the tap gesture recogniser and will hide the keyboard and restore the top constraint back to pervious view
     
     */
    @objc func keyWillHide(){
        hideCustomKeyboard(mainStackTopConstraint: self.weightMainStackTopConstraint,view: self.view)
        
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
            
            showCustomKeyboard(activeInputTextField: activeInputTextField, notification: notification, screenMainStackView: self.weightScreenMainStackView, screenScrollView: self.weightScreenScrollView, mainStackTopConstraint: self.weightMainStackTopConstraint, view: self.view)
        }
    }
    
    
    /// listening which input was typed 
    @IBAction func handleInputTextField(_ sender: UITextField) {
        checkWhichTextFieldPressed(sender: sender)
        checkAvailabilityRightBarButtons(rightBarButtonItems:self.navigationItem.rightBarButtonItems!,inputFields: weightInputTextFields)
    }
    
    /**
     Method will update the other weight input fields
     
     -  Parameters: textField, weightUnit of the changed method
     
     */
    func updateInputTextFields<T: MeasurementUnit>(textField: UITextField, unit: T) -> Void{
        if let input = textField.text {
            if input.isEmpty {
                
                ///Clear the input text fields when its empty
                clearTextFields(inputTextFields: weightInputTextFields)
                checkAvailabilityRightBarButtons(rightBarButtonItems:self.navigationItem.rightBarButtonItems!,inputFields: weightInputTextFields)
                
            } else {
                
                if let value = Double(input as String) {
                    let weight = Weight(unit: unit as! WeightMeasurementUnit, value: value)
                    
                    for _unit in WeightMeasurementUnit.getAvailableWeightUnits {
                        if _unit == unit as! WeightMeasurementUnit {
                            continue
                        }
                        let textField = mapUnitToTextField(unit: _unit)
                        let result = weight.convert(unit: _unit)
                        
                        // Rounding off to decimal digit
                        let roundedResult = result.truncate(places: self.decimalDigit)
                        
                        textField.text = String(roundedResult)
                        separateStonePounds()
                    }
                }
            }
        }
    }
    
    /**
     This function maps value to weight unit respectively
     - Parameters: weightUnit of the weight that user input
     - Returns: Respective UITextField
     */
    func mapUnitToTextField<T: MeasurementUnit>(unit: T) -> UITextField{
        var textField = UITextField()
        let weightUnit = WeightMeasurementUnit.getAvailableWeightUnits
        for index in 1...weightUnit.count {
            let item = weightUnit[index-1]
            if unit as! WeightMeasurementUnit == item {
                textField = weightInputTextFields[index-1]
                return textField
            }
        }
        return textField
    }
    
    /// This function separate the decimal in stone and add it to the pounds section
    func separateStonePounds(){
        if let spStoneTextField = spStoneInputField.text {
            if let value = Double(spStoneTextField as String) {
                let integerPart = Int(value)
                let decimalPart = value.truncatingRemainder(dividingBy: 1)
                let poundValue = decimalPart * 14
                
                spStoneInputField.text = String(integerPart)
                spPoundInputField.text = String(poundValue.truncate(places: self.decimalDigit))
            }
        }
    }
    
    /**
     This function handle the save buttons' functionality which only can be save 5 conversions
     */
    @IBAction func handleSaveButton(_ sender: UIBarButtonItem) {
        if !isInputTextFieldEmpty(inputFields: weightInputTextFields){
            
            let lastData = lastAddedData(inputFields: weightInputTextFields) as [String]
            
            let conversion = Weight.weightConversion(inputFields: weightInputTextFields) as String
            
            /// Getting initial history data
            var weightHistory = UserDefaults.standard.array(forKey: UserDefaultsKeys.Weight.WEIGHT_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            if (!checkConversionIsAlreadySaved(historyList: weightHistory, conversion: conversion)){
                
                /// Check whether there are maximum amount of weight conversions if so first value will be removed
                weightHistory = checkMaximumConversion(conversion: conversion, conversionKey: UserDefaultsKeys.Weight.WEIGHT_CONVERSIONS_USER_DEFAULTS_KEY, conversionsMaxCount: UserDefaultsKeys.Weight.WEIGHT_CONVERSIONS_USER_DEFAULTS_MAX_COUNT) as [String]
                
                /// Save last conversion in user defaults
                saveInUserDefaults(data: lastData, key: UserDefaultsKeys.Weight.LAST_WEIGHT_CONVERSION_USER_DEFAULTS_KEY)
                
                /// Saving conversion in user defaults
                saveInUserDefaults(data: weightHistory, key: UserDefaultsKeys.Weight.WEIGHT_CONVERSIONS_USER_DEFAULTS_KEY)
                
                /// Saving last active text field in user defaults
                saveInUserDefaults(data: activeInputTextField.tag, key: UserDefaultsKeys.Weight.LAST_EDITED_FIELD_WEIGHT_CONVERSION_TAG_USER_DEFAULTS_KEY)
                
                // Disabling the save button
                self.navigationItem.rightBarButtonItem!.isEnabled = false;
                
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: Alert.Success.title, message: Alert.Success.Weight.message)
                
            }else{
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: Alert.Warning.title, message: Alert.Warning.Weight.message)
            }
        }else{
            
            /// showAlert method is defined in the  UIViewControllerHelper
            showAlert(title: Alert.Error.title, message: Alert.Error.message)
            
        }
    }
    
    
    
    @IBAction func inputTextFieldsResetButton(_ sender: UIBarButtonItem) {
        
        inputTextFieldsClearButton(inputTextFields: weightInputTextFields, rightBarButtonItems: self.navigationItem.rightBarButtonItems!)
        
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
