//
//  SpeedViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

class SpeedViewController: UIViewController,CustomKeyboardDelegate {
    
    /// Defaults
    var activeInputTextField = UITextField()
    var speedMainStackTopConstraintDefaultHeight: CGFloat = 17.0
    var inputTextFieldKeyBoardGap = 20
    var keyBoardDefaultHeight:CGFloat = 0
    var decimalDigit = 4
    
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
        metresSecondInputTextField.initializeCustomKeyboard(delegate: self)
        kilometreHourInputTextField.initializeCustomKeyboard(delegate: self)
        milesHourInputTextField.initializeCustomKeyboard(delegate: self)
        knotInputTextField.initializeCustomKeyboard(delegate: self)
        
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
            checkWhichTextFieldPressed(sender:metresSecondInputTextField)
            
        }
    }
    
    func checkWhichTextFieldPressed(sender:UITextField){
        var unit: SpeedMeasurementUnit?
        
        if sender.tag == 1 {
            unit = SpeedMeasurementUnit.metresSecond
        } else if sender.tag == 2 {
            unit = SpeedMeasurementUnit.kilometreHour
        } else if sender.tag == 3 {
            unit = SpeedMeasurementUnit.milesHour
        }else if sender.tag == 4 {
            unit = SpeedMeasurementUnit.knot
        }
        
        if unit != nil {
            updateInputTextFields(textField: sender, speedUnit: unit!)
        }
    }
    
    // Load last conversion from user defaults
    func loadLastConversion(){
        /// Read from user defaults
        let lastSavedConversion = UserDefaults.standard.value(forKey: UserDefaultsKeys.Speed.LAST_SPEED_CONVERSION_USER_DEFAULTS_KEY) as? [String]
        
        if lastSavedConversion?.count ?? 0 > 0 {
            
            // Setting the conversion to the input text fields
            metresSecondInputTextField.text = lastSavedConversion![0]
            kilometreHourInputTextField.text = lastSavedConversion![1]
            milesHourInputTextField.text = lastSavedConversion![2]
            knotInputTextField.text = lastSavedConversion![2]
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
            self.speedMainStackTopConstraint.constant = self.speedMainStackTopConstraintDefaultHeight
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
                
                let initialY = speedScreenMainStackView.frame.origin.y + activeInputTextFieldSuperView.frame.origin.y + activeInputTextField.frame.origin.y
                
                
                if initialY > targetY {
                    let diff = targetY - initialY
                    let targetOffsetForTopConstraint = speedMainStackTopConstraint.constant + diff
                    self.view.layoutIfNeeded()
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        self.speedMainStackTopConstraint.constant = targetOffsetForTopConstraint
                        self.view.layoutIfNeeded()
                    })
                }
                
                var contentInset:UIEdgeInsets = self.speedScreenScrollView.contentInset
                contentInset.bottom = keyboard.size.height
                speedScreenScrollView.contentInset = contentInset
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
    
    
    /// listening which input was typed
    @IBAction func handleInputTextField(_ sender: UITextField) {
        
        checkWhichTextFieldPressed(sender: sender)
        
        checkAvailabilityRightBarButtons()
    }
    
    
    /**
     Method returns a boolean after checking whether input fields are empty or not
     
     - Returns: Boolean
     
     */
    func isInputTextFieldEmpty() -> Bool {
        if !(metresSecondInputTextField.text?.isEmpty)! && !(kilometreHourInputTextField.text?.isEmpty)! && !(milesHourInputTextField.text?.isEmpty)! && !(knotInputTextField.text?.isEmpty)!{
            return false
        }
        return true
    }
    
    /**
     Method will update the other speed input fields
     
     -  Parameters: textField, speedUnit of the changed method
     
     */
    func updateInputTextFields(textField: UITextField, speedUnit: SpeedMeasurementUnit) -> Void{
        if let input = textField.text{
            if input.isEmpty{
                
                ///Clear the input text fields when its empty
                clearTextFields(inputTextFields: speedInputTextFields)
                
            }else{
                
                if let value = Double(input as String){
                    let speed = Speed(unit: speedUnit, value: value)
                    
                    for _unit in SpeedMeasurementUnit.getAvailableSpeedUnits{
                        if _unit == speedUnit{
                            continue
                        }
                        let textField = mapUnitToTextField(speedUnit: _unit)
                        let result = speed.convert(unit: _unit)
                        
                        // Rounding off to 4 decimal places by default
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
    func mapUnitToTextField(speedUnit: SpeedMeasurementUnit) -> UITextField {
        var textField = metresSecondInputTextField
        switch speedUnit {
        case .metresSecond:
            textField = metresSecondInputTextField
        case .kilometreHour:
            textField = kilometreHourInputTextField
        case .milesHour:
            textField = milesHourInputTextField
        case .knot:
            textField = knotInputTextField
        }
        return textField!
    }
    
    /**
     This function handle the save buttons' functionality which only can be save 5 conversions
     */
    @IBAction func handleSaveButton(_ sender: UIBarButtonItem) {
        if !isInputTextFieldEmpty(){
            let lastAddData = [metresSecondInputTextField.text!, kilometreHourInputTextField.text!,milesHourInputTextField.text!, knotInputTextField.text!] as [String]
            
            let conversion = "\(metresSecondInputTextField.text!) ms/s = \(kilometreHourInputTextField.text!) km/h = \(milesHourInputTextField.text!) mi/h = \(knotInputTextField.text!) knots"
            
            /// Getting initial history data
            var speedHistory = UserDefaults.standard.array(forKey: UserDefaultsKeys.Speed.SPEED_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            if (!checkConversionIsAlreadySaved(historyList: speedHistory, conversion: conversion)){
                
                /// Check whether there are maximum amount of speed conversions if so first value will be removed
                if speedHistory.count >= UserDefaultsKeys.Speed.SPEED_CONVERSIONS_USER_DEFAULTS_MAX_COUNT {
                    speedHistory = Array(speedHistory.suffix(UserDefaultsKeys.Speed.SPEED_CONVERSIONS_USER_DEFAULTS_MAX_COUNT - 1))
                }
                speedHistory.append(conversion)
                
                /// Add last added conversion
                UserDefaults.standard.set(lastAddData, forKey: UserDefaultsKeys.Speed.LAST_SPEED_CONVERSION_USER_DEFAULTS_KEY)
                
                /// Saving data in user defaults
                UserDefaults.standard.set(speedHistory, forKey: UserDefaultsKeys.Speed.SPEED_CONVERSIONS_USER_DEFAULTS_KEY)
                
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: "Success", message: "The speed conversion was successfully saved.")
            }else{
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: "Warning", message: "The speed conversion is already saved")
            }
        }else{
            
            /// showAlert method is defined in the  UIViewControllerHelper
            showAlert(title: "Error", message: "You are trying to save an empty conversion.")
            
        }
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
            clearTextFields(inputTextFields: speedInputTextFields)
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

