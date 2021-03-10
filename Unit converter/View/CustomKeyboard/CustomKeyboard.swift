//
//  CustomKeyboard.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-14.
//

import UIKit

// Declares the methods needs to implement if the keyboard is used by a controller
@objc protocol CustomKeyboardDelegate {
    func customKeyboardNumericKeysHandle(key: Int)
    func customKeyboardBackspaceKeyHandle()
    func customKeyboardSymbolKeyHandle(symbol: String)
    func customKeyboardMinimusKeyHandle()
}

class CustomKeyboard: UIView {
    
    // Numeric Buttons
    @IBOutlet weak var numericButton0: UIButton!
    @IBOutlet weak var numericButton1: UIButton!
    @IBOutlet weak var numericButton2: UIButton!
    @IBOutlet weak var numericButton3: UIButton!
    @IBOutlet weak var numericButton4: UIButton!
    @IBOutlet weak var numericButton5: UIButton!
    @IBOutlet weak var numericButton6: UIButton!
    @IBOutlet weak var numericButton7: UIButton!
    @IBOutlet weak var numericButton8: UIButton!
    @IBOutlet weak var numericButton9: UIButton!
    
    // Minus and Period buttons
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var periodButton: UIButton!
    
    // Minimus and Backspace buttons
    @IBOutlet weak var minimusButton: UIButton!
    @IBOutlet weak var backspaceButton: UIButton!
    
    // Defining the array of buttons so that any effect can be done to every button
    var keyboardButtons: [UIButton] { return [numericButton0, numericButton1, numericButton2, numericButton3, numericButton4, numericButton5,numericButton6, numericButton7, numericButton8, numericButton9, minusButton, periodButton] }
    
    // Variable that could connect to the view controller and interaction
    weak var delegate: CustomKeyboardDelegate?
    
    
    // Variable that will set the default keyboard key colour
    var buttonDefaultKeyColor = UIColor.defaultKeyColor {
        // After keys are stored didSet will call and update the appearance
        didSet { updateButtonAppearance() }
    }
    // Variable that will set the default font colour in keyboard key
    var buttonDefaultFontColor = UIColor.white {
        // After keys are stored didSet will call and update the appearance
        didSet { updateButtonAppearance() }
    }
    
    
    // Variable that will set change the colour is clicked
    var buttonClickKeyColor = UIColor.pressedKeyColor {
        // After keys are stored didSet will call and update the appearance
        didSet { updateButtonAppearance() }
    }
    // Variable that will set change the font colour in keyboard key after click session
    var buttonClickFontColor = UIColor.white {
        // After key is stored didSet will call and update the appearance
        didSet { updateButtonAppearance() }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialiseKeyboard()
        // Check whether minus button needs to be enable
        NotificationCenter.default.addObserver(self, selector: #selector(enableMinusButton(notification:)),
                                               name: NSNotification.Name(rawValue: "enableMinus"), object: nil)
    }
    
    /// required is called to create the view from xib file
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialiseKeyboard()
    }
    
    func initialiseKeyboard() {
        let customKeyboardXibName = "CustomKeyboard"
        let view = Bundle.main.loadNibNamed(customKeyboardXibName, owner: self, options: nil)![0] as! UIView
        addSubview(view)
        view.frame = bounds
        
        updateButtonAppearance()
        
        // Disables minus button by default
        minusButton.isUserInteractionEnabled = false
    }
    
    
    /// This function is only accessibly in this .swift file only because of fileprivate this will update the button appearance
    fileprivate func updateButtonAppearance(){
        for key in keyboardButtons{
            key.setTitleColor(buttonDefaultFontColor, for: .normal)
            key.setTitleColor(buttonClickFontColor, for: [.selected, .highlighted])
            if key.isSelected{
                key.backgroundColor = buttonClickKeyColor
            }else{
                key.backgroundColor = buttonDefaultKeyColor
            }
        }
    }
    
    // This function enable the minus button
    @objc func enableMinusButton(notification: NSNotification){
        minusButton.isUserInteractionEnabled = true
    }
    
    // This function handles numeric on clicks
    @IBAction func handleNumericKeyOnClick(_ sender: UIButton) {
        // Setting the numeric key tags
        self.delegate?.customKeyboardNumericKeysHandle(key: sender.tag)
    }
    
    // This function handles symbol on clicks
    @IBAction func handleSymbolKeyOnClick(_ sender: UIButton) {
        // Setting the button label to symbol
        if let symbol =  sender.titleLabel?.text, symbol.count > 0{
            self.delegate?.customKeyboardSymbolKeyHandle(symbol: symbol)
        }
    }
    
    // This function handles backspace on clicks
    @IBAction func handleBackspaceOnClick(_ sender: UIButton) {
        self.delegate?.customKeyboardBackspaceKeyHandle()
    }
    
    // This function handles minimus on clicks
    @IBAction func handleMinimusOnClick(_ sender: UIButton) {
        self.delegate?.customKeyboardMinimusKeyHandle()
    }
    
}
