//
//  VerifyPhoneNumberStore.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class VerifyPhoneNumberStore: NSObject, BaseDataStore, VerifyPhoneNumberDataStore {
    
    // MARK: - VerifyPhoneNumberDataStore
    
    var phoneNumber: String?
    var country: Country?
    var countries: [Country] = []
    var states: [Place] = []
    var state: Place?
    
    // MARK: - Additional helpers
}
