//
//  Speed.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-23.
//

import Foundation
import UIKit

/// SpeedMeasurementUnit enumeration is used to define the units
enum SpeedMeasurementUnit: MeasurementUnit {
    case metresSecond, kilometreHour, milesHour, knot
    
    static let getAvailableSpeedUnits = [metresSecond, kilometreHour, milesHour, knot]
}

struct Speed {
    let value: Double
    let unit: SpeedMeasurementUnit
    
    init(unit: SpeedMeasurementUnit, value: Double) {
        self.value = value
        self.unit = unit
    }
    
    func convert(unit to: SpeedMeasurementUnit) -> Double {
        var output = 0.0
        
        switch unit {
        case .metresSecond:
            if to == .kilometreHour {
                output = value * 3.6
            } else if to == .milesHour {
                output = value * 2.237
            } else if to == .knot {
                output = value * 1.944
            }
        case .kilometreHour:
            if to == .metresSecond {
                output = value / 3.6
            } else if to == .milesHour {
                output = value / 1.609
            } else if to == .knot {
                output = value / 1.852
            }
        case .milesHour:
            if to == .metresSecond {
                output = value / 2.237
            } else if to == .kilometreHour {
                output = value *  1.609
            } else if to == .knot {
                output = value / 1.151
            }
        case .knot:
            if to == .metresSecond {
                output = value / 1.944
            } else if to == .kilometreHour {
                output = value * 1.852
            } else if to == .milesHour {
                output = value * 1.151
            }
        }
        return output
    }
    
    static func speedConversion(inputFields:[UITextField]) -> String {
        return  "\(inputFields[0].text ?? "0") ms/s = \(inputFields[1].text ?? "0") km/h = \(inputFields[2].text ?? "0") mi/h = \(inputFields[3].text ?? "0") knots"
    }
}
