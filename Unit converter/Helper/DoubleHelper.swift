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
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
