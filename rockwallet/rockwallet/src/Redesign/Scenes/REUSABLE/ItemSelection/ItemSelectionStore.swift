//
//  ItemSelectionStore.swift
//  breadwallet
//
//  Created by Rok on 31/05/2022.
//
//

import UIKit

class ItemSelectionStore: NSObject, BaseDataStore, ItemSelectionDataStore {
    // MARK: - ItemSelectionDataStore
    
    var items: [any ItemSelectable]?
    var instrumentID: String?
    
    var sceneTitle: String = ""
    
    /// Enable adding entries
    var isAddingEnabled: Bool? = false
    var isSelectingEnabled: Bool? = true
    var fromCardWithdrawal: Bool = false
    
    // MARK: - Additional helpers
}
