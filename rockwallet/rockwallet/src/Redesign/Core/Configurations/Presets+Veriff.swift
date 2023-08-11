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
        branding.background = LightColors.Background.one
        branding.onBackground = LightColors.Text.three
        branding.onBackgroundSecondary = LightColors.Text.one
        branding.primary = LightColors.primary
        branding.onPrimary = LightColors.Contrast.one
        branding.buttonRadius = CornerRadius.large.rawValue * 5
        branding.font = VeriffSdk.Branding.Font(regular: Fonts.Secondary,
                                                medium: Fonts.Tertiary,
                                                bold: Fonts.Primary)
        let locale = Locale.current
        
        return .init(branding: branding, languageLocale: locale)
    }
}
