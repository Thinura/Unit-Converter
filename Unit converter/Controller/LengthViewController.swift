//
//  LengthViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

/// Length conversions are saved by type "length" in User defaults
let LENGTH_CONVERSIONS_USER_DEFAULTS_KEY = "length"
private let LENGTH_CONVERSIONS_USER_DEFAULTS_MAX_COUNT = 5

class LengthViewController: UIViewController {
    
    /// Defaults
    var activeInputTextField = UITextField()
    var lengthMainStackTopConstraintDefaultHeight: CGFloat = 17.0
    var inputTextFieldKeyBoardGap = 20
    var keyBoardDefaultHeight:CGFloat = 0
    var decimalDigit = 4
    
    /// Used for keyboard handling - When user pressed auto scroll will be enable
    @IBOutlet weak var lengthMainStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lengthScreenScrollView: UIScrollView!
    @IBOutlet weak var speedScreenMainStackView: UIStackView!
    
    /// Text input fields
    @IBOutlet weak var millimetreInputTextField: UITextField!
    @IBOutlet weak var centimetreInputTextField: UITextField!
    @IBOutlet weak var inchInputTextField: UITextField!
    @IBOutlet weak var metreInputTextField: UITextField!
    @IBOutlet weak var kilometreInputTextField: UITextField!
    @IBOutlet weak var mileInputTextField: UITextField!
    @IBOutlet weak var yardInputTextField: UITextField!
    
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
        
        ///After loading checking whether the input fields are empty or not
        checkAvailabilityRightBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Reading from user defaults
        let decimal = UserDefaults.standard.value(forKey: DECIMAL_DIGIT_USER_DEFAULTS_KEY) as? String
        
        if (decimal != nil){
            self.decimalDigit = Int(decimal!) ?? 0
        }
    }
    
    
    /// listening which input was typed
    @IBAction func handleInputTextField(_ sender: UITextField) {
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
        
        checkAvailabilityRightBarButton()
    }
    
    /// Checking whether the input is field is empty if so save button needs to be disabled
    func checkAvailabilityRightBarButton() {
        if isInputTextFieldEmpty() {
            self.navigationItem.rightBarButtonItem!.isEnabled = false;
        } else {
            self.navigationItem.rightBarButtonItem!.isEnabled = true;
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
                clearTextFields()
                
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
    
    /// This function clears all the text fields
    func clearTextFields() {
        millimetreInputTextField.text = ""
        centimetreInputTextField.text = ""
        inchInputTextField.text = ""
        metreInputTextField.text = ""
        kilometreInputTextField.text = ""
        yardInputTextField.text = ""
        mileInputTextField.text = ""
    }
    
    /**
     This function handle the save buttons' functionality which only can be save 5 conversions
     */
    @IBAction func handleSaveButton(_ sender: UIBarButtonItem) {
        if !isInputTextFieldEmpty(){
            let conversion = "\(mileInputTextField.text!) mm = \(centimetreInputTextField.text!) cm = \(inchInputTextField.text!) inches = \(metreInputTextField.text!) m = \(mileInputTextField.text!) miles = \(yardInputTextField.text!) yards"
            
            /// Getting initial history data
            var lengthHistory = UserDefaults.standard.array(forKey: SPEED_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            /// Check whether there are maximum amount of temperature conversions if so first value will be removed
            if lengthHistory.count >= LENGTH_CONVERSIONS_USER_DEFAULTS_MAX_COUNT {
                lengthHistory = Array(lengthHistory.suffix(LENGTH_CONVERSIONS_USER_DEFAULTS_MAX_COUNT - 1))
            }
            lengthHistory.append(conversion)
            
            /// Saving data in user defaults
            UserDefaults.standard.set(lengthHistory, forKey: LENGTH_CONVERSIONS_USER_DEFAULTS_KEY)
            
            /// Initialising success alert
            let alert = UIAlertController(title: "Success", message: "The temperature conversion was successfully saved!", preferredStyle: UIAlertController.Style.alert)
            
            /// Defining the alert action
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            /// Initialising alert to the view
            self.present(alert, animated: true, completion: nil)
            
        }else{
            
            ///Initialising error alert
            let alert = UIAlertController(title: "Error", message: "You are trying to save an empty conversion!", preferredStyle: UIAlertController.Style.alert)
            
            /// Defining the alert action
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            /// Initialising alert to the view
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
}
