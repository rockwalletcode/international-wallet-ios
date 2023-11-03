// 
//  CreateTransactionModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 15/05/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import WalletKit

struct CreateTransactionModels {
    struct Transaction {
        struct ViewAction {
            var exchange: Exchange?
            var currencies: [Currency]?
            var fromFeeAmount: Amount?
            var fromAmount: Amount?
            var toAmountCode: String?
            var proTransfer: String?
            var address: String?
        }
    }
    
    struct Sender {
        struct ViewAction {
            var fromAmountCurrency: Currency?
        }
    }
    
    struct Fee {
        struct ViewAction {
            var fromAmount: Amount?
            var limit: Decimal?
        }
    }
}
