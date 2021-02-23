//
//  Length.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-23.
//

import Foundation

/// LengthMeasurementUnit enumeration is used to define the units
enum LengthMeasurementUnit {
    case millimetre, centimetre, inch, metre, mile, kilometre, yard
    
    static let getAvailableLengthUnits = [millimetre, centimetre, inch, metre, mile, kilometre, yard]
}

struct Length {
    let value: Double
    let unit: LengthMeasurementUnit
    
    init(unit: LengthMeasurementUnit, value: Double) {
        self.value = value
        self.unit = unit
    }
    
    func convert(unit to: LengthMeasurementUnit) -> Double {
        var output = 0.0
        
        switch unit {
        case .millimetre:
            if to == .centimetre {
                output = value / 10
            }else if to == .metre {
                output = value / 1000
            }else if to == .inch {
                output = value / 25.4
            }else if to == .mile {
                output = value / 1.609e+6
            } else if to == .kilometre {
                output = value / 1e+6
            }else if to == .yard {
                output = value / 914
            }
        case .centimetre:
            if to == .millimetre {
                output = value * 10
            }else if to == .metre {
                output = value / 100
            }else if to == .inch {
                output = value / 2.54
            }else if to == .mile {
                output = value / 160934
            } else if to == .kilometre {
                output = value / 100000
            }else if to == .yard {
                output = value / 91.44
            }
        case .metre:
            if to == .millimetre {
                output = value * 1000
            }else if to == .centimetre {
                output = value * 100
            }else if to == .inch {
                output = value * 39.37
            }else if to == .mile {
                output = value / 1609
            } else if to == .kilometre {
                output = value / 1000
            }else if to == .yard {
                output = value * 1.094
            }
        case .inch:
            if to == .millimetre {
                output = value * 25.4
            }else if to == .centimetre {
                output = value * 2.54
            }else if to == .metre {
                output = value / 39.37
            }else if to == .mile {
                output = value / 63360
            } else if to == .kilometre {
                output = value / 39370
            }else if to == .yard {
                output = value / 36
            }
        case .mile:
            if to == .millimetre {
                output = value * 1.609e+6
            }else if to == .centimetre {
                output = value * 160934
            }else if to == .metre {
                output = value * 1609
            }else if to == .inch {
                output = value * 63360
            } else if to == .kilometre {
                output = value * 1.609
            }else if to == .yard {
                output = value * 1760
            }
        case .kilometre:
            if to == .millimetre {
                output = value * 1e+6
            }else if to == .centimetre {
                output = value * 100000
            }else if to == .metre {
                output = value * 1000
            }else if to == .inch {
                output = value * 39370
            } else if to == .mile {
                output = value / 1.609
            }else if to == .yard {
                output = value * 1094
            }
        case .yard:
            if to == .millimetre {
                output = value * 914
            }else if to == .centimetre {
                output = value * 91.44
            }else if to == .metre {
                output = value / 1.094
            }else if to == .inch {
                output = value * 36
            } else if to == .mile {
                output = value / 1760
            }else if to == .kilometre {
                output = value / 1094
            }
        }
        return output
    }
}

