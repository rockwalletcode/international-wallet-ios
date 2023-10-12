//
//  AuthorizeLoginInteractor.swift
//  rockwallet
//
//  Created by Dino Gačević on 05/10/2023.
//
//

import UIKit

class AuthorizeLoginInteractor: NSObject, Interactor, AuthorizeLoginViewActions {
    typealias Models = AuthorizeLoginModels

    var presenter: AuthorizeLoginPresenter?
    var dataStore: AuthorizeLoginStore?

    // MARK: - AuthorizeLoginViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        AuthorizationStartedWorker().execute()
        presenter?.presentData(actionResponse: .init(item: Models.Item(location: dataStore?.location,
                                                                       device: dataStore?.device,
                                                                       ipAddress: dataStore?.ipAddress)))
    }
    
    func authorize(viewAction: AuthorizeLoginModels.Authorize.ViewAction) {
        DynamicLinksManager.shared.loginToken = nil
        AuthorizeLoginWorker().execute() { [weak self] result in
            switch result {
            case .success(let authorization):
                self?.presenter?.presentAuthorization(actionResponse: .init(success: true))
                
            case .failure:
                self?.presenter?.presentAuthorization(actionResponse: .init(success: false))
            }
        }
    }

    // MARK: - Aditional helpers
}
