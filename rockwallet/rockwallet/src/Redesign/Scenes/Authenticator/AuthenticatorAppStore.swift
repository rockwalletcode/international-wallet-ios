//
//  AuthenticatorAppStore.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 29.3.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class AuthenticatorAppStore: NSObject, BaseDataStore, AuthenticatorAppDataStore {
    // MARK: - AuthenticatorAppDataStore
    
    var setTwoStepAppModel: SetTwoStepAuth?
    
    // MARK: - Additional helpers
}
