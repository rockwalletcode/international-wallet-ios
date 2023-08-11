// 
//  KYCAuthEndpoints.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 07/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum KYCAuthEndpoints: String, URLType {
    static var baseURL: String = "https://"  + E.apiUrl + "blocksatoshi/one/%@"
    
    case veriffBiometricVerificationSession = "kyc/session?quote_id=%@&is_biometric=%@&biometric_type=%@" // Veriff liveness check for buy
    case veriffBiometricVerificationSessionLimits = "kyc/session?is_biometric=%@&biometric_type=%@" // Bio auth for limits
    case veriffSession = "kyc/session"
    case longPollBiometricStatus = "kyc/long-poll-biometric-status?quote_id=%@"
    case longPollBiometricStatusLimits = "kyc/long-poll-biometric-status?biometric_type=%@"
    case basic = "kyc/basic"
    case upload = "kyc/upload"
    case submit = "kyc/session/submit"
    case confirmationCodes = "confirmation-codes"
    case logout = "auth/logout"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
