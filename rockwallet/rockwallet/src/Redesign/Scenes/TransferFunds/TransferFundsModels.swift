//
//  TransferFundsModels.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 21.9.23.
//
//

import UIKit

enum TransferFundsModels {
    typealias Item = (amount: Amount?, balance: String?)
    
    struct AssetSelectionMessage {
        struct ViewAction {}
        
        struct ActionResponse {}
        
        struct ResponseDisplay {
            var model: InfoViewModel?
            var config: InfoViewConfiguration?
        }
    }
    
    struct AssetSelector {
        struct ViewAction {}
        
        struct ActionResponse {
            var proBalancesData: ProBalancesModel?
            var isDeposit: Bool
        }
        
        struct ResponseDisplay {
            let title: String
            var proBalancesData: ProBalancesModel?
            var isDeposit: Bool
        }
    }
    
    struct ErrorPopup {
        struct ResponseDisplay {}
    }
    
    struct ShowConfirmDialog {
        struct ViewAction {}
        
        struct ActionResponse {
            var fromCurrency: Currency?
            var fromAmount: Amount?
            var fromFee: Amount?
            var toFee: Amount?
            var isDeposit: Bool?
        }
        
        struct ResponseDisplay {
            var config: WrapperPopupConfiguration<SwapConfimationConfiguration>
            var viewModel: WrapperPopupViewModel<SwapConfirmationViewModel>
        }
    }
    
    struct Confirm {
        struct ViewAction {
        }
        
        struct ActionResponse {
            var isDeposit: Bool?
        }
        
        struct ResponseDisplay {}
    }
    
    struct ConfirmTransfer {
        struct ViewAction {
        }
        
        struct ActionResponse {
        }
        
        struct ResponseDisplay {
            var popupViewModel: PopupViewModel
            var popupConfig: PopupConfiguration
        }
    }
    
    struct SwitchPlaces {
        struct ViewAction {
            var isDeposit: Bool?
        }
        struct ActionResponse {
            var isDeposit: Bool?
        }
        
        struct ResponseDisplay {
            var mainHorizontalViewModel: SwitchFromToHorizontalViewModel?
        }
    }
}
