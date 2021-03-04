//
//  LengthViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

class LengthViewController: UIViewController, CustomKeyboardDelegate {
    
    /// Defaults
    var activeInputTextField = UITextField()
    var lengthMainStackTopConstraintDefaultHeight: CGFloat = 17.0
    var inputTextFieldKeyBoardGap = 20
    var keyBoardDefaultHeight:CGFloat = 0
    var decimalDigit = 4
    
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
        millimetreInputTextField.initializeCustomKeyboard(delegate: self)
        centimetreInputTextField.initializeCustomKeyboard(delegate: self)
        inchInputTextField.initializeCustomKeyboard(delegate: self)
        metreInputTextField.initializeCustomKeyboard(delegate: self)
        kilometreInputTextField.initializeCustomKeyboard(delegate: self)
        mileInputTextField.initializeCustomKeyboard(delegate: self)
        yardInputTextField.initializeCustomKeyboard(delegate: self)
        
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
            checkWhichTextFieldPressed(sender:millimetreInputTextField)
            
        }
    }
    
    func checkWhichTextFieldPressed(sender:UITextField){
        var lengthUnit: LengthMeasurementUnit?
        
        if sender.tag == 1 {
            lengthUnit = LengthMeasurementUnit.millimetre
        } else if sender.tag == 2 {
            lengthUnit = LengthMeasurementUnit.centimetre
        } else if sender.tag == 3 {
            lengthUnit = LengthMeasurementUnit.inch
        }else if sender.tag == 4 {
            lengthUnit = LengthMeasurementUnit.metre
        } else if sender.tag == 5 {
            lengthUnit = LengthMeasurementUnit.kilometre
        } else if sender.tag == 6 {
            lengthUnit = LengthMeasurementUnit.mile
        }else if sender.tag == 7 {
            lengthUnit = LengthMeasurementUnit.yard
        }
        
        if lengthUnit != nil {
            updateInputTextFields(textField: sender, lengthUnit: lengthUnit!)
        }
    }
    
    
    // Load last conversion from user defaults
    func loadLastConversion(){
        /// Read from user defaults
        let lastSavedConversion = UserDefaults.standard.value(forKey: UserDefaultsKeys.Length.LAST_LENGTH_CONVERSION_USER_DEFAULTS_KEY) as? [String]
        
        if lastSavedConversion?.count ?? 0 > 0 {
            
            // Setting the conversion to the input text fields
            millimetreInputTextField.text = lastSavedConversion![0]
            centimetreInputTextField.text = lastSavedConversion![1]
            inchInputTextField.text = lastSavedConversion![2]
            metreInputTextField.text = lastSavedConversion![3]
            kilometreInputTextField.text = lastSavedConversion![4]
            yardInputTextField.text = lastSavedConversion![5]
            mileInputTextField.text = lastSavedConversion![6]
            
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
            self.lengthMainStackTopConstraint.constant = self.lengthMainStackTopConstraintDefaultHeight
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
                
                let initialY = lengthScreenMainStackView.frame.origin.y + activeInputTextFieldSuperView.frame.origin.y + activeInputTextField.frame.origin.y
                
                
                if initialY > targetY {
                    let diff = targetY - initialY
                    let targetOffsetForTopConstraint = lengthMainStackTopConstraint.constant + diff
                    self.view.layoutIfNeeded()
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        self.lengthMainStackTopConstraint.constant = targetOffsetForTopConstraint
                        self.view.layoutIfNeeded()
                    })
                }
                
                var contentInset:UIEdgeInsets = self.lengthScreenScrollView.contentInset
                contentInset.bottom = keyboard.size.height
                lengthScreenScrollView.contentInset = contentInset
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
    
    /// listening which input was typed
    @IBAction func handleInputTextField(_ sender: UITextField) {
        
        checkWhichTextFieldPressed(sender: sender)
        checkAvailabilityRightBarButtons()
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
    
    /**
     Method returns a boolean after checking whether input fields are empty or not
     
     - Returns: Boolean
     
     */
    func isInputTextFieldEmpty() -> Bool {
        if !(millimetreInputTextField.text?.isEmpty)! && !(centimetreInputTextField.text?.isEmpty)! && !(metreInputTextField.text?.isEmpty)! && !(inchInputTextField.text?.isEmpty)! && !(kilometreInputTextField.text?.isEmpty)! && !(mileInputTextField.text?.isEmpty)!  && !(yardInputTextField.text?.isEmpty)!{
            return false
        }
        return true
    }
    
    /**
     Method will update the other length input fields
     
     -  Parameters: textField, lengthUnit of the changed method
     
     */
    func updateInputTextFields(textField: UITextField, lengthUnit: LengthMeasurementUnit) -> Void{
        if let input = textField.text{
            if input.isEmpty{
                
                ///Clear the input text fields when its empty
                clearTextFields(inputTextFields: lengthInputTextFields)
                
            }else{
                if let value = Double(input as String){
                    let length = Length(unit: lengthUnit, value: value)
                    
                    for _unit in LengthMeasurementUnit.getAvailableLengthUnits{
                        if _unit == lengthUnit{
                            continue
                        }
                        let textField = mapUnitToTextField(lengthUnit: _unit)
                        let result = length.convert(unit: _unit)
                        
                        /// Rounding off to 4 decimal places by default
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
    func mapUnitToTextField(lengthUnit: LengthMeasurementUnit) -> UITextField {
        var textField = millimetreInputTextField
        switch lengthUnit {
        case .millimetre:
            textField = millimetreInputTextField
        case .centimetre:
            textField = centimetreInputTextField
        case .inch:
            textField = inchInputTextField
        case .metre:
            textField = metreInputTextField
        case .mile:
            textField = mileInputTextField
        case .kilometre:
            textField = kilometreInputTextField
        case .yard:
            textField = yardInputTextField
        }
        return textField!
    }
    
    /**
     This function handle the save buttons' functionality which only can be save 5 conversions
     */
    @IBAction func handleSaveButton(_ sender: UIBarButtonItem) {
        if !isInputTextFieldEmpty(){
            let lastAddData = [millimetreInputTextField.text!, centimetreInputTextField.text!,inchInputTextField.text!,metreInputTextField.text!, kilometreInputTextField.text!,yardInputTextField.text!, mileInputTextField.text!] as [String]
            
            let conversion = "\(millimetreInputTextField.text!) mm = \(centimetreInputTextField.text!) cm = \(inchInputTextField.text!) inches = \(metreInputTextField.text!) m = \(mileInputTextField.text!) miles = \(yardInputTextField.text!) yards"
            
            /// Getting initial history data
            var lengthHistory = UserDefaults.standard.array(forKey: UserDefaultsKeys.Length.LENGTH_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            if (!checkConversionIsAlreadySaved(historyList: lengthHistory, conversion: conversion)){
                /// Check whether there are maximum amount of temperature conversions if so first value will be removed
                if lengthHistory.count >= UserDefaultsKeys.Length.LENGTH_CONVERSIONS_USER_DEFAULTS_MAX_COUNT {
                    lengthHistory = Array(lengthHistory.suffix(UserDefaultsKeys.Length.LENGTH_CONVERSIONS_USER_DEFAULTS_MAX_COUNT - 1))
                }
                lengthHistory.append(conversion)
                
                /// Add last added conversion
                UserDefaults.standard.set(lastAddData, forKey: UserDefaultsKeys.Length.LAST_LENGTH_CONVERSION_USER_DEFAULTS_KEY)
                
                /// Saving data in user defaults
                UserDefaults.standard.set(lengthHistory, forKey: UserDefaultsKeys.Length.LENGTH_CONVERSIONS_USER_DEFAULTS_KEY)
                
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: "Success", message: "The length conversion was successfully saved.")
                
            }else{
                /// showAlert method is defined in the  UIViewControllerHelper
                showAlert(title: "Warning", message: "The length conversion is already saved")
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
            clearTextFields(inputTextFields: lengthInputTextFields)
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
