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
        AuthorizationStartedWorker().execute { [weak self] result in
            switch result {
            case .success(let response):
                self?.dataStore?.device = response?.device
                self?.dataStore?.location = response?.location
                self?.dataStore?.ipAddress = response?.ipAddress
                
                self?.presenter?.presentData(actionResponse: .init(item: Models.Item(countdownTime: response?.countdownTime,
                                                                                     location: self?.dataStore?.location,
                                                                                     device: self?.dataStore?.device,
                                                                                     ipAddress: self?.dataStore?.ipAddress)))
                
            case .failure:
                self?.presenter?.presentAuthorization(actionResponse: .init(success: false))
            }
            
        }
        
    }
    
    func authorize(viewAction: AuthorizeLoginModels.Authorize.ViewAction) {
        guard let email = UserManager.shared.profile?.email,
              let deviceToken = UserDefaults.walletTokenValue,
              let token = DynamicLinksManager.shared.loginToken else {
            return
        }
        
        DynamicLinksManager.shared.loginToken = nil
        let requestData = AuthorizeLoginRequestData(email: email, token: token, deviceToken: deviceToken)
        AuthorizeLoginWorker().execute(requestData: requestData) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.presentAuthorization(actionResponse: .init(success: true))
                
            case .failure:
                self?.presenter?.presentAuthorization(actionResponse: .init(success: false))
            }
        }
    }
    
    func reject(viewAction: AuthorizeLoginModels.Reject.ViewAction) {
        RejectLoginWorker().execute { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.presentRejection(actionResponse: .init(success: true))
                
            case .failure:
                self?.presenter?.presentRejection(actionResponse: .init(success: false))
            }
        }
    }

    // MARK: - Aditional helpers
}
