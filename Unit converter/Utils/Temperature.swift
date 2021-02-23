//
//  Temperature.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-22.
//

import Foundation

/// TemperatureMeasurementUnit enumeration is used to define the units
enum TemperatureMeasurementUnit {
    case celsius, fahrenheit, kelvin
    
    static let getAvailableTemperatureUnits = [celsius, fahrenheit, kelvin]
}

struct Temperature {
    let value: Double
    let unit: TemperatureMeasurementUnit
    
    init(unit: TemperatureMeasurementUnit, value: Double) {
        self.value = value
        self.unit = unit
    }
    
    /// This function will convert to all temperature units according to given unit
    func convert(unit to: TemperatureMeasurementUnit) -> Double {
        var output = 0.0
        
        switch unit {
        case .celsius:
            if to == .fahrenheit {
                output = (value * 9 / 5) + 32
            } else if to == .kelvin {
                output = value + 273.15
            }
        case .fahrenheit:
            if to == .celsius {
                output = (value - 32) * 5 / 9
            } else if to == .kelvin {
                output = ((value - 32) * 5 / 9) + 273.15
            }
        case .kelvin:
            if to == .celsius {
                output = value - 273.15
            } else if to == .fahrenheit {
                output = ((value - 273.15) * 9 / 5) + 32
            }
        }
        return output
    }
}
