//
//  SignInStore.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 09/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SignInStore: NSObject, BaseDataStore, SignInDataStore {
    // MARK: - ProfileDataStore
    
    var email: String = ""
    var password: String = ""
    
    // MARK: - TwoStepDataStore
    
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    // MARK: - Additional helpers
}
