//
//  SetPasswordStore.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SetPasswordStore: NSObject, BaseDataStore, SetPasswordDataStore {
    // MARK: - ProfileDataStore
    
    var password: String = ""
    var passwordAgain: String = ""
    var code: String?
    
    // MARK: - TwoStepDataStore
    
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    // MARK: - Additional helpers
}
