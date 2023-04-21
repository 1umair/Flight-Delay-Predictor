

import Foundation
import UIKit

public struct Theme {

    func color() -> UIColor {
        let hex = getThemeColorString()
        return hexToColor(hex: hex)
    }

    func hexToColor(hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    func getThemeColorString() -> String {
        if let themeString = UserDefaults.standard.string(forKey: "theme") {
            return themeString
        }
        return "65C6A6"//"FC1F34"//"#eb4d4b"
    }
}

public struct Font {
    static let Title = UIFont(name: "AvenirNext-Medium", size: 18.0) ?? UIFont.boldSystemFont(ofSize: 18.0)
    static let Subtitle = UIFont(name: "AvenirNext-Regular", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
}

public struct Color {
    //static let Theme = UIColor(rgb: 0xEB4D4B, alphaVal: 1)
    static let Title = UIColor(rgb: 0xACDBDF, alphaVal: 1)
    static let Subtitle = UIColor(rgb: 0xACDBDF, alphaVal: 1)
    static let Button = UIColor(rgb: 0xACDBDF, alphaVal: 1)
    static let IntroPage = UIColor(rgb: 0xACDBDF, alphaVal: 1)
}


