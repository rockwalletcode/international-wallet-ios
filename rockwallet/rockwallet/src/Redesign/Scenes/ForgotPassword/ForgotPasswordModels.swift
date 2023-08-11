//
//  ForgotPasswordModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum ForgotPasswordModels {
    typealias Item = (String?)
    
    enum Section: Sectionable {
        case email
        case notice
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
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
        }
        
        struct ResponseDisplay {
            var email: String?
            
            var isEmailValid: Bool
            var isEmailEmpty: Bool
            var emailModel: TextFieldModel
            var isValid: Bool
        }
    }
    
    struct Next {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
}
