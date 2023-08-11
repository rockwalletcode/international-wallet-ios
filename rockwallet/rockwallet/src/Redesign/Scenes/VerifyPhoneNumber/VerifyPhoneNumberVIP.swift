//
//  VerifyPhoneNumberVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let VerifyPhoneNumber = VerifyPhoneNumberViewController.self
}

protocol VerifyPhoneNumberViewActions: BaseViewActions, CountriesAndStatesViewActions {
    func validate(viewAction: VerifyPhoneNumberModels.Validate.ViewAction)
    func setPhoneNumber(viewAction: VerifyPhoneNumberModels.SetPhoneNumber.ViewAction)
    func confirm(viewAction: VerifyPhoneNumberModels.Confirm.ViewAction)
}

protocol VerifyPhoneNumberActionResponses: BaseActionResponses, CountriesAndStatesActionResponses {
    func presentValidate(actionResponse: VerifyPhoneNumberModels.Validate.ActionResponse)
    func presentSetAreaCode(actionResponse: VerifyPhoneNumberModels.SetAreaCode.ActionResponse)
    func presentConfirm(actionResponse: VerifyPhoneNumberModels.Confirm.ActionResponse)
}

protocol VerifyPhoneNumberResponseDisplays: BaseResponseDisplays, CountriesAndStatesResponseDisplays {
    func displayValidate(responseDisplay: VerifyPhoneNumberModels.Validate.ResponseDisplay)
    func displaySetAreaCode(responseDisplay: VerifyPhoneNumberModels.SetAreaCode.ResponseDisplay)
    func displayConfirm(responseDisplay: VerifyPhoneNumberModels.Confirm.ResponseDisplay)
}

protocol VerifyPhoneNumberDataStore: BaseDataStore, CountriesAndStatesDataStore {
    var phoneNumber: String? { get set }
}

protocol VerifyPhoneNumberDataPassing {
    var dataStore: (any VerifyPhoneNumberDataStore)? { get }
}

protocol VerifyPhoneNumberRoutes: CountriesAndStatesRoutes {
}
