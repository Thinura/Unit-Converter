//
//  LiquidVolumeViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

class LiquidVolumeViewController: UIViewController, CustomKeyboardDelegate {
    
    /// Defaults
    var activeInputTextField = UITextField()
    var liquidVolumeMainStackTopConstraintDefaultHeight: CGFloat = 17.0
    var inputTextFieldKeyBoardGap = 20
    var keyBoardDefaultHeight:CGFloat = 0
    var decimalDigit = 4
    
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
        litreInputTextField.initializeCustomKeyboard(delegate: self)
        millilitreInputTextField.initializeCustomKeyboard(delegate: self)
        ukGallonInputTextField.initializeCustomKeyboard(delegate: self)
        ukPintInputTextField.initializeCustomKeyboard(delegate: self)
        ukFluidOunceInputTextField.initializeCustomKeyboard(delegate: self)
        
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
            checkWhichTextFieldPressed(sender:litreInputTextField)
            
        }
    }
    
    func checkWhichTextFieldPressed(sender:UITextField){
        var liquidVolumeUnit: LiquidVolumeMeasurementUnit?
        
        /// Checking whether which input field is pressed
        if sender.tag == 1 {
            liquidVolumeUnit = LiquidVolumeMeasurementUnit.litre
        } else if sender.tag == 2 {
            liquidVolumeUnit = LiquidVolumeMeasurementUnit.millilitre
        } else if sender.tag == 3 {
            liquidVolumeUnit = LiquidVolumeMeasurementUnit.ukGallon
        } else if sender.tag == 4 {
            liquidVolumeUnit = LiquidVolumeMeasurementUnit.ukPint
        } else if sender.tag == 5 {
            liquidVolumeUnit = LiquidVolumeMeasurementUnit.ukFluidOunce
        }
        
        if liquidVolumeUnit != nil {
            updateInputTextFields(textField: sender, liquidVolumeUnit: liquidVolumeUnit!)
        }
    }
    
    // Load last conversion from user defaults
    func loadLastConversion(){
        /// Read from user defaults
        let lastSavedConversion = UserDefaults.standard.value(forKey: UserDefaultsKeys.LiquidVolume.LAST_LIQUID_VOLUME_CONVERSION_USER_DEFAULTS_KEY) as? [String]
        
        if lastSavedConversion?.count ?? 0 > 0 {
            
            // Setting the conversion to the input text fields
            litreInputTextField.text = lastSavedConversion![0]
            millilitreInputTextField.text = lastSavedConversion![1]
            ukGallonInputTextField.text = lastSavedConversion![2]
            ukPintInputTextField.text = lastSavedConversion![3]
            ukFluidOunceInputTextField.text = lastSavedConversion![4]
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
            self.liquidVolumeMainStackTopConstraint.constant = self.liquidVolumeMainStackTopConstraintDefaultHeight
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
                
                let initialY = liquidVolumeMainStack.frame.origin.y + activeInputTextFieldSuperView.frame.origin.y + activeInputTextField.frame.origin.y
                
                
                if initialY > targetY {
                    let diff = targetY - initialY
                    let targetOffsetForTopConstraint = liquidVolumeMainStackTopConstraint.constant + diff
                    self.view.layoutIfNeeded()
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        self.liquidVolumeMainStackTopConstraint.constant = targetOffsetForTopConstraint
                        self.view.layoutIfNeeded()
                    })
                }
                
                var contentInset:UIEdgeInsets = self.liquidVolumeScreenScrollView.contentInset
                contentInset.bottom = keyboard.size.height
                liquidVolumeScreenScrollView.contentInset = contentInset
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
    
    /**
     Method returns a boolean after checking whether input fields are empty or not
     
     - Returns: Boolean
     
     */
    func isInputTextFieldEmpty() -> Bool {
        if !(litreInputTextField.text?.isEmpty)! && !(millilitreInputTextField.text?.isEmpty)! && !(ukGallonInputTextField.text?.isEmpty)! && !(ukPintInputTextField.text?.isEmpty)! &&
            !(ukFluidOunceInputTextField.text?.isEmpty)! {
            return false
        }
        return true
    }
    
    /**
     This function maps value to liquid volume unit respectively
     - Parameters: liquidVolumeUnit of the liquid volume that user input
     - Returns: Respective UITextField
     */
    func mapUnitToTextField(liquidVolumeUnit: LiquidVolumeMeasurementUnit) -> UITextField {
        var textField = millilitreInputTextField
        switch liquidVolumeUnit {
        case .millilitre:
            textField = millilitreInputTextField
        case .litre:
            textField = litreInputTextField
        case .ukGallon:
            textField = ukGallonInputTextField
        case .ukPint:
            textField = ukPintInputTextField
        case .ukFluidOunce:
            textField = ukFluidOunceInputTextField
        }
        return textField!
    }
    
    
    /**
     Method will update the other liquid volume input fields
     
     -  Parameters: textField, liquidVolumeUnit of the changed method
     
     */
    func updateInputTextFields(textField: UITextField, liquidVolumeUnit: LiquidVolumeMeasurementUnit) -> Void{
        if let input = textField.text {
            if input.isEmpty {
                
                ///Clear the input text fields when its empty
                clearTextFields(inputTextFields: liquidVolumeInputTextFields)
                
            } else {
                
                if let value = Double(input as String) {
                    let liquidVolume = LiquidVolume(unit: liquidVolumeUnit, value: value)
                    
                    for _unit in LiquidVolumeMeasurementUnit.getAvailableLiquidVolumeUnits {
                        if _unit == liquidVolumeUnit {
                            continue
                        }
                        let textField = mapUnitToTextField(liquidVolumeUnit: _unit)
                        let result = liquidVolume.convert(unit: _unit)
                        
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
            
            let lastAddData = [litreInputTextField.text!, millilitreInputTextField.text!,ukGallonInputTextField.text!,ukPintInputTextField.text!,ukFluidOunceInputTextField.text!] as [String]
            
            
            let conversion = "\(litreInputTextField.text!) ℓ = \(millilitreInputTextField.text!) mℓ = \(ukGallonInputTextField.text!) gal = \(ukPintInputTextField.text!) pints = \(ukFluidOunceInputTextField.text!) fl oz"
            
            /// Getting initial history data
            var liquidVolumeHistory = UserDefaults.standard.array(forKey: UserDefaultsKeys.LiquidVolume.LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            if (!checkConversionIsAlreadySaved(historyList: liquidVolumeHistory, conversion: conversion)){
                
                /// Check whether there are maximum amount of liquid volume conversions if so first value will be removed
                if liquidVolumeHistory.count >= UserDefaultsKeys.LiquidVolume.LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_MAX_COUNT {
                    liquidVolumeHistory = Array(liquidVolumeHistory.suffix(UserDefaultsKeys.LiquidVolume.LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_MAX_COUNT - 1))
                }
                liquidVolumeHistory.append(conversion)
                
                /// Add last added conversion
                UserDefaults.standard.set(lastAddData, forKey: UserDefaultsKeys.LiquidVolume.LAST_LIQUID_VOLUME_CONVERSION_USER_DEFAULTS_KEY)
                
                /// Saving data in user defaults
                UserDefaults.standard.set(liquidVolumeHistory, forKey: UserDefaultsKeys.LiquidVolume.LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_KEY)
                
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
            clearTextFields(inputTextFields: liquidVolumeInputTextFields)
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

