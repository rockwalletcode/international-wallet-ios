//
//  SignUpModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 10/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum SignUpModels {
    typealias Item = (email: String?, password: String?, passwordAgain: String?)
    
    enum Section: Sectionable {
        case email
        case password
        case confirmPassword
        case notice
        case termsTickbox
        case termsTickboxPro
        case promotionsTickbox
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Validate {
        struct ViewAction {
            var email: String?
            var password: String?
            var passwordAgain: String?
        }
        
        struct ActionResponse {
            var email: String?
            var password: String?
            var passwordAgain: String?
            
            var isEmailValid: Bool
            var isEmailEmpty: Bool
            var emailState: DisplayState?
            
            var isPasswordValid: Bool
            var isPasswordEmpty: Bool
            var passwordState: DisplayState?
            
            var isPasswordAgainValid: Bool
            var isPasswordAgainEmpty: Bool
            var passwordAgainState: DisplayState?
            var passwordsMatch: Bool
            
            var isTermsTickboxValid: Bool
        }
        
        struct ResponseDisplay {
            var email: String?
            var password: String?
            var passwordAgain: String?
            
            var isEmailValid: Bool
            var isEmailEmpty: Bool
            var emailModel: TextFieldModel
            
            var isPasswordValid: Bool
            var isPasswordEmpty: Bool
            var passwordModel: TextFieldModel
            
            var isPasswordAgainValid: Bool
            var isPasswordAgainEmpty: Bool
            var passwordAgainModel: TextFieldModel
            
            var isTermsTickboxValid: Bool
            
            var noticeConfiguration: LabelConfiguration
            var isValid: Bool
        }
    }
    
    struct TermsTickbox {
        struct ViewAction {
            var value: Bool?
            var valuePro: Bool?
        }
    }
    
    struct PromotionsTickbox {
        struct ViewAction {
            var value: Bool
        }
    }
    
    struct Next {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
}
