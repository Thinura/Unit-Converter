//
//  ConversionCellHelper.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-03-08.
//

import Foundation
import UIKit

struct Cell {
    struct Weight {
        static let name = "Weight"
        static let icon =  UIImage(named:"icon_weight")
        static let segueIdentifier = "weightSegue"
    }
    struct Temperature {
        static let name = "Temperature"
        static let icon = UIImage(named:"icon_temperature")
        static let segueIdentifier = "temperatureSegue"
    }
    struct Volume {
        static let name = "Volume"
        static let icon = UIImage(named:"icon_volume")
        static let segueIdentifier = "volumeSegue"
    }
    struct Length {
        static let name = "Length"
        static let icon = UIImage(named:"icon_length")
        static let segueIdentifier = "lengthSegue"
    }
    struct LiquidVolume {
        static let name = "Liquid Volume"
        static let icon = UIImage(named:"icon_liquidVolume")
        static let segueIdentifier = "liquidVolumeSegue"
    }
    struct Speed {
        static let name = "Speed"
        static let icon = UIImage(named:"icon_speed")
        static let segueIdentifier = "speedSegue"
    }
}
