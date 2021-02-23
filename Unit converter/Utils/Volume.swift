//
//  Volume.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-23.
//

import Foundation

/// VolumeMeasurementUnit enumeration is used to define the units
enum VolumeMeasurementUnit {
    case cuMillimetre, cuCentimetre, cuMetre, cuInch, cuFoot, cuYard
    
    static let getAvailableVolumeUnits = [cuMillimetre, cuCentimetre, cuMetre, cuInch, cuFoot, cuYard]
}

struct Volume {
    let value: Double
    let unit: VolumeMeasurementUnit
    
    init(unit: VolumeMeasurementUnit, value: Double) {
        self.value = value
        self.unit = unit
    }
    
    /// This function will convert to all  volume measurement units according to the given unit
    func convert(unit to: VolumeMeasurementUnit) -> Double {
        var output = 0.0
        
        switch unit {
        case .cuMillimetre:
            if to == .cuCentimetre {
                output = value * 0.001
            } else if to == .cuMetre {
                output = value * 1.0e-9
            } else if to == .cuInch {
                output = value * 6.10237e-5
            } else if to == .cuFoot {
                output = value * 3.531466672e-8
            } else if to == .cuYard{
                output = value * 1.307950619e-9
            }
        case .cuCentimetre:
            if to == .cuMillimetre {
                output = value * 1000
            } else if to == .cuMetre {
                output = value * 1.0e-6
            } else if to == .cuInch {
                output = value * 0.0610237441
            } else if to == .cuFoot {
                output = value * 3.53147e-5
            } else if to == .cuYard{
                output = value * 1.308e-6
            }
        case .cuMetre:
            if to == .cuMillimetre {
                output = value * 1.0e+9
            } else if to == .cuCentimetre {
                output = value * 1.0e+6
            } else if to == .cuInch {
                output = value * 61023.744095
            } else if to == .cuFoot {
                output = value * 35.314666721
            } else if to == .cuYard{
                output = value * 1.3079506193
            }
        case .cuInch:
            if to == .cuMillimetre {
                output = value * 16387.064
            } else if to == .cuCentimetre {
                output = value * 16.387064
            } else if to == .cuMetre {
                output = value * 1.63871e-5
            } else if to == .cuFoot {
                output = value * 5.787037e-4
            } else if to == .cuYard{
                output = value * 2.14335e-5
            }
        case .cuFoot:
            if to == .cuMillimetre {
                output = value * 28316846.592
            } else if to == .cuCentimetre {
                output = value * 28316.846592
            } else if to == .cuMetre {
                output = value * 0.0283168466
            } else if to == .cuInch {
                output = value * 1728
            } else if to == .cuYard{
                output = value * 0.037037037
            }
        case .cuYard:
            if to == .cuMillimetre {
                output = value * 764554857.98
            } else if to == .cuCentimetre {
                output = value * 764554.85798
            } else if to == .cuMetre {
                output = value * 0.764554858
            } else if to == .cuInch {
                output = value * 46656
            } else if to == .cuFoot{
                output = value * 27
            }
        }
        
        return output
    }
}
