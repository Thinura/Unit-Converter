//
//  LiquidVolumeViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

/// Liquid volume conversions are saved by type "liquidVolume" in User defaults
let LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_KEY = "liquidVolume"
private let LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_MAX_COUNT = 5

class LiquidVolumeViewController: UIViewController {
    
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
    
    /// Stack views for Input Fields
    @IBOutlet weak var litreStackView: UIStackView!
    @IBOutlet weak var millilitreStackView: UIStackView!
    @IBOutlet weak var ukGallonStackView: UIStackView!
    @IBOutlet weak var ukPintStackView: UIStackView!
    @IBOutlet weak var ukFluidOunceStackView: UIStackView!
    
    
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
    
    /// Checking whether the input is field is empty if so save button needs to be disabled
    func checkAvailabilityRightBarButton() {
        if isInputTextFieldEmpty() {
            self.navigationItem.rightBarButtonItem!.isEnabled = false;
        } else {
            self.navigationItem.rightBarButtonItem!.isEnabled = true;
        }
    }
    
    @IBAction func handleInputTextField(_ sender: UITextField) {
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
        
        checkAvailabilityRightBarButton()
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
    
    /// This function clears all the text fields
    func clearTextFields() {
        litreInputTextField.text = ""
        millilitreInputTextField.text = ""
        ukGallonInputTextField.text = ""
        ukPintInputTextField.text = ""
        ukFluidOunceInputTextField.text = ""
    }
    
    /**
     This function maps value to liquid volume unit respectively
     - Parameters: liquidVolumeUnit of the weight that user input
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
     
     -  Parameters: textField, weightUnit of the changed method
     
     */
    func updateInputTextFields(textField: UITextField, liquidVolumeUnit: LiquidVolumeMeasurementUnit) -> Void{
        if let input = textField.text {
            if input.isEmpty {
                
                ///Clear the input text fields when its empty
                clearTextFields()
                
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
            let conversion = "\(litreInputTextField.text!) ℓ = \(millilitreInputTextField.text!) mℓ = \(ukGallonInputTextField.text!) gal = \(ukPintInputTextField.text!) pints = \(ukFluidOunceInputTextField.text!) fl oz"
            
            /// Getting initial history data
            var liquidVolumeHistory = UserDefaults.standard.array(forKey: LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            /// Check whether there are maximum amount of weight conversions if so first value will be removed
            if liquidVolumeHistory.count >= LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_MAX_COUNT {
                liquidVolumeHistory = Array(liquidVolumeHistory.suffix(LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_MAX_COUNT - 1))
            }
            liquidVolumeHistory.append(conversion)
            
            /// Saving data in user defaults
            UserDefaults.standard.set(liquidVolumeHistory, forKey: LIQUID_VOLUME_CONVERSIONS_USER_DEFAULTS_KEY)
            
            /// Initialising success alert
            let alert = UIAlertController(title: "Success", message: "The weight conversion was successfully saved!", preferredStyle: UIAlertController.Style.alert)
            
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

