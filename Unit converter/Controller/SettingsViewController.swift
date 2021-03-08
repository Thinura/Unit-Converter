//
//  SettingsViewController.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-13.
//

import UIKit
import DropDown

//let DECIMAL_DIGIT_USER_DEFAULTS_KEY = "decimal"

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var buttonSelectorDecimal: UIButton!
    
    let decimalSelector = DropDown()
    var decimal =  DecimalSelector.defaultDecimalDigit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Reading from user defaults
        let decimalDigit = UserDefaults.standard.value(forKey: UserDefaultsKeys.Settings.DECIMAL_DIGIT_USER_DEFAULTS_KEY) as? String
        if (decimalDigit != nil){
            self.decimal = Int(decimalDigit!) ?? 0
        }
        
        buttonSelectorDecimal.setTitle(String(self.decimal), for: .normal)
    }
    
    @IBAction func onClickSelectorDecimal(_ sender: UIButton) {
        decimalSelector.dataSource = DecimalSelector.numberOfDecimals//3
        decimalSelector.anchorView = sender
        decimalSelector.bottomOffset = CGPoint(x: 0, y: sender.frame.size.height)
        decimalSelector.show()
        decimalSelector.selectionAction = { [weak self] (index: Int, item: String) in //8
            guard let _ = self else { return }
            
            self!.decimal =  Int(item) ?? 0

            /// Saving data in user defaults
            UserDefaults.standard.set(item, forKey: UserDefaultsKeys.Settings.DECIMAL_DIGIT_USER_DEFAULTS_KEY)
            sender.setTitle(item, for: .normal) //9
        }
        
    }
    
}
