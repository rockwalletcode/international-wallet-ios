//
//  SsnAdditionalInfoInteractor.swift
//  breadwallet
//
//  Created by Dino Gacevic on 24/07/2023.
//
//

import UIKit

class SsnAdditionalInfoInteractor: NSObject, Interactor, SsnAdditionalInfoViewActions {
    typealias Models = SsnAdditionalInfoModels

    var presenter: SsnAdditionalInfoPresenter?
    var dataStore: SsnAdditionalInfoStore?

    // MARK: - SsnAdditionalInfoViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: dataStore?.ssn))
    }
    
    func validateSsn(viewAction: SsnAdditionalInfoModels.ValidateSsn.ViewAction) {
        dataStore?.ssn = viewAction.value
        presenter?.presentValidateSsn(actionResponse: .init(isValid: dataStore?.isSsnValid ?? false))
    }
    
    func confirmSsn(viewAction: SsnAdditionalInfoModels.ConfirmSsn.ViewAction) {
        presenter?.presentConfirmSsn(actionResponse: .init(ssn: dataStore?.ssn))
    }
    
    func showSsnError(viewAction: SsnAdditionalInfoModels.SsnError.ViewAction) {
        presenter?.presentSsnError(actionResponse: .init(ssn: dataStore?.ssn, error: viewAction.error))
    }

    // MARK: - Aditional helpers
}
