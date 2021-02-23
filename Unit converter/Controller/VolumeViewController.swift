//
//  VolumeViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

/// Volume conversions are saved by type "volume" in User defaults
let VOLUME_CONVERSIONS_USER_DEFAULTS_KEY = "volume"
private let VOLUME_CONVERSIONS_USER_DEFAULTS_MAX_COUNT = 5

class VolumeViewController: UIViewController {
    
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
    
    /// Stack views for Input Fields
    @IBOutlet weak var cuMillimetreStackView: UIStackView!
    @IBOutlet weak var cuCentimetreStackView: UIStackView!
    @IBOutlet weak var cuMetreStackView: UIStackView!
    @IBOutlet weak var cuInchStackView: UIStackView!
    @IBOutlet weak var cuFootStackView: UIStackView!
    @IBOutlet weak var cuYardStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///After loading checking whether the input fields are empty or not
        checkAvailabilityRightBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
        }
        else {
            self.navigationItem.rightBarButtonItem!.isEnabled = true;
        }
    }
    
    
    @IBAction func handleInputTextField(_ sender: UITextField) {
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
        
        checkAvailabilityRightBarButton()
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
    
    /// This function clears all the text fields
    func clearTextFields() {
        cuMillimetreInputTextField.text = ""
        cuCentimetreInputTextField.text = ""
        cuInchInputTextField.text = ""
        cuMetreInputTextField.text = ""
        cuFootInputTextField.text = ""
        cuYardInputTextField.text = ""
    }
    
    /**
     This function maps value to weight unit respectively
     - Parameters: volumeUnit of the weight that user input
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
                clearTextFields()
                
            } else {
                
                if let value = Double(input as String) {
                    let weight = Volume(unit: volumeUnit, value: value)
                    
                    for _unit in VolumeMeasurementUnit.getAvailableVolumeUnits {
                        if _unit == volumeUnit {
                            continue
                        }
                        let textField = mapUnitToTextField(volumeUnit: _unit)
                        let result = weight.convert(unit: _unit)
                        
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
            let conversion = "\(cuMillimetreInputTextField.text!) cu mm = \(cuCentimetreInputTextField.text!) cu cm = \(cuMetreInputTextField.text!) cu m = \(cuInchInputTextField.text!) cu in = \(cuFootInputTextField.text!) cu ft = \(cuYardInputTextField.text!) cu yd"
            
            /// Getting initial history data
            var volumeHistory = UserDefaults.standard.array(forKey: VOLUME_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            /// Check whether there are maximum amount of volume conversions if so first value will be removed
            if volumeHistory.count >= VOLUME_CONVERSIONS_USER_DEFAULTS_MAX_COUNT {
                volumeHistory = Array(volumeHistory.suffix(VOLUME_CONVERSIONS_USER_DEFAULTS_MAX_COUNT - 1))
            }
            volumeHistory.append(conversion)
            
            /// Saving data in user defaults
            UserDefaults.standard.set(volumeHistory, forKey: VOLUME_CONVERSIONS_USER_DEFAULTS_KEY)
            
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
