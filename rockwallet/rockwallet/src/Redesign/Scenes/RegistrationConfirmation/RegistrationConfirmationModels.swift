//
//  RegistrationConfirmationModels.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

enum RegistrationConfirmationModels {
    typealias Item = (type: RegistrationConfirmationModels.ConfirmationType, email: String?)
    
    enum Section: Sectionable {
        case image
        case title
        case instructions
        case input
        case help
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    indirect enum ConfirmationType: Hashable {
        // Regular Login/Register without 2FA
        case account
        
        // Change 2FA method
        case twoStepAccountEmailSettings
        case twoStepAccountAppSettings
        
        // First time 2FA setup
        case twoStepEmail
        case twoStepApp
        
        // Login with 2FA
        case twoStepEmailLogin
        case twoStepAppLogin
        
        // Send funds with 2FA
        case twoStepEmailSendFunds
        case twoStepAppSendFunds
        
        // Buy with 2FA
        case twoStepEmailBuy
        case twoStepAppBuy
        
        // 2FA required
        case twoStepEmailRequired
        case twoStepAppRequired
        
        // Reset password with 2FA
        case twoStepEmailResetPassword
        case twoStepAppResetPassword
        
        // 2FA app backup code
        case twoStepAppBackupCode(ConfirmationType)
        
        // Disable 2FA
        case twoStepDisable
        
        // Check your email screen after Forgot Password
        case forgotPassword
        
        var sections: [Section] {
            switch self {
            case .account, .twoStepEmail, .twoStepAccountEmailSettings, .twoStepAccountAppSettings,
                    .twoStepEmailLogin, .twoStepEmailSendFunds, .twoStepEmailBuy, .twoStepEmailRequired,
                    .twoStepEmailResetPassword, .twoStepDisable:
                return [.image, .title, .instructions, .input, .help]
                
            case .twoStepApp:
                return [.title, .input]
                
            case .twoStepAppLogin, .twoStepAppResetPassword, .twoStepAppSendFunds, .twoStepAppRequired:
                return [.title, .input, .help]
                
            case .twoStepAppBackupCode, .twoStepAppBuy:
                return [.title, .instructions, .input, .help]
                
            case .forgotPassword:
                return [.image, .title, .instructions, .help]
            }
        }
        
        var title: String {
            switch self {
            case .account, .twoStepAccountEmailSettings, .twoStepAccountAppSettings:
                return L10n.AccountCreation.verifyEmail
                
            case .twoStepEmail, .twoStepEmailLogin, .twoStepEmailResetPassword, .twoStepEmailSendFunds,
                    .twoStepEmailBuy, .twoStepEmailRequired, .twoStepDisable:
                return L10n.TwoStep.Email.Confirmation.title
                
            case .twoStepApp, .twoStepAppLogin, .twoStepAppResetPassword, .twoStepAppSendFunds, .twoStepAppBuy, .twoStepAppRequired:
                return L10n.TwoStep.App.Confirmation.title
                
            case .twoStepAppBackupCode:
                return L10n.TwoStep.App.Confirmation.BackupCode.title
                
            case .forgotPassword:
                return L10n.Account.checkYourEmail
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .forgotPassword:
                return L10n.Account.resendEmail
                
            default:
                return L10n.AccountCreation.resendCode
            }
        }
        
        func getInstructions(email: String) -> String? {
            switch self {
            case .account, .twoStepAccountEmailSettings, .twoStepAccountAppSettings:
                return "\(L10n.AccountCreation.enterCode)\(email)"
                
            case .twoStepEmail, .twoStepEmailLogin, .twoStepEmailResetPassword, .twoStepEmailSendFunds,
                    .twoStepEmailBuy, .twoStepEmailRequired, .twoStepDisable:
                return "\(L10n.AccountCreation.enterCode)\(email)"
                
            case .twoStepAppBackupCode:
                return L10n.TwoStep.App.Confirmation.BackupCode.instructions
                
            case .twoStepApp, .twoStepAppLogin, .twoStepAppResetPassword, .twoStepAppSendFunds, .twoStepAppBuy, .twoStepAppRequired:
                return nil
                
            case .forgotPassword:
                return "\(L10n.Account.passwordRecoverDescription)\(email)"
            }
        }
    }
    
    struct Validate {
        struct ViewAction {
            var code: String?
        }
        
        struct ActionResponse {
            var isValid: Bool
        }
        
        struct ResponseDisplay {
            var isValid: Bool
        }
    }
    
    struct Confirm {
        struct ViewAction {
            var type: RegistrationConfirmationModels.ConfirmationType?
        }
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
    
    struct Resend {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
}
