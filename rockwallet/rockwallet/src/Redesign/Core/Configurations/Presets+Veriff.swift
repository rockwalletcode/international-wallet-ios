// 
//  Presets+Veriff.swift
//  breadwallet
//
//  Created by Rok on 20/01/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import Veriff

extension Presets {
    static var veriff: VeriffSdk.Configuration {
        let branding = VeriffSdk.Branding()
        branding.background = Colors.Background.one
        branding.onBackground = Colors.Text.three
        branding.onBackgroundSecondary = Colors.Text.one
        branding.primary = Colors.primary
        branding.onPrimary = Colors.Contrast.one
        branding.buttonRadius = CornerRadius.large.rawValue * 5
        branding.font = VeriffSdk.Branding.Font(regular: Fonts.Secondary,
                                                medium: Fonts.Tertiary,
                                                bold: Fonts.Primary)
        let locale = Locale.current
        
        return .init(branding: branding, languageLocale: locale)
    }
}
