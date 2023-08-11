//
//  TwoStepAuthenticationStore.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 27/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class TwoStepAuthenticationStore: NSObject, BaseDataStore, TwoStepAuthenticationDataStore {
    // MARK: - TwoStepAuthenticationDataStore
    
    var keyStore: KeyStore?
    
    // MARK: - Additional helpers
}
