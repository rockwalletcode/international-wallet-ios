//
//  BaseInfoStore.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 13.7.22.
//
//

import UIKit

class BaseInfoStore: NSObject, BaseDataStore, BaseInfoDataStore {
    
    // MARK: - BaseInfoDataStore
    
    var coreSystem: CoreSystem?
    var keyStore: KeyStore?
    var id: String?
    var restrictionReason: Profile.AccessRights.RestrictionReason?
    
    var item: Any?

    // MARK: - Additional helpers
}
