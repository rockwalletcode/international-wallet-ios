//
//  BillingAddressStore.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 01/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Frames
import UIKit

class BillingAddressStore: NSObject, BaseDataStore, BillingAddressDataStore {
    // MARK: - BillingAddressDataStore
    
    var firstName: String?
    var lastName: String?
    var country: Country?
    var city: String?
    var zipPostal: String?
    var address: String?
    var paymentReference: String?
    var paymentstatus: AddCard.Status?
    var countries: [Country] = []
    var states: [Place] = []
    var state: Place?
    
    // From first screen
    var cardNumber: String?
    var expMonth: String?
    var expYear: String?
    var cvv: String?
    
    // MARK: - Additional helpers
    
    var isValid: Bool {
        return FieldValidator.validate(fields: [firstName,
                                                lastName,
                                                city,
                                                zipPostal,
                                                address]) && state != nil && country != nil
    }
}
