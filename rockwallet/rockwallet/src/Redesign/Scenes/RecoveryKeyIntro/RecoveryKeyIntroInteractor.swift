//
//  RecoveryKeyIntroInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 04/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class RecoveryKeyIntroInteractor: NSObject, Interactor, RecoveryKeyIntroViewActions {
    
    typealias Models = RecoveryKeyIntroModels
    
    var presenter: RecoveryKeyIntroPresenter?
    var dataStore: RecoveryKeyIntroStore?
    
    // MARK: - RecoveryKeyIntroViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: Models.Item()))
    }
    
    func toggleTickbox(viewAction: RecoveryKeyIntroModels.Tickbox.ViewAction) {
        presenter?.presentToggleTickbox(actionResponse: .init(value: viewAction.value))
    }
    
    // MARK: - Additional helpers
}
