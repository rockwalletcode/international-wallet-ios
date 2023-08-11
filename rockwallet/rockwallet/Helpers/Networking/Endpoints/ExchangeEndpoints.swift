// 
//  ExchangeEndpoints.swift
//  breadwallet
//
//  Created by Rok on 04/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum ExchangeEndpoints: String, URLType {
    static var baseURL: String = "https://" + E.apiUrl + "blocksatoshi/exchange/%@"
    
    case quote = "quote?from=%@&to=%@&type=%@"
    case quoteSecondFactorCode = "quote?from=%@&to=%@&type=%@&second_factor_code=%@"
    case quoteSecondFactorBackup = "quote?from=%@&to=%@&type=%@&second_factor_backup=%@"
    
    case supportedCurrencies = "supported-currencies"
    case create = "create"
    case achCreate = "ach/create"
    case details = "v2/exchange/%@"
    case history = "v2/exchanges"
    case paymentInstruments = "v2/payment-instruments"
    case paymentInstrument = "payment-instrument"
    case paymentInstrumentId = "payment-instrument?instrument_id=%@"
    case paymentStatus = "payment-status?reference=%@"
    
    case plaidLinkToken = "plaid-link-token"
    case plaidLinkTokenId = "plaid-link-token?account_id=%@"
    case plaidPublicToken = "plaid-public-token"
    case plaidLogEvent = "plaid-log-event"
    case plaidLogError = "plaid-log-link-error"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
