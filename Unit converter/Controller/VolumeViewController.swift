//
//  VolumeViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

class VolumeViewController: UIViewController, CustomKeyboardDelegate, ConversionHelper, CustomKeyboardHelper {
    
    /// Defaults
    var activeInputTextField = UITextField()
    var decimalDigit = DecimalSelector.defaultDecimalDigit
    
    /// Used for keyboard handling - When user pressed auto scroll will be enable
    @IBOutlet weak var volumeMainStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var volumeScreenScrollView: UIScrollView!
    @IBOutlet weak var volumeScreenMainStackView: UIStackView!
    
    /// Text Input Fields
    @IBOutlet weak var cuMillimetreInputTextField: UITextField!
    @IBOutlet weak var cuCentimetreInputTextField: UITextField!
    @IBOutlet weak var cuMetreInputTextField: UITextField!
    @IBOutlet weak var cuInchInputTextField: UITextField!
    @IBOutlet weak var cuFootInputTextField: UITextField!
    @IBOutlet weak var cuYardInputTextField: UITextField!
    var volumeInputTextFields: [UITextField] {
        return [cuMillimetreInputTextField, cuCentimetreInputTextField, cuMetreInputTextField, cuInchInputTextField, cuFootInputTextField, cuYardInputTextField]
    }
    /// Stack views for Input Fields
    @IBOutlet weak var cuMillimetreStackView: UIStackView!
    @IBOutlet weak var cuCentimetreStackView: UIStackView!
    @IBOutlet weak var cuMetreStackView: UIStackView!
    @IBOutlet weak var cuInchStackView: UIStackView!
    @IBOutlet weak var cuFootStackView: UIStackView!
    @IBOutlet weak var cuYardStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding gesture recogniser listener
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(keyWillHide)))
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        
        settingUpCustomKeyboard()
        
        settingUpDecimal()
        
    }
    
    /// This function setting up the custom keyboard
    func settingUpCustomKeyboard() {
        
        // Setting up the custom keyboard with the text input fields
        for item in volumeInputTextFields {
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
            loadLastConversion(inputFields: volumeInputTextFields, conversionUserDefaultsKey:  UserDefaultsKeys.Volume.LAST_VOLUME_CONVERSION_USER_DEFAULTS_KEY,conversionLastActiveTextFieldKey: UserDefaultsKeys.Volume.LAST_EDITED_FIELD_VOLUME_CONVERSION_TAG_USER_DEFAULTS_KEY,rightBarButtonItem: self.navigationItem.rightBarButtonItem!)
            
        }
    }
    
    /**
     This function which input field is pressed and updating the other input fields
     - Parameter sender:UITextField
     */
    func checkWhichTextFieldPressed(sender:UITextField){
        var volumeUnit: VolumeMeasurementUnit?
        
        volumeUnit = getUnitByTag(tag: sender.tag, unitsArray: VolumeMeasurementUnit.getAvailableVolumeUnits)
        
        if volumeUnit != nil {
            updateInputTextFields(textField: sender, unit: volumeUnit!)
        }
    }
    
    /**
     This function will be called by the tap gesture recogniser and will hide the keyboard and restore the top constraint back to pervious view
     
     */
    @objc func keyWillHide(){
        hideCustomKeyboard(mainStackTopConstraint: self.volumeMainStackTopConstraint,view: self.view)
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
            
            showCustomKeyboard(activeInputTextField: activeInputTextField, notification: notification, screenMainStackView: self.volumeScreenMainStackView, screenScrollView: self.volumeScreenScrollView, mainStackTopConstraint: self.volumeMainStackTopConstraint, view: self.view)
        }
    }
    
    @IBAction func handleInputTextField(_ sender: UITextField) {
        
        checkWhichTextFieldPressed(sender: sender)
        checkAvailabilityRightBarButtons(rightBarButtonItems:self.navigationItem.rightBarButtonItems!,inputFields: volumeInputTextFields)
    }
    
    /**
     Method will update the other volume input fields
     
     -  Parameters: textField, volumeUnit of the changed method
     
     */
    func updateInputTextFields<T: MeasurementUnit>(textField: UITextField, unit: T) -> Void{
        if let input = textField.text {
            if input.isEmpty {
                
                ///Clear the input text fields when its empty
                clearTextFields(inputTextFields: volumeInputTextFields)
                checkAvailabilityRightBarButtons(rightBarButtonItems:self.navigationItem.rightBarButtonItems!,inputFields: volumeInputTextFields)
                
            } else {
                
                if let value = Double(input as String) {
                    let volume = Volume(unit: unit as! VolumeMeasurementUnit, value: value)
                    
                    for _unit in VolumeMeasurementUnit.getAvailableVolumeUnits {
                        if _unit == unit as! VolumeMeasurementUnit {
                            continue
                        }
                        let textField = mapUnitToTextField(unit: _unit)
                        let result = volume.convert(unit: _unit)
                        
                        // Rounding off to decimal digit
                        let roundedResult = result.truncate(places: self.decimalDigit)
                        
                        textField.text = String(roundedResult)
                    }
                }
            }
        }
    }
    
    /**
     This function maps value to volume unit respectively
     - Parameters: volumeUnit of the volume that user input
     - Returns: Respective UITextField
     */
    func mapUnitToTextField<T: MeasurementUnit>(unit: T) -> UITextField {
        var textField = UITextField()
        
        for index in 1...VolumeMeasurementUnit.getAvailableVolumeUnits.count {
            let item = VolumeMeasurementUnit.getAvailableVolumeUnits[index-1]
            if unit as! VolumeMeasurementUnit == item {
                textField = volumeInputTextFields[index-1]
                return textField
            }
            
        }
        return textField
    }
    
    /**
     This function handle the save buttons' functionality which only can be save 5 conversions
     */
    @IBAction func handleSaveButton(_ sender: UIBarButtonItem) {
        if !isInputTextFieldEmpty(inputFields: volumeInputTextFields){
            
            let lastData = lastAddedData(inputFields: volumeInputTextFields) as [String]
            
            let conversion = Volume.volumeConversion(inputFields: volumeInputTextFields) as String
            
            /// Getting initial history data
            var volumeHistory = UserDefaults.standard.array(forKey: UserDefaultsKeys.Volume.VOLUME_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            if (!checkConversionIsAlreadySaved(historyList: volumeHistory, conversion: conversion)){
                
                /// Check whether there are maximum amount of volume conversions if so first value will be removed
                volumeHistory = checkMaximumConversion(conversion:  conversion, conversionKey: UserDefaultsKeys.Volume.VOLUME_CONVERSIONS_USER_DEFAULTS_KEY, conversionsMaxCount: UserDefaultsKeys.Volume.VOLUME_CONVERSIONS_USER_DEFAULTS_MAX_COUNT ) as [String]
                
                /// Add last added conversion
                saveInUserDefaults(data: lastData, key:  UserDefaultsKeys.Volume.LAST_VOLUME_CONVERSION_USER_DEFAULTS_KEY)
                
                /// Saving data in user defaults
                saveInUserDefaults(data: volumeHistory, key:  UserDefaultsKeys.Volume.VOLUME_CONVERSIONS_USER_DEFAULTS_KEY)
                
                /// Saving last active text field in user defaults
                saveInUserDefaults(data: activeInputTextField.tag, key: UserDefaultsKeys.Volume.LAST_EDITED_FIELD_VOLUME_CONVERSION_TAG_USER_DEFAULTS_KEY)
                
                // Disabling the save button
                self.navigationItem.rightBarButtonItem!.isEnabled = false;
                
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: Alert.Success.title, message:Alert.Success.Volume.message)
                
            }else{
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: Alert.Warning.title, message: Alert.Warning.Volume.message)
            }
        }else{
            
            /// showAlert method is defined in the  UIViewControllerHelper
            showAlert(title: Alert.Error.title, message: Alert.Error.message)
            
        }
    }
    
    @IBAction func inputTextFieldsResetButton(_ sender: UIBarButtonItem) {
        
        inputTextFieldsClearButton(inputTextFields: volumeInputTextFields, rightBarButtonItems: self.navigationItem.rightBarButtonItems!)
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
