//
//  LiquidVolume.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-23.
//

import Foundation

/// liquidVolumeMeasurementUnit enumeration is used to define the units
enum LiquidVolumeMeasurementUnit {
    case litre, millilitre, ukGallon, ukPint, ukFluidOunce
    
    static let getAvailableLiquidVolumeUnits = [litre, millilitre, ukGallon, ukPint, ukFluidOunce]
}

struct LiquidVolume {
    let value: Double
    let unit: LiquidVolumeMeasurementUnit
    
    init(unit: LiquidVolumeMeasurementUnit, value: Double) {
        self.value = value
        self.unit = unit
    }
    
    /// This function will convert to all liquid volume measurement units according to the given unit
    func convert(unit to: LiquidVolumeMeasurementUnit) -> Double {
        var output = 0.0
        
        switch unit {
        case .litre:
            if to == .millilitre {
                output = value * 1000
            } else if to == .ukGallon {
                output = value / 4.546
            } else if to == .ukPint {
                output = value * 1.76
            } else if to == .ukFluidOunce {
                output = value * 35.195
            }
        case .millilitre:
            if to == .litre {
                output = value / 1000
            } else if to == .ukGallon {
                output = value / 4546
            } else if to == .ukPint {
                output = value / 568
            } else if to == .ukFluidOunce {
                output = value / 28.413
            }
        case .ukGallon:
            if to == .litre {
                output = value * 4.546
            } else if to == .millilitre {
                output = value * 4546
            } else if to == .ukPint {
                output = value * 8
            } else if to == .ukFluidOunce {
                output = value * 160
            }
        case .ukPint:
            if to == .litre {
                output = value / 1.76
            } else if to == .millilitre {
                output = value * 568
            } else if to == .ukGallon {
                output = value / 8
            } else if to == .ukFluidOunce {
                output = value * 20
            }
        case .ukFluidOunce:
            if to == .litre {
                output = value / 35.195
            } else if to == .millilitre {
                output = value * 28.413
            } else if to == .ukGallon {
                output = value / 160
            } else if to == .ukPint {
                output = value / 20
            }
        }
        
        return output
    }
}

