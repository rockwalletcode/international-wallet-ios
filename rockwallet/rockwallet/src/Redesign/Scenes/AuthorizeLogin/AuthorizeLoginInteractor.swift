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
        presenter?.presentData(actionResponse: .init(item: Models.Item(location: dataStore?.location,
                                                                       device: dataStore?.device,
                                                                       ipAddress: dataStore?.ipAddress)))
    }
    
    func authorize(viewAction: AuthorizeLoginModels.Authorize.ViewAction) {
//        DynamicLinksManager.shared.loginToken = nil // Call in case of failure
        // TODO: BE call
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.presenter?.presentAuthorization(actionResponse: .init(success: true))
        }
    }

    // MARK: - Aditional helpers
}
