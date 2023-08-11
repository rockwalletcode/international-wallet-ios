//
//  KYCBasicStore.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

class KYCBasicStore: NSObject, BaseDataStore, KYCBasicDataStore {
    // MARK: - KYCBasicDataStore
    
    var firstName: String?
    var lastName: String?
    var birthdate: Date?
    var birthDateString: String?
}
