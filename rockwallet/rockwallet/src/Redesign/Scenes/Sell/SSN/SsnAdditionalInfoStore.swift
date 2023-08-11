// 
//  SsnAdditionalInfoStore.swift
//  breadwallet
//
//  Created by Dino Gacevic on 24/07/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class SsnAdditionalInfoStore: NSObject, BaseDataStore, SsnAdditionalInfoDataStore {
    var ssn: String?
    var isSsnValid: Bool {
        return ssn?.count == 4 || ssn?.count == 9
    }
}
