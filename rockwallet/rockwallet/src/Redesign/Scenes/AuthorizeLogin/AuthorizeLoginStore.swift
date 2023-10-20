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
    
    var location: String?
    var device: String?
    var ipAddress: String?

    // MARK: - Aditional helpers
}
