// 
//  CopyValueVIP.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 24.4.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

protocol CopyValueActions: BaseViewActions, FetchViewActions {
    func copyValue(viewAction: CopyValueModels.Copy.ViewAction)
}

protocol CopyValueResponses: BaseActionResponses, FetchActionResponses {
    func presentCopyValue(actionResponse: CopyValueModels.Copy.ActionResponse)
}

extension Interactor where Self: CopyValueActions,
                           Self.ActionResponses: CopyValueResponses {
    func copyValue(viewAction: CopyValueModels.Copy.ViewAction) {
        let value = viewAction.value?.filter { !$0.isWhitespace } ?? ""
        UIPasteboard.general.string = value
        
        let message = viewAction.message ?? L10n.Receive.copied
        presenter?.presentCopyValue(actionResponse: .init(message: message))
    }
}

extension Presenter where Self: CopyValueResponses {
    func presentCopyValue(actionResponse: CopyValueModels.Copy.ActionResponse) {
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(actionResponse.message)),
                                                              config: Presets.InfoView.verification))
    }
}
