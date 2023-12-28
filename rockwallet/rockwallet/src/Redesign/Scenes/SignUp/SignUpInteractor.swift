//
//  SignUpInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 10/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SignUpInteractor: NSObject, Interactor, SignUpViewActions {
    
    typealias Models = SignUpModels
    
    var presenter: SignUpPresenter?
    var dataStore: SignUpStore?
    
    // MARK: - SignUpViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: Models.Item(email: dataStore?.email,
                                                                       password: dataStore?.password,
                                                                       passwordAgain: dataStore?.passwordAgain)))
    }
    
    func validate(viewAction: SignUpModels.Validate.ViewAction) {
        if let email = viewAction.email {
            dataStore?.email = email
        }
        
        if let password = viewAction.password {
            dataStore?.password = password
        }
        
        if let passwordAgain = viewAction.passwordAgain {
            dataStore?.passwordAgain = passwordAgain
        }
        
        let isEmailValid = dataStore?.email.isValidEmailAddress ?? false
        let isEmailEmpty = dataStore?.email.isEmpty == true
        let emailState: DisplayState? = isEmailEmpty || isEmailValid ? nil : .error
        
        let isPasswordValid = dataStore?.password.isValidPassword ?? false
        let isPasswordEmpty = dataStore?.password.isEmpty == true
        let passwordState: DisplayState? = isPasswordEmpty || isPasswordValid ? nil : .error
        
        let isPasswordAgainValid = dataStore?.passwordAgain.isValidPassword ?? false
        let isPasswordAgainEmpty = dataStore?.passwordAgain.isEmpty == true
        let passwordAgainState: DisplayState? = isPasswordAgainEmpty || isPasswordAgainValid ? nil : .error
        
        let passwordsMatch = !isPasswordEmpty && !isPasswordAgainEmpty && dataStore?.password == dataStore?.passwordAgain
        
        let isTermsTickboxValid = dataStore?.termsTickbox == true && dataStore?.termsTickboxPro == true
        
        presenter?.presentValidate(actionResponse: .init(email: viewAction.email,
                                                         password: viewAction.password,
                                                         passwordAgain: viewAction.passwordAgain,
                                                         isEmailValid: isEmailValid,
                                                         isEmailEmpty: isEmailEmpty,
                                                         emailState: emailState,
                                                         isPasswordValid: isPasswordValid,
                                                         isPasswordEmpty: isPasswordEmpty,
                                                         passwordState: passwordState,
                                                         isPasswordAgainValid: isPasswordAgainValid,
                                                         isPasswordAgainEmpty: isPasswordAgainEmpty,
                                                         passwordAgainState: passwordAgainState,
                                                         passwordsMatch: passwordsMatch,
                                                         isTermsTickboxValid: isTermsTickboxValid))
    }
    
    func toggleTermsTickbox(viewAction: SignUpModels.TermsTickbox.ViewAction) {
        if viewAction.valuePro != nil {
            dataStore?.termsTickboxPro = viewAction.valuePro ?? false
        } else {
            dataStore?.termsTickbox = viewAction.value ?? false
        }
        
        validate(viewAction: .init())
    }
    
    func togglePromotionsTickbox(viewAction: SignUpModels.PromotionsTickbox.ViewAction) {
        dataStore?.promotionsTickbox = viewAction.value
    }
    
    func next(viewAction: SignUpModels.Next.ViewAction) {
        guard let email = dataStore?.email,
              let password = dataStore?.password,
              let token = UserDefaults.walletTokenValue else { return }
        
        let data = RegistrationRequestData(email: email,
                                           password: password,
                                           token: token,
                                           subscribe: dataStore?.promotionsTickbox ?? false,
                                           accountHandling: .register)
        RegistrationWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let data):
                guard let sessionKey = data?.sessionKey, let sessionKeyHash = data?.sessionKeyHash else { return }
                
                UserManager.shared.setUserCredentials(email: email, sessionToken: sessionKey, sessionTokenHash: sessionKeyHash, newAccount: true)
                
                UserManager.shared.refresh { _ in
                    self?.presenter?.presentNext(actionResponse: .init())
                }
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    // MARK: - Additional helpers
}
