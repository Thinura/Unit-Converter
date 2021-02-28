//
//  DoubleHelper.swift
//  Unit converter
//
//  Created by Thinura Laksara on 2021-02-23.
//

import Foundation

extension Double
{
    func truncate(places : Int)-> Double
    {
        let divisor = pow(10.0, Double(places))
        return Double((self * divisor).rounded()/divisor)
    }
}
