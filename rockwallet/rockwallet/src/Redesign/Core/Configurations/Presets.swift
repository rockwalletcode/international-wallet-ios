// 
//  Presets.swift
//  breadwallet
//
//  Created by Rok on 11/05/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct Presets {
    struct Background {
        struct Primary {
            static var normal = BackgroundConfiguration(backgroundColor: Colors.primary,
                                                        tintColor: Colors.Contrast.two,
                                                        border: Presets.Border.normalButtonFullRadius)
            
            static var selected = BackgroundConfiguration(backgroundColor: Colors.secondary,
                                                          tintColor: Colors.Contrast.two,
                                                          border: Presets.Border.selectedButtonFullRadius)
            
            static var disabled = BackgroundConfiguration(backgroundColor: Colors.Disabled.one,
                                                          tintColor: Colors.Contrast.two,
                                                          border: Presets.Border.disabledButtonFullRadius)
            
            static var borderless = BackgroundConfiguration(backgroundColor: Colors.Background.cards,
                                                             tintColor: Colors.primary,
                                                             border: Presets.Border.borderlessButtonFullRadius)
            
            static var error = BackgroundConfiguration(backgroundColor: Colors.primary,
                                                       tintColor: Colors.Error.one,
                                                       border: Presets.Border.error)
            
            static var tertiary = BackgroundConfiguration(backgroundColor: Colors.Background.three,
                                                          tintColor: Colors.Contrast.two,
                                                          border: Presets.Border.normalButtonFullRadius)
        }
        
        struct Secondary {
            static var normal = BackgroundConfiguration(tintColor: Colors.primary)
            static var selected = BackgroundConfiguration(tintColor: Colors.Text.one)
            static var disabled = BackgroundConfiguration(tintColor: Colors.Disabled.two)
            static var error = BackgroundConfiguration(tintColor: Colors.Error.one)
        }
        
        struct TextField {
            static var normal = BackgroundConfiguration(backgroundColor: Colors.Background.one, tintColor: Colors.primary,
                                                        border: .init(tintColor: Colors.Outline.two, borderWidth: 1, cornerRadius: .extraSmall))
            static var selected = BackgroundConfiguration(backgroundColor: Colors.Background.one, tintColor: Colors.Text.one,
                                                          border: .init(tintColor: Colors.primary, borderWidth: 1, cornerRadius: .extraSmall))
            static var disabled = BackgroundConfiguration(backgroundColor: Colors.Background.one, tintColor: Colors.Disabled.two,
                                                          border: .init(tintColor: Colors.Outline.two, borderWidth: 1, cornerRadius: .extraSmall))
            static var error = BackgroundConfiguration(backgroundColor: Colors.Background.one, tintColor: Colors.Error.one,
                                                       border: .init(tintColor: Colors.Error.one, borderWidth: 1, cornerRadius: .extraSmall))
        }
        
        static var transparent = BackgroundConfiguration(backgroundColor: .clear,
                                                         tintColor: Colors.primary)
    }
    
    struct Border {
        static var extraSmallPlain = BorderConfiguration(borderWidth: 0, cornerRadius: .extraSmall)
        static var mediumPlain = BorderConfiguration(borderWidth: 0, cornerRadius: .medium)
        static var commonPlain = BorderConfiguration(borderWidth: 0, cornerRadius: .common)
        
        static var error = BorderConfiguration(tintColor: Colors.Error.one, borderWidth: 1, cornerRadius: .extraSmall)
        static var accountVerification = BorderConfiguration(tintColor: Colors.Outline.one, borderWidth: 1, cornerRadius: .small)
        
        static var normal = BorderConfiguration(borderWidth: 0, cornerRadius: .medium)
        static var selected = BorderConfiguration(borderWidth: 0, cornerRadius: .medium)
        static var disabled = BorderConfiguration(borderWidth: 0, cornerRadius: .medium)
        
        static var normalButtonFullRadius = BorderConfiguration(tintColor: Colors.primary, borderWidth: 1.5, cornerRadius: .fullRadius)
        static var selectedButtonFullRadius = BorderConfiguration(tintColor: Colors.secondary, borderWidth: 1.5, cornerRadius: .fullRadius)
        static var disabledButtonFullRadius = BorderConfiguration(tintColor: Colors.Disabled.one, borderWidth: 1.5, cornerRadius: .fullRadius)
        
        static var borderlessButtonFullRadius = BorderConfiguration(tintColor: .clear, borderWidth: 0, cornerRadius: .fullRadius)
        
        static var normalTextField = BorderConfiguration(tintColor: Colors.Outline.two, borderWidth: 1, cornerRadius: .extraSmall)
        static var selectedTextField = BorderConfiguration(tintColor: Colors.Outline.two, borderWidth: 1, cornerRadius: .extraSmall)
        static var disabledTextField = BorderConfiguration(tintColor: Colors.Outline.two, borderWidth: 1, cornerRadius: .extraSmall)
    }
    
    struct Shadow {
        static var zero = ShadowConfiguration(color: .clear,
                                              opacity: .zero,
                                              offset: .zero,
                                              shadowRadius: .small)
        
        static var normal = ShadowConfiguration(color: Colors.Contrast.one,
                                                opacity: .low,
                                                offset: .init(width: 4, height: 10),
                                                shadowRadius: .small)
        
        static var light = ShadowConfiguration(color: Colors.Contrast.one,
                                               opacity: .lowest,
                                               offset: .init(width: 0, height: 8),
                                               shadowRadius: .small)
    }
}

extension Presets {
    struct Button {
        static var primary = ButtonConfiguration(normalConfiguration: Presets.Background.Primary.normal,
                                                 selectedConfiguration: Presets.Background.Primary.selected,
                                                 disabledConfiguration: Presets.Background.Primary.disabled)
        
        static var whiteBorderless = ButtonConfiguration(normalConfiguration: Presets.Background.Primary.borderless,
                                                         selectedConfiguration: Presets.Background.Primary.borderless,
                                                         disabledConfiguration: Presets.Background.Primary.borderless,
                                                         buttonContentEdgeInsets: .zero)
        
        static var secondary = ButtonConfiguration(normalConfiguration: Presets.Background.Secondary.normal
            .withBorder(border: Presets.Border.normalButtonFullRadius),
                                                   selectedConfiguration: Presets.Background.Secondary.selected
            .withBorder(border: Presets.Border.selectedButtonFullRadius),
                                                   disabledConfiguration: Presets.Background.Secondary.disabled
            .withBorder(border: Presets.Border.disabledButtonFullRadius))
        
        static var secondaryNoBorder = ButtonConfiguration(
            normalConfiguration: BackgroundConfiguration(backgroundColor: Colors.Background.two,
                                                         tintColor: Colors.primary,
                                                         border: .init(tintColor: .clear, borderWidth: 0, cornerRadius: .fullRadius)),
            selectedConfiguration: Presets.Background.Secondary.selected,
            disabledConfiguration: Presets.Background.Secondary.disabled,
            buttonContentEdgeInsets: .zero)
        
        static var noBorders = ButtonConfiguration(normalConfiguration: BackgroundConfiguration(tintColor: Colors.secondary),
                                                   selectedConfiguration: Presets.Background.Secondary.selected,
                                                   disabledConfiguration: Presets.Background.Secondary.disabled,
                                                   buttonContentEdgeInsets: .zero)
        
        static var blackIcon = ButtonConfiguration(normalConfiguration: .init(tintColor: Colors.Text.three),
                                                   selectedConfiguration: .init(tintColor: Colors.Text.one),
                                                   disabledConfiguration: .init(tintColor: Colors.Disabled.one))
    }
}

extension Presets {
    struct TextField {
        static var primary = TextFieldConfiguration(leadingImageConfiguration: .init(backgroundColor: .clear, tintColor: Colors.Text.two),
                                                    titleConfiguration: .init(font: Fonts.Body.two, textColor: Colors.Text.one),
                                                    selectedTitleConfiguration: .init(font: Fonts.Body.two, textColor: Colors.Text.two),
                                                    textConfiguration: .init(font: Fonts.Body.two, textColor: Colors.Text.one),
                                                    placeholderConfiguration: .init(font: Fonts.Body.two, textColor: Colors.Text.one),
                                                    hintConfiguration: .init(font: Fonts.Body.three,
                                                                             textColor: Colors.Error.one,
                                                                             numberOfLines: 1),
                                                    backgroundConfiguration: Presets.Background.TextField.normal,
                                                    selectedBackgroundConfiguration: Presets.Background.TextField.selected,
                                                    disabledBackgroundConfiguration: Presets.Background.TextField.disabled,
                                                    errorBackgroundConfiguration: Presets.Background.TextField.error.withBorder(border: Presets.Border.error))
        
        static var two = TextFieldConfiguration(titleConfiguration: .init(font: Fonts.Body.two, textColor: Colors.Text.one),
                                                selectedTitleConfiguration: .init(font: Fonts.Body.three, textColor: Colors.Text.two),
                                                textConfiguration: .init(font: Fonts.Body.two, textColor: Colors.Text.one),
                                                placeholderConfiguration: .init(font: Fonts.Body.two, textColor: Colors.Text.one),
                                                hintConfiguration: .init(font: Fonts.Body.three,
                                                                         textColor: Colors.Error.one,
                                                                         numberOfLines: 1),
                                                trailingImageConfiguration: .init(tintColor: Colors.Text.two),
                                                backgroundConfiguration: Presets.Background.TextField.normal,
                                                selectedBackgroundConfiguration: Presets.Background.TextField.selected,
                                                disabledBackgroundConfiguration: Presets.Background.TextField.disabled,
                                                errorBackgroundConfiguration: Presets.Background.TextField.error)
        
        static var phrase = TextFieldConfiguration(titleConfiguration: .init(font: Fonts.Body.two, textColor: Colors.Text.one),
                                                   selectedTitleConfiguration: .init(font: Fonts.Body.two, textColor: Colors.Text.two),
                                                   textConfiguration: .init(font: Fonts.Body.phrase, textColor: Colors.Text.one),
                                                   placeholderConfiguration: .init(font: Fonts.Body.two, textColor: Colors.Text.one))
    }
}

extension Presets {
    struct InfoView {
        static var verification = InfoViewConfiguration(headerLeadingImage: BackgroundConfiguration(tintColor: Colors.Contrast.two),
                                                        headerTitle: .init(font: Fonts.Subtitle.two, textColor: Colors.Text.three),
                                                        headerTrailing: .init(normalConfiguration: .init(tintColor: Colors.Text.three),
                                                                              selectedConfiguration: .init(tintColor: Colors.Text.two),
                                                                              disabledConfiguration: .init(tintColor: Colors.Disabled.two)),
                                                        title: .init(font: Fonts.Subtitle.two, textColor: Colors.Text.three),
                                                        description: .init(font: Fonts.Body.two, textColor: Colors.Text.one),
                                                        button: Presets.Button.noBorders,
                                                        background: .init(backgroundColor: Colors.Background.three,
                                                                          border: Presets.Border.commonPlain),
                                                        shadow: Presets.Shadow.zero)
        
        static var warning = InfoViewConfiguration(headerTitle: .init(font: Fonts.Title.six, textColor: Colors.Text.three),
                                                   description: .init(font: Fonts.Body.two, textColor: Colors.Text.three),
                                                   background: .init(backgroundColor: Colors.Background.three,
                                                                     tintColor: Colors.Contrast.two,
                                                                     border: Presets.Border.mediumPlain),
                                                   shadow: Presets.Shadow.zero)
        
        static var error = InfoViewConfiguration(headerTitle: .init(font: Fonts.Title.six, textColor: Colors.Contrast.two),
                                                 description: .init(font: Fonts.Body.two, textColor: Colors.Contrast.two),
                                                 background: .init(backgroundColor: Colors.Error.one,
                                                                   tintColor: Colors.Contrast.two,
                                                                   border: Presets.Border.mediumPlain),
                                                 shadow: Presets.Shadow.zero)
        
        static var tickbox = InfoViewConfiguration(title: .init(font: Fonts.Subtitle.three, textColor: LightColors.Text.one),
                                                   description: .init(font: Fonts.Body.two, textColor: LightColors.Text.one),
                                                   button: Presets.Button.noBorders,
                                                   tickboxItem: .init(title: .init(font: Fonts.Body.two, textColor: LightColors.Text.three)),
                                                   background: .init(backgroundColor: LightColors.Background.three,
                                                                     border: Presets.Border.commonPlain),
                                                   shadow: Presets.Shadow.zero)
    }
}

extension Presets {
    struct Popup {
        static var normal = PopupConfiguration(background: .init(backgroundColor: Colors.Background.one,
                                                                 tintColor: Colors.Contrast.two,
                                                                 border: Presets.Border.mediumPlain),
                                               title: .init(font: Fonts.Title.six, textColor: Colors.Text.three, textAlignment: .center),
                                               body: .init(font: Fonts.Body.two, textColor: Colors.Text.one),
                                               
                                               buttons: [Presets.Button.primary.withBorder(normal: Presets.Border.normalButtonFullRadius,
                                                                                           selected: Presets.Border.selectedButtonFullRadius,
                                                                                           disabled: Presets.Border.disabledButtonFullRadius),
                                                         Presets.Button.secondary],
                                               closeButton: Presets.Button.blackIcon)
        
        static var white = PopupConfiguration(background: .init(backgroundColor: Colors.Background.one,
                                                                tintColor: Colors.Contrast.two,
                                                                border: Presets.Border.mediumPlain),
                                              title: .init(font: Fonts.Title.five, textColor: Colors.Text.three),
                                              body: .init(font: Fonts.Body.two, textColor: Colors.Text.one, textAlignment: .left),
                                              buttons: [Presets.Button.primary.withBorder(normal: Presets.Border.normalButtonFullRadius,
                                                                                          selected: Presets.Border.selectedButtonFullRadius,
                                                                                          disabled: Presets.Border.disabledButtonFullRadius),
                                                        Presets.Button.secondary],
                                              closeButton: Presets.Button.blackIcon)
        
        static var whiteCentered = PopupConfiguration(background: .init(backgroundColor: Colors.Background.one,
                                                                        tintColor: Colors.Contrast.two,
                                                                        border: Presets.Border.mediumPlain),
                                                      title: .init(font: Fonts.Title.five, textColor: Colors.Text.three, textAlignment: .center),
                                                      body: .init(font: Fonts.Body.two, textColor: Colors.Text.one, textAlignment: .center),
                                                      buttons: [Presets.Button.primary.withBorder(normal: Presets.Border.normalButtonFullRadius,
                                                                                                  selected: Presets.Border.selectedButtonFullRadius,
                                                                                                  disabled: Presets.Border.disabledButtonFullRadius),
                                                                Presets.Button.secondary],
                                                      closeButton: Presets.Button.blackIcon)
    }
}

extension Presets {
    enum Animation: Double {
        case short = 0.25
        case average = 0.35
        case long = 0.45
    }
}

extension Presets {
    enum Delay: Double {
        case immediate = 0.1
        case short = 0.5
        case regular = 1.0
        case medium = 1.5
        case long = 2.0
        case buttonState = 25.0
        case repeatingAction = 30.0
    }
}

extension Presets {
    struct VerificationView {
        static var resubmitAndDeclined = VerificationConfiguration(shadow: Presets.Shadow.zero,
                                                                   background: .init(backgroundColor: Colors.Background.one,
                                                                                     tintColor: Colors.Outline.two,
                                                                                     border: Presets.Border.mediumPlain),
                                                                   title: .init(font: Fonts.Title.five, textColor: Colors.Text.one),
                                                                   status: .init(title: .init(font: Fonts.Body.two,
                                                                                              textColor: Colors.Contrast.two,
                                                                                              textAlignment: .center),
                                                                                 background: .init(backgroundColor: Colors.Error.one,
                                                                                                   tintColor: Colors.Contrast.two,
                                                                                                   border: Presets.Border.extraSmallPlain)),
                                                                   infoButton: .init(normalConfiguration: Presets.Background.Secondary.normal,
                                                                                     selectedConfiguration: Presets.Background.Secondary.selected,
                                                                                     disabledConfiguration: Presets.Background.Secondary.disabled),
                                                                   description: .init(font: Fonts.Body.two, textColor: Colors.Text.two),
                                                                   benefits: .init(font: Fonts.Body.two, textColor: Colors.Text.three, textAlignment: .center))
        
        static var pending = VerificationConfiguration(shadow: Presets.Shadow.zero,
                                                       background: .init(backgroundColor: Colors.Background.one,
                                                                         tintColor: Colors.Outline.two,
                                                                         border: Presets.Border.mediumPlain),
                                                       title: .init(font: Fonts.Title.five, textColor: Colors.Text.one),
                                                       status: .init(title: .init(font: Fonts.Body.two,
                                                                                  textColor: Colors.Contrast.one,
                                                                                  textAlignment: .center),
                                                                     background: .init(backgroundColor: Colors.Pending.one,
                                                                                       tintColor: Colors.Contrast.one,
                                                                                       border: Presets.Border.extraSmallPlain)),
                                                       infoButton: .init(normalConfiguration: Presets.Background.Secondary.normal,
                                                                         selectedConfiguration: Presets.Background.Secondary.selected,
                                                                         disabledConfiguration: Presets.Background.Secondary.disabled),
                                                       description: .init(font: Fonts.Body.two, textColor: Colors.Text.two),
                                                       benefits: .init(font: Fonts.Body.two, textColor: Colors.Text.three, textAlignment: .center))
        
        static var verified = VerificationConfiguration(shadow: Presets.Shadow.zero,
                                                        background: .init(backgroundColor: Colors.Background.one,
                                                                          tintColor: Colors.Outline.two,
                                                                          border: Presets.Border.mediumPlain),
                                                        title: .init(font: Fonts.Title.five, textColor: Colors.Text.one),
                                                        status: .init(title: .init(font: Fonts.Body.two,
                                                                                   textColor: Colors.Contrast.one,
                                                                                   textAlignment: .center),
                                                                      background: .init(backgroundColor: Colors.Success.one,
                                                                                        tintColor: Colors.Contrast.two,
                                                                                        border: Presets.Border.extraSmallPlain)),
                                                        infoButton: .init(normalConfiguration: Presets.Background.Secondary.normal,
                                                                          selectedConfiguration: Presets.Background.Secondary.selected,
                                                                          disabledConfiguration: Presets.Background.Secondary.disabled),
                                                        description: .init(font: Fonts.Body.two, textColor: Colors.Text.two),
                                                        benefits: .init(font: Fonts.Body.two, textColor: Colors.Text.three, textAlignment: .center))
    }
}

extension Presets {
    struct Order {
        static var small = OrderConfiguration(title: .init(font: Fonts.Body.two, textColor: Colors.Text.two, textAlignment: .center, numberOfLines: 1),
                                              value: .init(font: Fonts.Subtitle.two,
                                                           textColor: Colors.Text.one,
                                                           textAlignment: .center,
                                                           numberOfLines: 1,
                                                           lineBreakMode: .byTruncatingMiddle),
                                              shadow: Presets.Shadow.light,
                                              background: .init(backgroundColor: Colors.Background.one,
                                                                tintColor: Colors.Text.one,
                                                                border: Presets.Border.mediumPlain),
                                              contentBackground: .init(tintColor: Colors.Text.one))
        
        static var auth = OrderConfiguration(title: .init(font: Fonts.Subtitle.two, textColor: Colors.Text.three, textAlignment: .center, numberOfLines: 1),
                                             value: .init(font: Fonts.Subtitle.two,
                                                          textColor: Colors.Text.three,
                                                          textAlignment: .center),
                                             background: .init(backgroundColor: Colors.Background.cards,
                                                               border: .init(tintColor: Colors.Outline.one,
                                                                             borderWidth: 1,
                                                                             cornerRadius: CornerRadius.common)),
                                             contentBackground: .init(tintColor: Colors.Background.cards))
    }
}

extension Presets {
    struct AssetSelection {
        static var header = AssetConfiguration(topConfiguration: .init(font: Fonts.Subtitle.two, textColor: Colors.Text.one),
                                               bottomConfiguration: .init(font: Fonts.Subtitle.two, textColor: Colors.Text.two),
                                               topRightConfiguration: .init(font: Fonts.Subtitle.two, textColor: Colors.Text.one, textAlignment: .right),
                                               bottomRightConfiguration: .init(font: Fonts.Subtitle.two, textColor: Colors.Text.two, textAlignment: .right),
                                               backgroundConfiguration: .init(backgroundColor: Colors.Background.cards,
                                                                              border: Presets.Border.normal),
                                               imageConfig: .init(backgroundColor: Colors.Pending.one,
                                                                  tintColor: .white,
                                                                  border: .init(borderWidth: 0,
                                                                                cornerRadius: .medium)),
                                               imageSize: .small)
        
        static var enabled = AssetConfiguration(topConfiguration: .init(font: Fonts.Subtitle.one, textColor: Colors.Text.three),
                                                bottomConfiguration: .init(font: Fonts.Subtitle.two, textColor: Colors.Text.two),
                                                topRightConfiguration: .init(font: Fonts.Subtitle.one, textColor: Colors.Text.three, textAlignment: .right),
                                                bottomRightConfiguration: .init(font: Fonts.Subtitle.two,
                                                                                textColor: Colors.Text.two,
                                                                                textAlignment: .right),
                                                imageSize: .large)
        
        static var disabled = AssetConfiguration(topConfiguration: .init(font: Fonts.Subtitle.two, textColor: Colors.Text.one.withAlphaComponent(0.5)),
                                                 bottomConfiguration: .init(font: Fonts.Subtitle.two, textColor: Colors.Text.two.withAlphaComponent(0.5)),
                                                 topRightConfiguration: .init(font: Fonts.Subtitle.two,
                                                                              textColor: Colors.Text.one.withAlphaComponent(0.5),
                                                                              textAlignment: .right),
                                                 bottomRightConfiguration: .init(font: Fonts.Subtitle.two,
                                                                                 textColor: Colors.Text.two.withAlphaComponent(0.5),
                                                                                 textAlignment: .right),
                                                 imageSize: .large,
                                                 imageAlpha: 0.5)
    }
}

extension Presets {
    struct TitleValue {
        static var common = TitleValueConfiguration(title: .init(font: Fonts.Body.two, textColor: Colors.Text.one, numberOfLines: 1),
                                                    value: .init(font: Fonts.Subtitle.two, textColor: Colors.Text.one, textAlignment: .right))
        
        static var bold = TitleValueConfiguration(title: .init(font: Fonts.Body.one, textColor: Colors.Text.one, numberOfLines: 1),
                                                  value: .init(font: Fonts.Subtitle.one, textColor: Colors.Text.one, textAlignment: .right))
        
        static var small = TitleValueConfiguration(title: .init(font: Fonts.Body.three, textColor: Colors.Text.two, numberOfLines: 1),
                                                   value: .init(font: Fonts.Subtitle.three, textColor: Colors.Text.two, textAlignment: .right))
        
        static var alert = TitleValueConfiguration(title: .init(font: Fonts.Title.six, textColor: Colors.Text.three, textAlignment: .center, numberOfLines: 1),
                                                   value: .init(font: Fonts.Body.two, textColor: Colors.Text.one, textAlignment: .center))
    }
}

extension Presets {
    struct ExchangeView {
        static var shadow: ShadowConfiguration? = Presets.Shadow.light
        static var background: BackgroundConfiguration? = .init(backgroundColor: Colors.Background.cards,
                                                                tintColor: Colors.Text.one,
                                                                border: Presets.Border.mediumPlain)
    }
}
