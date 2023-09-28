//
//  TransferFundsModels.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 21.9.23.
//
//

import UIKit

enum TransferFundsModels {
    typealias Item = Amount?
    
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
        
        struct ActionResponse {}
        
        struct ResponseDisplay {
            let title: String
        }
    }
    
    struct ErrorPopup {
        struct ResponseDisplay {}
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
}
