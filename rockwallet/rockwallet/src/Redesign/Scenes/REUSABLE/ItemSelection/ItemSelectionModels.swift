//
//  ItemSelectionModels.swift
//  breadwallet
//
//  Created by Rok on 31/05/2022.
//
//

import UIKit

protocol ItemSelectable: Hashable {
    var displayName: String? { get }
    var displayImage: ImageViewModel? { get }
}

enum ItemSelectionModels: Hashable {

    struct Item {
        var items: [any ItemSelectable]?
        var isAddingEnabled: Bool?
        var fromCardWithdrawal: Bool
    }
    
    enum Section: Sectionable {
        case banner
        case addItem
        case items
        
        var header: AccessoryType? { nil }
        var footer: AccessoryType? { nil }
    }
    
    enum Search {
        struct ViewAction {
            let text: String?
        }
    }
    
    struct ActionSheet {
        struct ViewAction {
            var instrumentId: String
            var last4: String
        }
        
        struct ActionResponse {
            var instrumentId: String
            var last4: String
        }
        
        struct ResponseDisplay {
            var instrumentId: String
            var last4: String
            var actionSheetOkButton: String
            var actionSheetCancelButton: String
        }
    }
    
    struct RemovePayment {
        struct ViewAction {}
        
        struct ActionResponse {}
        
        struct ResponseDisplay {}
    }
    
    struct RemovePaymenetPopup {
        struct ViewAction {
            var instrumentID: String
            var last4: String
        }
        
        struct ActionResponse {
            var last4: String
        }
        
        struct ResponseDisplay {
            var popupViewModel: PopupViewModel
            var popupConfig: PopupConfiguration
        }
    }
    
    enum FindAddress {
        struct ViewAction {
            var input: String?
        }
    }
}
