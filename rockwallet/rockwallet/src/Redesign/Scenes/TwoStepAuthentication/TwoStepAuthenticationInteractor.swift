//
//  TwoStepAuthenticationInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 27/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class TwoStepAuthenticationInteractor: NSObject, Interactor, TwoStepAuthenticationViewActions {
    typealias Models = TwoStepAuthenticationModels
    
    var presenter: TwoStepAuthenticationPresenter?
    var dataStore: TwoStepAuthenticationStore?
    
    // MARK: - TwoStepAuthenticationViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        TwoStepSettingsWorker().execute(requestData: TwoStepSettingsRequestData(method: .get)) { [weak self] result in
            switch result {
            case .success(let data):
                self?.presenter?.presentData(actionResponse: .init(item: data?.type))
                
            case .failure:
                self?.presenter?.presentData(actionResponse: .init(item: nil))
            }
        }
    }
    
    func changeMethod(viewAction: TwoStepAuthenticationModels.ChangeMethod.ViewAction) {
        presenter?.presentChangeMethod(actionResponse: .init(indexPath: viewAction.indexPath))
    }
    
    // MARK: - Additional helpers
}
