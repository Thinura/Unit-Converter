//
//  LiquidVolumeViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

class LiquidVolumeViewController: UIViewController, CustomKeyboardDelegate, ConversionHelper, CustomKeyboardHelper {
    
    /// Defaults
    var activeInputTextField = UITextField()
    var decimalDigit = DecimalSelector.defaultDecimalDigit
    
    /// Used for keyboard handling - When user pressed auto scroll will be enable
    @IBOutlet weak var liquidVolumeMainStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var liquidVolumeScreenScrollView: UIScrollView!
    @IBOutlet weak var liquidVolumeMainStack: UIStackView!
    
    /// Text Input Fields
    @IBOutlet weak var litreInputTextField: UITextField!
    @IBOutlet weak var millilitreInputTextField: UITextField!
    @IBOutlet weak var ukGallonInputTextField: UITextField!
    @IBOutlet weak var ukPintInputTextField: UITextField!
    @IBOutlet weak var ukFluidOunceInputTextField: UITextField!
    var liquidVolumeInputTextFields: [UITextField] {
        return [litreInputTextField, millilitreInputTextField, ukGallonInputTextField, ukPintInputTextField, ukFluidOunceInputTextField]
    }
    /// Stack views for Input Fields
    @IBOutlet weak var litreStackView: UIStackView!
    @IBOutlet weak var millilitreStackView: UIStackView!
    @IBOutlet weak var ukGallonStackView: UIStackView!
    @IBOutlet weak var ukPintStackView: UIStackView!
    @IBOutlet weak var ukFluidOunceStackView: UIStackView!
    
    
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
        for item in liquidVolumeInputTextFields {
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
            loadLastConversion(inputFields: liquidVolumeInputTextFields, conversionUserDefaultsKey:  UserDefaultsKeys.LiquidVolume.LAST_LIQUID_VOLUME_CONVERSION_USER_DEFAULTS_KEY,conversionLastActiveTextFieldKey: UserDefaultsKeys.LiquidVolume.LAST_EDITED_FIELD_LIQUID_VOLUME_CONVERSION_TAG_USER_DEFAULTS_KEY,rightBarButtonItem: self.navigationItem.rightBarButtonItem!)
            
        }
    }
    
    func checkWhichTextFieldPressed(sender:UITextField){
        var liquidVolumeUnit: LiquidVolumeMeasurementUnit?
        
        liquidVolumeUnit = getUnitByTag(tag: sender.tag, unitsArray: LiquidVolumeMeasurementUnit.getAvailableLiquidVolumeUnits)
        
        if liquidVolumeUnit != nil {
            updateInputTextFields(textField: sender, unit: liquidVolumeUnit!)
        }
    }
    
    /**
     This function will be called by the tap gesture recogniser and will hide the keyboard and restore the top constraint back to pervious view
     
     */
    @objc func keyWillHide(){
        hideCustomKeyboard(mainStackTopConstraint: self.liquidVolumeMainStackTopConstraint,view: self.view)
        
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
            
            showCustomKeyboard(activeInputTextField: activeInputTextField, notification: notification, screenMainStackView: self.liquidVolumeMainStack, screenScrollView: self.liquidVolumeScreenScrollView, mainStackTopConstraint: self.liquidVolumeMainStackTopConstraint, view: self.view)
        }
    }
    
    @IBAction func handleInputTextField(_ sender: UITextField) {
        
        checkWhichTextFieldPressed(sender: sender)
        checkAvailabilityRightBarButtons(rightBarButtonItems:self.navigationItem.rightBarButtonItems!,inputFields: liquidVolumeInputTextFields)
    }
    
    /**
     Method will update the other liquid volume input fields
     
     -  Parameters: textField, liquidVolumeUnit of the changed method
     
     */
    func updateInputTextFields<T: MeasurementUnit>(textField: UITextField, unit: T) -> Void{
        if let input = textField.text {
            if input.isEmpty {
                
                ///Clear the input text fields when its empty
                clearTextFields(inputTextFields: liquidVolumeInputTextFields)
                checkAvailabilityRightBarButtons(rightBarButtonItems:self.navigationItem.rightBarButtonItems!,inputFields: liquidVolumeInputTextFields)
                
                
            } else {
                
                if let value = Double(input as String) {
                    let liquidVolume = LiquidVolume(unit: unit as! LiquidVolumeMeasurementUnit, value: value)
                    
                    for _unit in LiquidVolumeMeasurementUnit.getAvailableLiquidVolumeUnits {
                        if _unit == unit as! LiquidVolumeMeasurementUnit {
                            continue
                        }
                        let textField = mapUnitToTextField(unit: _unit)
                        let result = liquidVolume.convert(unit: _unit)
                        
                        // Rounding off to decimal digit
                        let roundedResult = result.truncate(places: self.decimalDigit)
                        
                        textField.text = String(roundedResult)
                    }
                }
            }
        }
    }
    
    /**
     This function maps value to liquid volume unit respectively
     - Parameters: liquidVolumeUnit of the liquid volume that user input
     - Returns: Respective UITextField
     */
    func mapUnitToTextField<T: MeasurementUnit>(unit: T) -> UITextField {
        var textField = UITextField()
        let liquidVolumeUnit = LiquidVolumeMeasurementUnit.getAvailableLiquidVolumeUnits
        for index in 1...liquidVolumeUnit.count {
            let item = liquidVolumeUnit[index-1]
            if unit as! LiquidVolumeMeasurementUnit == item {
                textField = liquidVolumeInputTextFields[index-1]
                return textField
            }
        }
        return textField
    }
    
    /**
     This function handle the save buttons' functionality which only can be save 5 conversions
     */
    @IBAction func handleSaveButton(_ sender: UIBarButtonItem) {
        if !isInputTextFieldEmpty(inputFields: liquidVolumeInputTextFields){
            
            let lastData = lastAddedData(inputFields: liquidVolumeInputTextFields) as [String]
            
            let conversion = LiquidVolume.liquidVolumeConversion(inputFields: liquidVolumeInputTextFields) as String
            
            /// Getting initial history data
            var liquidVolumeHistory = UserDefaults.standard.array(forKey: UserDefaultsKeys.LiquidVolume.LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            if (!checkConversionIsAlreadySaved(historyList: liquidVolumeHistory, conversion: conversion)){
                
                /// Check whether there are maximum amount of liquid volume conversions if so first value will be removed
                liquidVolumeHistory = checkMaximumConversion(conversion: conversion, conversionKey: UserDefaultsKeys.LiquidVolume.LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_KEY, conversionsMaxCount: UserDefaultsKeys.LiquidVolume.LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_MAX_COUNT)
                
                /// Add last added conversion
                saveInUserDefaults(data: lastData, key: UserDefaultsKeys.LiquidVolume.LAST_LIQUID_VOLUME_CONVERSION_USER_DEFAULTS_KEY)
                
                /// Saving data in user defaults
                saveInUserDefaults(data: liquidVolumeHistory, key: UserDefaultsKeys.LiquidVolume.LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_KEY)
                
                /// Saving last active text field in user defaults
                saveInUserDefaults(data: activeInputTextField.tag, key: UserDefaultsKeys.LiquidVolume.LAST_EDITED_FIELD_LIQUID_VOLUME_CONVERSION_TAG_USER_DEFAULTS_KEY)
                
                // Disabling the save button
                self.navigationItem.rightBarButtonItem!.isEnabled = false;
                
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: Alert.Success.title, message:Alert.Success.LiquidVolume.message)
            }else{
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: Alert.Warning.title, message:Alert.Warning.LiquidVolume.message)
            }
        }else{
            
            /// showAlert method is defined in the  UIViewControllerHelper
            showAlert(title: Alert.Error.title, message: Alert.Error.message)
            
        }
    }
    
    @IBAction func inputTextFieldsResetButton(_ sender: UIBarButtonItem) {
        
        inputTextFieldsClearButton(inputTextFields: liquidVolumeInputTextFields, rightBarButtonItems: self.navigationItem.rightBarButtonItems!)
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

