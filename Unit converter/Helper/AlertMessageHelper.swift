//
//  AlertMessageHelper.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-03-04.
//

import Foundation

enum AlertAction: String {
    case OK = "Ok"
}

struct Alert {
    struct Success {
        static let title = "Successfully Saved!"
        struct Weight {
            static let message = "The weight conversion was successfully saved in history.."
        }
        struct Temperature {
            static let message = "The temperature conversion was successfully saved in history."
        }
        struct Volume {
            static let message = "The volume conversion was successfully saved in history."
        }
        struct LiquidVolume {
            static let message = "The liquid volume conversion was successfully saved in history."
        }
        struct Length {
            static let message = "The length conversion was successfully saved in history."
        }
        struct Speed {
            static let message = "The speed conversion was successfully saved in history."
        }
    }
    
    struct Warning {
        static let title = "Warning!"
        struct Weight {
            static let message = "The weight conversion is already existing in the history."
        }
        struct Temperature {
            static let message = "The temperature conversion is already existing in the history."
        }
        struct Volume {
            static let message = "The volume conversion is already existing in the history."
        }
        struct LiquidVolume {
            static let message = "The liquid volume conversion is already existing in the history."
        }
        struct Length {
            static let message = "The length conversion is already existing in the history."
        }
        struct Speed {
            static let message = "The speed conversion is already existing in the history."
        }
        
    }
    
    struct Error {
        static let title = "Error!"
        static let message = "You are trying to save an empty conversion."
        
    }
}
