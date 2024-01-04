// 
//  UserSignature.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 17/01/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import WalletKit

struct UserSignature {
    func getHeaders(nonce: String?, token: String?) -> [String: String] {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: Constant.countryUS)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        let dateString = formatter.string(from: Date())
        
        guard let nonce = nonce,
              let token = token,
              let data = (dateString + token + nonce).data(using: .utf8)?.sha256,
              let sessionKey = UserDefaults.sessionToken,
              let apiKeyString = try? keychainItem(key: KeychainKey.apiAuthKey) as String?,
              !apiKeyString.isEmpty,
              let apiKey = Key.createFromString(asPrivate: apiKeyString),
              let signature = CoreSigner.basicDER.sign(data32: data, using: apiKey)?.base64EncodedString()
        else { return [:] }
        
        if UserManager.shared.profile != nil {
            return [
                "Authorization": sessionKey,
                "Date": dateString,
                "Signature": signature
            ]
        } else {
            return [
                "Date": dateString,
                "Signature": signature
            ]
        }
    }
    
    func getHeadersWithdraw(amount: String?, address: String?, asset: String?) -> [String: String] {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: Constant.countryUS)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        let dateString = formatter.string(from: Date())
        
        guard let amount = amount,
              let address = address,
              let asset = asset,
              let data = (dateString + asset + address + amount).data(using: .utf8)?.sha256,
              let sessionKey = UserDefaults.sessionToken,
              let apiKeyString = try? keychainItem(key: KeychainKey.apiAuthKey) as String?,
              !apiKeyString.isEmpty,
              let apiKey = Key.createFromString(asPrivate: apiKeyString),
              let signature = CoreSigner.basicDER.sign(data32: data, using: apiKey)?.base64EncodedString()
        else { return [:] }
        
        return [
            "Authorization": sessionKey,
            "Date": dateString,
            "Signature": signature
        ]
    }
    
    func getHeadersAddresses(address: String?, xpub: String?) -> [String: String] {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: Constant.countryUS)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        let dateString = formatter.string(from: Date())
        
        guard let address = address,
              let xpub = xpub,
              let data = (dateString + xpub + "," + address).data(using: .utf8)?.sha256,
              let sessionKey = UserDefaults.sessionToken,
              let apiKeyString = try? keychainItem(key: KeychainKey.apiAuthKey) as String?,
              !apiKeyString.isEmpty,
              let apiKey = Key.createFromString(asPrivate: apiKeyString),
              let signature = CoreSigner.basicDER.sign(data32: data, using: apiKey)?.base64EncodedString()
        else { return [:] }
        
        return [
            "Authorization": sessionKey,
            "Date": dateString,
            "Signature": signature
        ]
    }
}
