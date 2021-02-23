//
//  TemperatureViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit

/// Temperature conversions are saved by type "temperature" in User defaults
let TEMPERATURE_CONVERSIONS_USER_DEFAULTS_KEY = "temperature"
private let TEMPERATURE_CONVERSIONS_USER_DEFAULTS_MAX_COUNT = 5

class TemperatureViewController: UIViewController {
    
    /// Defaults
    var activeInputTextField = UITextField()
    var temperatureMainStackTopConstraintDefaultHeight: CGFloat = 17.0
    var inputTextFieldKeyBoardGap = 20
    var keyBoardDefaultHeight:CGFloat = 0
    var decimalDigit = 4
    
    /// Used for keyboard handling - When user pressed auto scroll will be enable
    @IBOutlet weak var temperatureMainStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var temperatureScreenScrollView: UIScrollView!
    @IBOutlet weak var temperatureScreenMainStackView: UIStackView!
    
    /// Text input fields
    @IBOutlet weak var celsiusInputTextField: UITextField!
    @IBOutlet weak var fahrenheitInputTextField: UITextField!
    @IBOutlet weak var kelvinInputTextField: UITextField!
    
    /// Stack views for input fields
    @IBOutlet weak var celsiusStackView: UIStackView!
    @IBOutlet weak var fahrenheitStackView: UIStackView!
    @IBOutlet weak var kelvinStackView: UIStackView!
    
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
        var unit: TemperatureMeasurementUnit?
        
        if sender.tag == 1 {
            unit = TemperatureMeasurementUnit.celsius
        } else if sender.tag == 2 {
            unit = TemperatureMeasurementUnit.fahrenheit
        } else if sender.tag == 3 {
            unit = TemperatureMeasurementUnit.kelvin
        }
        
        if unit != nil {
            updateInputTextFields(textField: sender, temperatureUnit: unit!)
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
        if !(celsiusInputTextField.text?.isEmpty)! && !(fahrenheitInputTextField.text?.isEmpty)! && !(kelvinInputTextField.text?.isEmpty)! {
            return false
        }
        return true
    }
    
    /**
     Method will update the other temperature input fields
     
     -  Parameters: textField, temperatureUnit of the changed method
     
     */
    func updateInputTextFields(textField: UITextField, temperatureUnit: TemperatureMeasurementUnit) -> Void{
        if let input = textField.text{
            if input.isEmpty{
                
                ///Clear the input text fields when its empty
                clearTextFields()
                
            }else{
                if let value = Double(input as String){
                    let temperature = Temperature(unit: temperatureUnit, value: value)
                    
                    for _unit in TemperatureMeasurementUnit.getAvailableTemperatureUnits{
                        if _unit == temperatureUnit{
                            continue
                        }
                        let textField = mapUnitToTextField(temperatureUnit: _unit)
                        let result = temperature.convert(unit: _unit)
                        
                        // Rounding off to 4 decimal places by default
                        let roundedResult = result.truncate(places: self.decimalDigit)
                        
                        textField.text = String(roundedResult)
                    }
                }
            }
        }
    }
    
    /**
     This function maps value to temperature unit respectively
     - Parameters: temperatureUnit of the temperature that user input
     - Returns: Respective UITextField
     */
    func mapUnitToTextField(temperatureUnit: TemperatureMeasurementUnit) -> UITextField {
        var textField = celsiusInputTextField
        switch temperatureUnit {
        case .celsius:
            textField = celsiusInputTextField
        case .fahrenheit:
            textField = fahrenheitInputTextField
        case .kelvin:
            textField = kelvinInputTextField
        }
        return textField!
    }
    
    /**
     This function handle the save buttons' functionality which only can be save 5 conversions
     */
    @IBAction func handleSaveButton(_ sender: UIBarButtonItem) {
        if !isInputTextFieldEmpty(){
            let conversion = "\(celsiusInputTextField.text!) °C = \(fahrenheitInputTextField.text!) °F = \(kelvinInputTextField.text!) K"
            
            /// Getting initial history data
            var temperatureHistory = UserDefaults.standard.array(forKey: TEMPERATURE_CONVERSIONS_USER_DEFAULTS_KEY) as? [String] ?? []
            
            /// Check whether there are maximum amount of temperature conversions if so first value will be removed
            if temperatureHistory.count >= TEMPERATURE_CONVERSIONS_USER_DEFAULTS_MAX_COUNT {
                temperatureHistory = Array(temperatureHistory.suffix(TEMPERATURE_CONVERSIONS_USER_DEFAULTS_MAX_COUNT - 1))
            }
            temperatureHistory.append(conversion)
            
            /// Saving data in user defaults
            UserDefaults.standard.set(temperatureHistory, forKey: TEMPERATURE_CONVERSIONS_USER_DEFAULTS_KEY)
            
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
    
    /// This function clears all the text fields
    func clearTextFields() {
        celsiusInputTextField.text = ""
        fahrenheitInputTextField.text = ""
        kelvinInputTextField.text = ""
    }
}
