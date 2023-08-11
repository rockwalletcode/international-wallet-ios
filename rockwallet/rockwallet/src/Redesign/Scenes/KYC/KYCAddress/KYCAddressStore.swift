//
//  KYCAddressStore.swift
//  breadwallet
//
//  Created by Rok on 06/01/2023.
//
//

import UIKit

class KYCAddressStore: NSObject, BaseDataStore, KYCAddressDataStore {
    
    // MARK: - KYCAddressDataStore
    
    var countries: [Country] = []
    var states: [Place] = []
    
    var firstName: String?
    var lastName: String?
    var birthDateString: String?
    var address: String?
    var city: String?
    var state: Place?
    var postalCode: String?
    var country: Country?
    var ssn: String?
    
    var isValid: Bool {
        guard address?.isEmpty == false,
              city?.isEmpty == false,
              postalCode?.isEmpty == false,
              country != nil else {
            return false
        }
        
        guard country?.iso2 == Constant.countryUS else {
            return true
        }
        
        guard state != nil else {
            return false
        }
        return true
    }
    
    // MARK: - Additional helpers
}
