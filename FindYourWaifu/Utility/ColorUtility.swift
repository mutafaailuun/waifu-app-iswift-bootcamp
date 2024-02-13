//
//  ColorUtility.swift
//  FindYourWaifu
//
//  Created by Jaliel on 13/02/24.
//

import Foundation
import SwiftUI

struct ColorUtility {
    static func randomColor() -> Color {
        return Color(
            red: randomDouble(),
            green: randomDouble(),
            blue: randomDouble()
        )
    }
    
    private static func randomDouble() -> Double {
        return Double.random(in: 0...1)
    }
}
