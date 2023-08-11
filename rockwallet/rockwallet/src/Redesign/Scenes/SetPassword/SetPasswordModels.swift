//
//  SetPasswordModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum SetPasswordModels {
    typealias Item = (password: String?, passwordAgain: String?)
    
    enum Section: Sectionable {
        case password
        case confirmPassword
        case notice
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Validate {
        struct ViewAction {
            var password: String?
            var passwordAgain: String?
        }
        
        struct ActionResponse {
            var password: String?
            var passwordAgain: String?
            
            var isPasswordValid: Bool
            var isPasswordEmpty: Bool
            var passwordState: DisplayState?
            
            var isPasswordAgainValid: Bool
            var isPasswordAgainEmpty: Bool
            var passwordAgainState: DisplayState?
            var passwordsMatch: Bool
        }
        
        struct ResponseDisplay {
            var password: String?
            var passwordAgain: String?
            
            var isPasswordValid: Bool
            var isPasswordEmpty: Bool
            var passwordModel: TextFieldModel
            
            var isPasswordAgainValid: Bool
            var isPasswordAgainEmpty: Bool
            var passwordAgainModel: TextFieldModel
            
            var noticeConfiguration: LabelConfiguration
            var isValid: Bool
        }
    }
    
    struct Next {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
}
