//
//  Weight.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-20.
//

import Foundation
import UIKit

/// WeightMeasurementUnit enumeration is used to define the units
enum WeightMeasurementUnit: MeasurementUnit {
    case kilogram, gram, ounce, pound, stone
    
    static let getAvailableWeightUnits = [gram, kilogram, ounce, pound, stone]
}

struct Weight {
    
    let value: Double
    let unit: WeightMeasurementUnit
    
    init(unit: WeightMeasurementUnit, value: Double) {
        self.value = value
        self.unit = unit
    }
    
    /// This function will convert to all weight measurement units according to the given unit
    func convert(unit to: WeightMeasurementUnit) -> Double {
        var output = 0.0
        switch unit {
        case .kilogram:
            if to == .gram {
                output = value * 1000
            } else if to == .ounce {
                output = value * 35.274
            } else if to == .pound {
                output = value * 2.205
            } else if to == .stone {
                output = value / 6.35
            }
        case .gram:
            if to == .kilogram {
                output = value / 1000
            } else if to == .ounce {
                output = value / 28.35
            } else if to == .pound {
                output = value / 454
            } else if to == .stone {
                output = value / 6350
            }
        case .ounce:
            if to == .kilogram {
                output = value / 35.274
            } else if to == .gram {
                output = value * 28.35
            } else if to == .pound {
                output = value / 16
            } else if to == .stone {
                output = value / 224
            }
        case .pound:
            if to == .kilogram {
                output = value / 2.205
            } else if to == .gram {
                output = value * 454
            } else if to == .ounce {
                output = value * 16
            } else if to == .stone {
                output = value / 14
            }
        case .stone:
            if to == .kilogram {
                output = value * 6.35
            } else if to == .gram {
                output = value * 6350
            } else if to == .pound {
                output = value *  14
            } else if to == .ounce {
                output = value * 224
            }
        }
        
        return output
    }
    
    static func weightConversion(inputFields:[UITextField]) -> String {
        return "\(inputFields[0].text ?? "0") g = \(inputFields[1].text ?? "0") kg = \(inputFields[2].text ?? "0") oz = \(inputFields[3].text ?? "0") lb = \(inputFields[4].text ?? "0") stones & \(inputFields[5].text ?? "0") pounds"
    }
    
}
