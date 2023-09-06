// 
//  PaymentMethodsModels.swift
//  breadwallet
//
//  Created by Rok on 12/12/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import LinkKit

enum PaymentMethodsModels {
    enum Get {
        struct ViewAction {
            var openCards: Bool = false
            var setAmount: Bool = true
        }
        
        struct ActionResponse {
            var item: PaymentCard?
        }
    }
    
    struct SetPaymentCard {
        struct ViewAction {
            var card: PaymentCard?
            var setAmount: Bool
        }
    }
    
    struct PaymentCards {
        struct ViewAction {}
        
        struct ActionResponse {
            var allPaymentCards: [PaymentCard]
            var exchangeType: ExchangeType?
        }
        
        struct ResponseDisplay {
            var allPaymentCards: [PaymentCard]
            var exchangeType: ExchangeType?
        }
    }
    
    enum Link {
        struct ViewAction {}
        
        struct ActionResponse {
            var plaidHandler: PlaidLinkKitHandler
        }
        
        struct ResponseDisplay {
            var plaidHandler: PlaidLinkKitHandler
        }
    }
    
    struct PaymentMethod {
        struct ViewAction {
            let method: PaymentCard.PaymentType
        }
        
        struct ActionResponse {}
        
        struct ResponseDisplay {}
    }
    
    struct PlaidLinked {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {
            let model: PopupViewModel
        }
    }
}
