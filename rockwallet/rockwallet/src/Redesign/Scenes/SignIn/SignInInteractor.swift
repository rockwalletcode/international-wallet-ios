//
//  SignInInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 09/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SignInInteractor: NSObject, Interactor, SignInViewActions {
    
    typealias Models = SignInModels
    
    var presenter: SignInPresenter?
    var dataStore: SignInStore?
    
    // MARK: - SignInViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: Models.Item(email: "", password: "")))
    }
    
    func validate(viewAction: SignInModels.Validate.ViewAction) {
        if let email = viewAction.email {
            dataStore?.email = email
        }
        
        if let password = viewAction.password {
            dataStore?.password = password
        }
        
        let isEmailValid = dataStore?.email.isValidEmailAddress ?? false
        let isEmailEmpty = dataStore?.email.isEmpty == true
        let emailState: DisplayState? = isEmailEmpty || isEmailValid ? nil : .error
        
        let isPasswordValid = dataStore?.password.isValidPassword ?? false
        let isPasswordEmpty = dataStore?.password.isEmpty == true
        let passwordState: DisplayState? = isPasswordEmpty || isPasswordValid ? nil : .error
        
        presenter?.presentValidate(actionResponse: .init(email: viewAction.email,
                                                         password: viewAction.password,
                                                         isEmailValid: isEmailValid,
                                                         isEmailEmpty: isEmailEmpty,
                                                         emailState: emailState,
                                                         isPasswordValid: isPasswordValid,
                                                         isPasswordEmpty: isPasswordEmpty,
                                                         passwordState: passwordState))
    }
    
    func next(viewAction: SignInModels.Next.ViewAction) {
        guard let email = dataStore?.email,
              let password = dataStore?.password,
              let token = UserDefaults.walletTokenValue else { return }
        
        let data = RegistrationRequestData(email: email,
                                           password: password,
                                           token: token,
                                           subscribe: nil,
                                           accountHandling: .login)
        RegistrationWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let data):
                guard let sessionKey = data?.sessionKey,
                      let sessionKeyHash = data?.sessionKeyHash,
                      let sendXPubs = UserDefaults.sendXPubs else { return }
                
                UserManager.shared.setUserCredentials(email: email, sessionToken: sessionKey, sessionTokenHash: sessionKeyHash, sendXPubs: sendXPubs)
                
                UserManager.shared.refresh { _ in
                    self?.presenter?.presentNext(actionResponse: .init())
                }
                
                UserDefaults.sendXPubs = false
                
            case .failure(let error):
                self?.handleNextFailure(viewAction: .init(registrationRequestData: data, error: error))
            }
        }
    }
    
    // MARK: - Additional helpers
}
