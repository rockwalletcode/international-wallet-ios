//
//  AuthenticatorAppInteractor.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 29.3.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class AuthenticatorAppInteractor: NSObject, Interactor, AuthenticatorAppViewActions {
    typealias Models = AuthenticatorAppModels

    var presenter: AuthenticatorAppPresenter?
    var dataStore: AuthenticatorAppStore?
    
    // MARK: - AuthenticatorAppViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        guard dataStore?.setTwoStepAppModel == nil else {
            presenter?.presentData(actionResponse: .init(item: dataStore?.setTwoStepAppModel))
            
            return
        }
        
        let data = SetTwoStepAuthRequestData(type: .app, updateCode: nil)
        SetTwoStepAuthWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let data):
                self?.dataStore?.setTwoStepAppModel = data
                
                self?.presenter?.presentData(actionResponse: .init(item: data))

            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func openTotpUrl(viewAction: AuthenticatorAppModels.OpenTotpUrl.ViewAction) {
        presenter?.presentOpenTotpUrl(actionResponse: .init(url: dataStore?.setTwoStepAppModel?.url))
    }
    
    func next(viewAction: AuthenticatorAppModels.Next.ViewAction) {
        presenter?.presentNext(actionResponse: .init())
    }
    
    // MARK: - Additional helpers
}
