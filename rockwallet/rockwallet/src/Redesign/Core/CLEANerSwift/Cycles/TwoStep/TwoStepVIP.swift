// 
//  TwoStepVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 18/05/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

protocol TwoStepViewActions: BaseViewActions, FetchViewActions {
    func handleNextFailure(viewAction: TwoStepModels.NextFailure.ViewAction)
}

protocol TwoStepActionResponses: BaseActionResponses, FetchActionResponses {
    func presentNextFailure(actionResponse: TwoStepModels.NextFailure.ActionResponse)
}

protocol TwoStepResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displayNextFailure(responseDisplay: TwoStepModels.NextFailure.ResponseDisplay)
}

protocol TwoStepDataStore: BaseDataStore, FetchDataStore {
    var secondFactorCode: String? { get set }
    var secondFactorBackup: String? { get set }
}

extension Interactor where Self: TwoStepViewActions,
                           Self.DataStore: TwoStepDataStore,
                           Self.ActionResponses: TwoStepActionResponses {
    func handleNextFailure(viewAction: TwoStepModels.NextFailure.ViewAction) {
        guard let error = (viewAction.error as? NetworkingError) else { return }
        
        guard error.errorCategory == .twoStep else {
            presenter?.presentError(actionResponse: .init(error: error))
            return
        }
        
        if error.errorType == .twoStepInvalidCode {
            presenter?.presentError(actionResponse: .init(error: error))
        }
        
        presenter?.presentNextFailure(actionResponse: .init(reason: error,
                                                            registrationRequestData: viewAction.registrationRequestData,
                                                            setPasswordRequestData: viewAction.setPasswordRequestData))
    }
}

extension Presenter where Self: TwoStepActionResponses,
                          Self.ResponseDisplays: TwoStepResponseDisplays {
    func presentNextFailure(actionResponse: TwoStepModels.NextFailure.ActionResponse) {
        viewController?.displayNextFailure(responseDisplay: .init(reason: actionResponse.reason,
                                                                  registrationRequestData: actionResponse.registrationRequestData,
                                                                  setPasswordRequestData: actionResponse.setPasswordRequestData))
    }
}

extension Controller where Self: TwoStepResponseDisplays,
                           Self.ViewActions: TwoStepViewActions {
    func displayNextFailure(responseDisplay: TwoStepModels.NextFailure.ResponseDisplay) {
        (coordinator as? AccountCoordinator)?.showTwoStepErrorFlow(reason: responseDisplay.reason,
                                                                   registrationRequestData: responseDisplay.registrationRequestData,
                                                                   setPasswordRequestData: responseDisplay.setPasswordRequestData)
        
    }
}
