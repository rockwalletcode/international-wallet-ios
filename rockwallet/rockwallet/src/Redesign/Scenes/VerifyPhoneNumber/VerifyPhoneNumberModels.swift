//
//  VerifyPhoneNumberModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum VerifyPhoneNumberModels {
    typealias Item = VerifyPhoneNumberDataStore
    
    enum Section: Sectionable {
        case instructions
        case phoneNumber
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Validate {
        struct ViewAction {}
        
        struct ActionResponse {
            var isValid: Bool
        }
        
        struct ResponseDisplay {
            var isValid: Bool
        }
    }
    
    struct SetAreaCode {
        struct ActionResponse {
            var areaCode: Country
            var phoneNumber: String?
        }
        struct ResponseDisplay {
            var model: PhoneNumberViewModel
        }
    }
    
    struct SetPhoneNumber {
        struct ViewAction {
            var phoneNumber: String?
        }
    }
    
    struct Confirm {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
}
