//
//  AuthenticatorAppModels.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 29.3.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum AuthenticatorAppModels {
    typealias Item = SetTwoStepAuth?
    
    enum Section: Sectionable {
        case importWithLink
        case divider
        case instructions
        case qrCode
        case enterCodeManually
        case copyCode
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct CopyValue {
        struct ViewAction {
            var value: String?
        }
        struct ActionResponse {}
    }
    
    struct OpenTotpUrl {
        struct ViewAction {}
        struct ActionResponse {
            let url: String?
        }
        struct ResponseDisplay {
            let url: URL
        }
    }
    
    struct Next {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {}
    }
}
