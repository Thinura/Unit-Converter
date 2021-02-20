//
//  WeightViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

/// Weight conversions are saved by type "weight" in User defaults
let WEIGHT_CONVERSIONS_USER_DEFAULTS_KEY = "weight"
private let WEIGHT_CONVERSIONS_USER_DEFAULTS_MAX_COUNT = 5


class WeightViewController: UIViewController {
    
    /// Defaults
    var activeInputTextField = UITextField()
    var weightMainStackTopConstraintDefaultHeight: CGFloat = 17.0
    var inputTextFieldKeyBoardGap = 20
    var keyBoardDefaultHeight:CGFloat = 0
    
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
    
    ///Stack views for Input Fields
    @IBOutlet weak var kilogramStackView: UIStackView!
    @IBOutlet weak var gramStackView: UIStackView!
    @IBOutlet weak var ounceStackView: UIStackView!
    @IBOutlet weak var poundStackView: UIStackView!
    @IBOutlet weak var stonePoundStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if isInputTextFieldEmpty(){
            self.navigationItem.rightBarButtonItem!.isEnabled = false
        }
    }
    
    //override func viewWillAppear(_ animated: Bool) {
    //}

    @IBAction func handleInputTextField(_ sender: UITextField) {
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
                clearTextFields()
            } else {
                if let value = Double(input as String) {
                    let weight = Weight(unit: weightUnit, value: value)
                    
                    for _unit in WeightMeasurementUnit.getAvailableWeightUnits {
                        if _unit == weightUnit {
                            continue
                        }
                        let textField = mapUnitToTextField(weightUnit: _unit)
                        let result = weight.convert(unit: _unit)
                        
                        //rounding off to 4 decimal places
                        let roundedResult = Double(round(10000 * result) / 10000)
                        
                        textField.text = String(roundedResult)
                        separateStonePounds()
                    }
                }
            }
        }
    }
    
    /// This function clears all the text fields
    func clearTextFields() {
        kilogramInputTextField.text = ""
        gramInputTextField.text = ""
        ounceInputField.text = ""
        poundInputField.text = ""
        spPoundInputField.text = ""
        spStoneInputField.text = ""
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
        if let textFieldVal = spStoneInputField.text {
            if let value = Double(textFieldVal as String) {
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
            let conversion = "\(gramInputTextField.text!) g = \(kilogramInputTextField.text!) kg = \(ounceInputField.text!) oz =  \(poundInputField.text!) lb = \(spStoneInputField.text!) stones & \(spPoundInputField.text!) pounds"
            
            /// Getting initial history data
            var weightHistory = UserDefaults.standard.array(forKey: WEIGHT_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            /// Check whether there are maximum amount of weight conversions if so first value will be removed 
            if weightHistory.count >= WEIGHT_CONVERSIONS_USER_DEFAULTS_MAX_COUNT {
                weightHistory = Array(weightHistory.suffix(WEIGHT_CONVERSIONS_USER_DEFAULTS_MAX_COUNT - 1))
            }
            weightHistory.append(conversion)
            
            UserDefaults.standard.set(weightHistory, forKey: WEIGHT_CONVERSIONS_USER_DEFAULTS_KEY)
            
            let alert = UIAlertController(title: "Success", message: "The weight conversion was successully saved!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Error", message: "You are trying to save an empty conversion!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}


extension Float {
    var cleanValue: String
    {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
