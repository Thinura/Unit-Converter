//
//  WeightViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit



class WeightViewController: UIViewController, CustomKeyboardDelegate {
    
    /// Defaults
    var activeInputTextField = UITextField()
    var weightMainStackTopConstraintDefaultHeight: CGFloat = 17.0
    var inputTextFieldKeyBoardGap = 20
    var keyBoardDefaultHeight:CGFloat = 0
    var decimalDigit = 4
    
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
    var weightInputTextFields: [UITextField] { return [kilogramInputTextField, gramInputTextField, ounceInputField, poundInputField, spStoneInputField, spPoundInputField]}
    ///Stack views for Input Fields
    @IBOutlet weak var kilogramStackView: UIStackView!
    @IBOutlet weak var gramStackView: UIStackView!
    @IBOutlet weak var ounceStackView: UIStackView!
    @IBOutlet weak var poundStackView: UIStackView!
    @IBOutlet weak var stonePoundStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(keyWillHide)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        settingUpCustomKeyboard()
        
        settingUpDecimal()
    }
    
    // Load last conversion from user defaults
    func loadLastConversion(){
        /// Read from user defaults
        let lastSavedConversion = UserDefaults.standard.value(forKey: UserDefaultsKeys.Weight.LAST_WEIGHT_CONVERSION_USER_DEFAULTS_KEY) as? [String]
        
        if lastSavedConversion?.count ?? 0 > 0 {
            
            // Setting the conversion to the input text fields
            kilogramInputTextField.text = lastSavedConversion![0]
            gramInputTextField.text = lastSavedConversion![1]
            ounceInputField.text = lastSavedConversion![2]
            poundInputField.text = lastSavedConversion![3]
            spStoneInputField.text = lastSavedConversion![4]
            spPoundInputField.text = lastSavedConversion![5]
            
        }
        
    }
    
    /// This function setting up the custom keyboard
    func settingUpCustomKeyboard() {
        
        // Setting up the custom keyboard with the text input fields
        kilogramInputTextField.initializeCustomKeyboard(delegate: self)
        gramInputTextField.initializeCustomKeyboard(delegate: self)
        ounceInputField.initializeCustomKeyboard(delegate: self)
        poundInputField.initializeCustomKeyboard(delegate: self)
        spStoneInputField.initializeCustomKeyboard(delegate: self)
        
        spPoundInputField.initializeCustomKeyboard(delegate: self)
        spPoundInputField.isUserInteractionEnabled = false // disable the interactivity pound is already on the input text
        
        //Listening to keyboard show events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    /// This function read the decimal digit from user defaults
    func settingUpDecimal() {
        /// Reading from user defaults
        let userDefaultDecimalDigit = UserDefaults.standard.value(forKey: UserDefaultsKeys.Settings.DECIMAL_DIGIT_USER_DEFAULTS_KEY) as? NSString
        // Default value will be set to 4 decimal points
        let decimal = ((userDefaultDecimalDigit ?? DecimalSelector.defaultDecimal as NSString) as NSString).integerValue
        
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
            checkWhichTextFieldPressed(sender:kilogramInputTextField)
            
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
            self.weightMainStackTopConstraint.constant = self.weightMainStackTopConstraintDefaultHeight
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
            
            var activeInputTextFieldSuperView = activeInputTextField.superview!
            if activeInputTextField.tag == 5 || activeInputTextField.tag == 6{
                activeInputTextFieldSuperView = activeInputTextField.superview!.superview!
            }
            
            if let info = notification.userInfo{
                let keyboard:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
                
                let targetY = view.frame.size.height - keyboard.height - 15 - activeInputTextField.frame.size.height
                
                let initialY = weightScreenMainStackView.frame.origin.y + activeInputTextFieldSuperView.frame.origin.y + activeInputTextField.frame.origin.y
                
                
                if initialY > targetY {
                    let diff = targetY - initialY
                    let targetOffsetForTopConstraint = weightMainStackTopConstraint.constant + diff
                    self.view.layoutIfNeeded()
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        self.weightMainStackTopConstraint.constant = targetOffsetForTopConstraint
                        self.view.layoutIfNeeded()
                    })
                }
                
                var contentInset:UIEdgeInsets = self.weightScreenScrollView.contentInset
                contentInset.bottom = keyboard.size.height
                weightScreenScrollView.contentInset = contentInset
            }
        }
    }
    
    
    /// listening which input was typed 
    @IBAction func handleInputTextField(_ sender: UITextField) {
        
        checkWhichTextFieldPressed(sender: sender)
        checkAvailabilityRightBarButtons()
        
    }
    
    
    func checkWhichTextFieldPressed(sender:UITextField){
        var weightUnit: WeightMeasurementUnit?
        
        /// Checking whether which input field is pressed
        if sender.tag == 1 {
            weightUnit = WeightMeasurementUnit.kilogram
        } else if sender.tag == 2 {
            weightUnit = WeightMeasurementUnit.gram
        } else if sender.tag == 3 {
            weightUnit = WeightMeasurementUnit.ounce
        } else if sender.tag == 4 {
            weightUnit = WeightMeasurementUnit.pound
        } else if sender.tag == 5 {
            weightUnit = WeightMeasurementUnit.stone
        } else if sender.tag == 6 {
            weightUnit = WeightMeasurementUnit.stone
        }
        if weightUnit != nil {
            updateInputTextFields(textField: sender, weightUnit: weightUnit!)
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
        if !(kilogramInputTextField.text?.isEmpty)! && !(gramInputTextField.text?.isEmpty)! && !(ounceInputField.text?.isEmpty)! && !(poundInputField.text?.isEmpty)! &&
            !(spStoneInputField.text?.isEmpty)! && !(spPoundInputField.text?.isEmpty)!{
            return false
        }
        return true
    }
    
    /**
     Method will update the other weight input fields
     
     -  Parameters: textField, weightUnit of the changed method
     
     */
    func updateInputTextFields(textField: UITextField, weightUnit: WeightMeasurementUnit) -> Void{
        if let input = textField.text {
            if input.isEmpty {
                
                ///Clear the input text fields when its empty
                clearTextFields(inputTextFields: weightInputTextFields)
                
            } else {
                
                if let value = Double(input as String) {
                    let weight = Weight(unit: weightUnit, value: value)
                    
                    for _unit in WeightMeasurementUnit.getAvailableWeightUnits {
                        if _unit == weightUnit {
                            continue
                        }
                        let textField = mapUnitToTextField(weightUnit: _unit)
                        let result = weight.convert(unit: _unit)
                        
                        /// Rounding off to 4 decimal places by default
                        let roundedResult = result.truncate(places: self.decimalDigit)
                        
                        textField.text = String(roundedResult)
                        separateStonePounds()
                    }
                }
            }
        }
    }
    
    /// This function clears all the text fields
    func clearTextFields(inputTextFields:[UITextField]) {
        for textInputField in inputTextFields{
            textInputField.text = ""
        }
        checkAvailabilityRightBarButtons()
    }
    
    /**
     This function maps value to weight unit respectively
     - Parameters: weightUnit of the weight that user input
     - Returns: Respective UITextField
     */
    func mapUnitToTextField(weightUnit: WeightMeasurementUnit) -> UITextField {
        var textField = kilogramInputTextField
        switch weightUnit {
        case .kilogram:
            textField = kilogramInputTextField
        case .gram:
            textField = gramInputTextField
        case .ounce:
            textField = ounceInputField
        case .pound:
            textField = poundInputField
        case .stone:
            textField = spStoneInputField
        }
        return textField!
    }
    
    /// This function separate the decimal in stone and add it to the pounds section
    func separateStonePounds(){
        if let spStoneTextField = spStoneInputField.text {
            if let value = Double(spStoneTextField as String) {
                let integerPart = Int(value)
                let decimalPart = value.truncatingRemainder(dividingBy: 1)
                let poundValue = decimalPart * 14
                
                spStoneInputField.text = String(integerPart)
                spPoundInputField.text = String(Double(round(10000 * poundValue) / 10000))
            }
        }
    }
    
    /**
     This function handle the save buttons' functionality which only can be save 5 conversions
     */
    @IBAction func handleSaveButton(_ sender: UIBarButtonItem) {
        if !isInputTextFieldEmpty(){
            let lastAddData = [kilogramInputTextField.text!, gramInputTextField.text!,ounceInputField.text!,poundInputField.text!,spStoneInputField.text!,spPoundInputField.text!] as [String]
            
            let conversion = "\(gramInputTextField.text!) g = \(kilogramInputTextField.text!) kg = \(ounceInputField.text!) oz =  \(poundInputField.text!) lb = \(spStoneInputField.text!)  stones & \(spPoundInputField.text!) pounds"
            
            /// Getting initial history data
            var weightHistory = UserDefaults.standard.array(forKey: UserDefaultsKeys.Weight.WEIGHT_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            if (!checkConversionIsAlreadySaved(historyList: weightHistory, conversion: conversion)){
                /// Check whether there are maximum amount of weight conversions if so first value will be removed
                if weightHistory.count >= UserDefaultsKeys.Weight.WEIGHT_CONVERSIONS_USER_DEFAULTS_MAX_COUNT {
                    weightHistory = Array(weightHistory.suffix(UserDefaultsKeys.Weight.WEIGHT_CONVERSIONS_USER_DEFAULTS_MAX_COUNT - 1))
                }
                weightHistory.append(conversion)
                
                /// Add last added conversion
                UserDefaults.standard.set(lastAddData, forKey: UserDefaultsKeys.Weight.LAST_WEIGHT_CONVERSION_USER_DEFAULTS_KEY)
                
                /// Saving data in user defaults
                UserDefaults.standard.set(weightHistory, forKey: UserDefaultsKeys.Weight.WEIGHT_CONVERSIONS_USER_DEFAULTS_KEY)
                
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
    
    func checkConversionIsAlreadySaved(historyList:[String],conversion:String)->Bool{
        for historyListConversion in historyList {
            if (historyListConversion == conversion){
                return true
            }
        }
        return false
    }
    
    @IBAction func inputTextFieldsResetButton(_ sender: UIBarButtonItem) {
        if !isInputTextFieldEmpty(){
            ///Clear the input text fields when its empty
            clearTextFields(inputTextFields: weightInputTextFields)
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
