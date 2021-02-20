//
//  History.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-21.
//

import UIKit

/**
 This class is to render the conversion cell in the history tab
 
 - Parameters:
        type - conversion type
        icon - image of the conversion
        conversionDetails - details of the saved conversion
 
 */

class History {
    let type: String
    let icon: UIImage
    let conversionDetails: String
    
    init(type: String, icon: UIImage, conversionDetails: String) {
        self.type = type
        self.icon = icon
        self.conversionDetails = conversionDetails
    }
    
    func getHistoryType() -> String {
        return type
    }
    
    func getHistoryIcon() -> UIImage {
        return icon
    }
    
    func getHistoryConversionDetails() -> String {
        return conversionDetails
    }
}
