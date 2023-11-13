//
//  SignInModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 09/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum SignInModels {
    typealias Item = (email: String?, password: String?)
    
    enum Section: Sectionable {
        case email
        case password
        case forgotPassword
        case termsDescription
        case terms
        case termsPro
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Validate {
        struct ViewAction {
            var email: String?
            var password: String?
        }
        
        struct ActionResponse {
            var email: String?
            var password: String?
            
            var isEmailValid: Bool
            var isEmailEmpty: Bool
            var emailState: DisplayState?
            
            var isPasswordValid: Bool
            var isPasswordEmpty: Bool
            var passwordState: DisplayState?
        }
        
        struct ResponseDisplay {
            var email: String?
            var password: String?
            
            var isEmailValid: Bool
            var isEmailEmpty: Bool
            var emailModel: TextFieldModel
            
            var isPasswordValid: Bool
            var isPasswordEmpty: Bool
            var passwordModel: TextFieldModel
            
            var isValid: Bool
        }
    }
    
    struct Next {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
}
