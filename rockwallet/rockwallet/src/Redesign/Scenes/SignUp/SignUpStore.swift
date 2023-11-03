//
//  SignUpStore.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 10/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SignUpStore: NSObject, BaseDataStore, SignUpDataStore {
    // MARK: - ProfileDataStore
    
    var email = ""
    var password = ""
    var passwordAgain = ""
    var termsTickbox = false
    var termsTickboxPro = false
    var promotionsTickbox = false
    
    // MARK: - Additional helpers
}
