//
//  SwapModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WalletKit

enum SwapModels {
    typealias Item = (fromAmount: Amount?, toAmount: Amount?)
    
    struct SwitchPlaces {
        struct ViewAction {}
    }
    
    struct SelectedAsset {
        struct ViewAction {
            var from: String?
            var to: String?
        }
    }
    
    struct Assets {
        struct ViewAction {
            var from: Bool?
            var to: Bool?
        }
        
        struct ActionResponse {
            var from: [Currency]?
            var to: [Currency]?
        }
        
        struct ResponseDisplay {
            var title: String
            var from: [Currency]?
            var to: [Currency]?
        }
    }
    
    struct ShowConfirmDialog {
        struct ViewAction {}
        
        struct ActionResponse {
            var fromAmount: Amount?
            var toAmount: Amount?
            var quote: Quote?
            var fromFee: Amount?
            var toFee: Amount?
        }
        
        struct ResponseDisplay {
            var config: WrapperPopupConfiguration<SwapConfimationConfiguration>
            var viewModel: WrapperPopupViewModel<SwapConfirmationViewModel>
        }
    }
    
    struct AssetSelectionMessage {
        struct ViewAction {
            var selectedDisabledAsset: AssetViewModel?
        }
        
        struct ActionResponse {
            var from: Currency?
            var to: Currency?
            var selectedDisabledAsset: AssetViewModel?
        }
        
        struct ResponseDisplay {
            var model: InfoViewModel?
            var config: InfoViewConfiguration?
        }
    }
    
    struct Confirm {
        struct ViewAction {
        }
        
        struct ActionResponse {
            var from: String?
            var to: String?
            var exchangeId: String?
        }
        
        struct ResponseDisplay {
            var from: String
            var to: String
            var exchangeId: String
        }
    }
    
    struct ErrorPopup {
        struct ResponseDisplay {}
    }
    
    struct AssetInfoPopup {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {
            var popupViewModel: PopupViewModel
            var popupConfig: PopupConfiguration
        }
    }
}
