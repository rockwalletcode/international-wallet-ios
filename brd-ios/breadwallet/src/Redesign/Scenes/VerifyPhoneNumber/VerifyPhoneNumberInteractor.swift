//
//  VerifyPhoneNumberInteractor.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import PhoneNumberKit

class VerifyPhoneNumberInteractor: NSObject, Interactor, VerifyPhoneNumberViewActions {
    typealias Models = VerifyPhoneNumberModels
    
    var presenter: VerifyPhoneNumberPresenter?
    var dataStore: VerifyPhoneNumberStore?
    
    // MARK: - VerifyPhoneNumberViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: nil))
    }
    
    func setPhoneNumber(viewAction: VerifyPhoneNumberModels.SetPhoneNumber.ViewAction) {
        dataStore?.phoneNumber = viewAction.phoneNumber?.removeWhitespaces()
        
        validate(viewAction: .init())
    }
    
    func validate(viewAction: VerifyPhoneNumberModels.Validate.ViewAction) {
        let phoneNumberKit = PhoneNumberKit()
        let isValid = phoneNumberKit.isValidPhoneNumber((dataStore?.country?.areaCode ?? "") + (dataStore?.phoneNumber ?? ""))
        
        Debounce<String>.input(dataStore?.phoneNumber ?? "", comparedAgainst: self.dataStore?.phoneNumber ?? "") { [weak self] _ in
            guard !isValid && self?.dataStore?.phoneNumber.isNilOrEmpty == false else { return }
            self?.presenter?.presentError(actionResponse: .init(error: GeneralError(errorMessage: L10n.VerifyPhoneNumber.Number.invalid)))
        }
        
        presenter?.presentValidate(actionResponse: .init(isValid: isValid))
    }
    
    func confirm(viewAction: VerifyPhoneNumberModels.Confirm.ViewAction) {
        let phoneNumber = (dataStore?.country?.areaCode ?? "") + (dataStore?.phoneNumber ?? "")
        
        let data = SetTwoStepPhoneRequestData(phone: phoneNumber)
        SetTwoStepPhoneWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success:
                UserDefaults.phoneNumber = phoneNumber
                
                UserManager.shared.refresh { _ in
                    self?.presenter?.presentConfirm(actionResponse: .init())
                }
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    // MARK: - Additional helpers
}
