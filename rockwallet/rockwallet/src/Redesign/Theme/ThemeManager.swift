// 
//  ThemeManager.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class ThemeManager {
    private var colors: [String: String]
    private var fonts: [String: String]
    
    static var shared = ThemeManager()
    
    init() {
        guard let path = Bundle.main.path(forResource: "theme", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              var colors = dict["colors"] as? [String: String],
              let fonts = dict["fonts"] as? [String: String]
        else {
            fatalError("Theme.plist error")
        }
        
        if UserDefaults.isDarkMode {
            guard let darkColors = dict["darkColors"] as? [String: String] else {
                fatalError("Theme.plist error")
            }
            
            colors = darkColors
        }
        
        self.colors = colors
        self.fonts = fonts
    }
    
    func color(for key: String) -> UIColor {
        guard let color = colors[key] else {
            return .clear
        }
        
        return UIColor(hex: color)
    }
    
    func font(for key: String, size: CGFloat) -> UIFont {
        guard let fontName = fonts[key] else {
            return UIFont.systemFont(ofSize: size, weight: .regular)
        }
        
        return UIFont(name: fontName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
}
