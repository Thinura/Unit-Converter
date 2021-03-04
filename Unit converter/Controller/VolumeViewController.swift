//
//  VolumeViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

class VolumeViewController: UIViewController, CustomKeyboardDelegate {
    
    /// Defaults
    var activeInputTextField = UITextField()
    var volumeMainStackTopConstraintDefaultHeight: CGFloat = 17.0
    var inputTextFieldKeyBoardGap = 20
    var keyBoardDefaultHeight:CGFloat = 0
    var decimalDigit = 4
    
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
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(keyWillHide)))
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        
        settingUpCustomKeyboard()
        
        settingUpDecimal()
        
    }
    
    /// This function setting up the custom keyboard
    func settingUpCustomKeyboard() {
        
        // Setting up the custom keyboard with the text input fields
        cuMillimetreInputTextField.initializeCustomKeyboard(delegate: self)
        cuCentimetreInputTextField.initializeCustomKeyboard(delegate: self)
        cuMetreInputTextField.initializeCustomKeyboard(delegate: self)
        cuInchInputTextField.initializeCustomKeyboard(delegate: self)
        cuFootInputTextField.initializeCustomKeyboard(delegate: self)
        cuYardInputTextField.initializeCustomKeyboard(delegate: self)
        
        //Listening to keyboard show events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    
    /// This function read the decimal digit from user defaults
    func settingUpDecimal() {
        /// Reading from user defaults
        let userDefaultDecimalDigit = UserDefaults.standard.value(forKey: UserDefaultsKeys.Settings.DECIMAL_DIGIT_USER_DEFAULTS_KEY) as? NSString
        // Default value will be set to 4 decimal points
        let decimal = ((userDefaultDecimalDigit ?? "4") as NSString).integerValue
        
        
        if !activeInputTextField.text!.isEmpty {
            // Inililzing user default decimal digit
            self.decimalDigit = decimal
            // Change according to the decimal digit but not active input field
            checkWhichTextFieldPressed(sender: activeInputTextField)
            
        }else{
            // Load last saved data
            loadLastConversion()
            
            // Inililzing user default decimal digit
            self.decimalDigit = decimal
            checkWhichTextFieldPressed(sender: cuMillimetreInputTextField)
            
        }
    }
    
    func checkWhichTextFieldPressed(sender:UITextField){
        var volumeUnit: VolumeMeasurementUnit?
        
        /// Checking whether which input field is pressed
        if sender.tag == 1 {
            volumeUnit = VolumeMeasurementUnit.cuMillimetre
        } else if sender.tag == 2 {
            volumeUnit = VolumeMeasurementUnit.cuCentimetre
        } else if sender.tag == 3 {
            volumeUnit = VolumeMeasurementUnit.cuMetre
        } else if sender.tag == 4 {
            volumeUnit = VolumeMeasurementUnit.cuInch
        } else if sender.tag == 5 {
            volumeUnit = VolumeMeasurementUnit.cuFoot
        } else if sender.tag == 6 {
            volumeUnit = VolumeMeasurementUnit.cuYard
        }
        
        if volumeUnit != nil {
            updateInputTextFields(textField: sender, volumeUnit: volumeUnit!)
        }
    }
    
    // Load last conversion from user defaults
    func loadLastConversion(){
        /// Read from user defaults
        let lastSavedConversion = UserDefaults.standard.value(forKey: UserDefaultsKeys.Volume.LAST_VOLUME_CONVERSION_USER_DEFAULTS_KEY) as? [String]
        
        if lastSavedConversion?.count ?? 0 > 0 {
            
            cuMillimetreInputTextField.text = lastSavedConversion![0]
            cuCentimetreInputTextField.text = lastSavedConversion![1]
            cuInchInputTextField.text = lastSavedConversion![2]
            cuMetreInputTextField.text = lastSavedConversion![3]
            cuFootInputTextField.text = lastSavedConversion![4]
            cuYardInputTextField.text = lastSavedConversion![5]
        }
        
    }
    
    /**
     This function will be called by the tap gesture recogniser and will hide the keyboard and restore the top constraint back to pervious view
     
     */
    @objc func keyWillHide(){
        // Remove listening the first responder
        view.endEditing(true)
        
        UIView.animate(withDuration: 0.50, animations: {
            // Putting the view back to previous state
            self.volumeMainStackTopConstraint.constant = self.volumeMainStackTopConstraintDefaultHeight
            self.view.layoutIfNeeded()
        })
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
            
            let activeInputTextFieldSuperView = activeInputTextField.superview!
            
            
            if let info = notification.userInfo{
                let keyboard:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
                
                let targetY = view.frame.size.height - keyboard.height - 15 - activeInputTextField.frame.size.height
                
                let initialY = volumeScreenMainStackView.frame.origin.y + activeInputTextFieldSuperView.frame.origin.y + activeInputTextField.frame.origin.y
                
                
                if initialY > targetY {
                    let diff = targetY - initialY
                    let targetOffsetForTopConstraint = volumeMainStackTopConstraint.constant + diff
                    self.view.layoutIfNeeded()
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        self.volumeMainStackTopConstraint.constant = targetOffsetForTopConstraint
                        self.view.layoutIfNeeded()
                    })
                }
                
                var contentInset:UIEdgeInsets = self.volumeScreenScrollView.contentInset
                contentInset.bottom = keyboard.size.height
                volumeScreenScrollView.contentInset = contentInset
            }
        }
    }
    
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
    func checkAvailabilityRightBarButtons() {
        // Getting access on last two right navigation bar buttons
        let rightBarButtons =  self.navigationItem.rightBarButtonItems!.prefix(2)
        for button in rightBarButtons {
            if isInputTextFieldEmpty() {
                button.isEnabled = false
            }else{
                button.isEnabled = true
            }
        }
    }
    
    
    @IBAction func handleInputTextField(_ sender: UITextField) {
        
        checkWhichTextFieldPressed(sender: sender)
        checkAvailabilityRightBarButtons()
    }
    
    /// This function clears all the text fields
    func clearTextFields(inputTextFields:[UITextField]) {
        for textInputField in inputTextFields{
            textInputField.text = ""
        }
        checkAvailabilityRightBarButtons()
    }
    
    @IBAction func inputTextFieldsResetButton(_ sender: UIBarButtonItem) {
        if !isInputTextFieldEmpty(){
            ///Clear the input text fields when its empty
            clearTextFields(inputTextFields: volumeInputTextFields)
        }
    }
    
    func checkConversionIsAlreadySaved(historyList:[String],conversion:String)->Bool{
        for historyListConversion in historyList {
            if (historyListConversion == conversion){
                return true
            }
        }
        return false
    }
    
    /**
     Method returns a boolean after checking whether input fields are empty or not
     
     - Returns: Boolean
     
     */
    func isInputTextFieldEmpty() -> Bool {
        if !(cuMillimetreInputTextField.text?.isEmpty)! && !(cuCentimetreInputTextField.text?.isEmpty)! && !(cuInchInputTextField.text?.isEmpty)! && !(cuMetreInputTextField.text?.isEmpty)! && !(cuFootInputTextField.text?.isEmpty)! && !(cuYardInputTextField.text?.isEmpty)!{
            return false
        }
        return true
    }
    
    /**
     This function maps value to volume unit respectively
     - Parameters: volumeUnit of the volume that user input
     - Returns: Respective UITextField
     */
    func mapUnitToTextField(volumeUnit: VolumeMeasurementUnit) -> UITextField {
        var textField = cuMillimetreInputTextField
        switch volumeUnit {
        case .cuMillimetre:
            textField = cuMillimetreInputTextField
        case .cuCentimetre:
            textField = cuCentimetreInputTextField
        case .cuInch:
            textField = cuInchInputTextField
        case .cuMetre:
            textField = cuMetreInputTextField
        case .cuFoot:
            textField = cuFootInputTextField
        case .cuYard:
            textField = cuYardInputTextField
        }
        return textField!
    }
    
    /**
     Method will update the other volume input fields
     
     -  Parameters: textField, volumeUnit of the changed method
     
     */
    func updateInputTextFields(textField: UITextField, volumeUnit: VolumeMeasurementUnit) -> Void{
        if let input = textField.text {
            if input.isEmpty {
                
                ///Clear the input text fields when its empty
                clearTextFields(inputTextFields: volumeInputTextFields)
                
            } else {
                
                if let value = Double(input as String) {
                    let volume = Volume(unit: volumeUnit, value: value)
                    
                    for _unit in VolumeMeasurementUnit.getAvailableVolumeUnits {
                        if _unit == volumeUnit {
                            continue
                        }
                        let textField = mapUnitToTextField(volumeUnit: _unit)
                        let result = volume.convert(unit: _unit)
                        
                        /// Rounding off to 4 decimal places by default
                        let roundedResult = result.truncate(places: self.decimalDigit)
                        
                        textField.text = String(roundedResult)
                    }
                }
            }
        }
    }
    
    /**
     This function handle the save buttons' functionality which only can be save 5 conversions
     */
    @IBAction func handleSaveButton(_ sender: UIBarButtonItem) {
        if !isInputTextFieldEmpty(){
            
            let lastAddData = [cuMillimetreInputTextField.text!, cuCentimetreInputTextField.text!,cuInchInputTextField.text!,cuMetreInputTextField.text!, cuFootInputTextField.text!,cuYardInputTextField.text!] as [String]
            
            
            let conversion = "\(cuMillimetreInputTextField.text!) cu mm = \(cuCentimetreInputTextField.text!) cu cm = \(cuMetreInputTextField.text!) cu m = \(cuInchInputTextField.text!) cu in = \(cuFootInputTextField.text!) cu ft = \(cuYardInputTextField.text!) cu yd"
            
            /// Getting initial history data
            var volumeHistory = UserDefaults.standard.array(forKey: UserDefaultsKeys.Volume.VOLUME_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            if (!checkConversionIsAlreadySaved(historyList: volumeHistory, conversion: conversion)){
                
                /// Check whether there are maximum amount of volume conversions if so first value will be removed
                if volumeHistory.count >= UserDefaultsKeys.Volume.VOLUME_CONVERSIONS_USER_DEFAULTS_MAX_COUNT {
                    volumeHistory = Array(volumeHistory.suffix(UserDefaultsKeys.Volume.VOLUME_CONVERSIONS_USER_DEFAULTS_MAX_COUNT - 1))
                }
                volumeHistory.append(conversion)
                
                /// Add last added conversion
                UserDefaults.standard.set(lastAddData, forKey: UserDefaultsKeys.Volume.LAST_VOLUME_CONVERSION_USER_DEFAULTS_KEY)
                
                
                /// Saving data in user defaults
                UserDefaults.standard.set(volumeHistory, forKey: UserDefaultsKeys.Volume.VOLUME_CONVERSIONS_USER_DEFAULTS_KEY)
                
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
