//
//  PaymailAddressModels.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.4.23.
//
//

import UIKit

enum PaymailAddressModels {
    typealias Item = PaymailAddressDataStore
    
    enum Section: Sectionable {
        case description
        case emailViewTitle
        case emailView
        case emailViewSetup
        case paymail
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    enum ScreenType {
        case paymailSetup
        case paymailNotSetup
        
        var description: String {
            switch self {
            case .paymailNotSetup:
                return L10n.PaymailAddress.createAddressDescription
                
            case .paymailSetup:
                return L10n.PaymailAddress.description
                
            }
        }
        
        var image: ImageViewModel {
            switch self {
            case .paymailSetup:
                return .image(Asset.copyIcon.image)
                
            case .paymailNotSetup:
                return .image(Asset.cancel.image.tinted(with: LightColors.Text.three))
                
            }
        }
        
        var emailViewTitle: String {
            switch self {
            case .paymailSetup:
                return L10n.PaymailAddress.yourPaymailAddress
                
            case .paymailNotSetup:
                return L10n.PaymailAddress.paymailAddressField
                
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .paymailSetup:
                return L10n.Button.back
                
            case .paymailNotSetup:
                return L10n.PaymailAddress.createPaymailAddress
                
            }
        }
    }
    
    struct CreatePaymail {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
    
    struct InfoPopup {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {
            var model: PopupViewModel
        }
    }
    
    struct BottomAlert {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
    
    struct Validate {
        struct ViewAction {
            var email: String?
        }
        
        struct ActionResponse {
            var email: String?
            
            var isEmailValid: Bool
            var isEmailEmpty: Bool
            var emailState: DisplayState?
            var isPaymailTaken: Bool
        }
        
        struct ResponseDisplay {
            var email: String?
            
            var isEmailValid: Bool
            var isEmailEmpty: Bool
            var emailModel: TextFieldModel
            var isValid: Bool
        }
    }
}
