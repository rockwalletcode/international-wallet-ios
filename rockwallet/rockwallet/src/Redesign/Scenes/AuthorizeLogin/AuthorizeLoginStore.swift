//
//  AuthorizeLoginStore.swift
//  rockwallet
//
//  Created by Dino Gačević on 05/10/2023.
//
//

import UIKit

class AuthorizeLoginStore: NSObject, BaseDataStore, AuthorizeLoginDataStore {
    
    // MARK: - AuthorizeLoginDataStore
    
    var location: String? = "Maribor, Slovenia"
    var device: String? = "iPhone 14 Pro"
    var ipAddress: String? = "213.172.234.81"

    // MARK: - Aditional helpers
}
