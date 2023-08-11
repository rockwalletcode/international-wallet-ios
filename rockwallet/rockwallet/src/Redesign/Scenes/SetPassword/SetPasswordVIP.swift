//
//  SetPasswordVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let SetPassword = SetPasswordViewController.self
}

protocol SetPasswordViewActions: BaseViewActions, FetchViewActions, TwoStepViewActions {
    func validate(viewAction: SetPasswordModels.Validate.ViewAction)
    func next(viewAction: SetPasswordModels.Next.ViewAction)
}

protocol SetPasswordActionResponses: BaseActionResponses, FetchActionResponses, TwoStepActionResponses {
    func presentValidate(actionResponse: SetPasswordModels.Validate.ActionResponse)
    func presentNext(actionResponse: SetPasswordModels.Next.ActionResponse)
}

protocol SetPasswordResponseDisplays: BaseResponseDisplays, FetchResponseDisplays, TwoStepResponseDisplays {
    func displayValidate(responseDisplay: SetPasswordModels.Validate.ResponseDisplay)
    func displayNext(responseDisplay: SetPasswordModels.Next.ResponseDisplay)
}

protocol SetPasswordDataStore: BaseDataStore, FetchDataStore, TwoStepDataStore {
    var password: String { get set }
    var passwordAgain: String { get set }
    var code: String? { get set }
}

protocol SetPasswordDataPassing {
    var dataStore: (any SetPasswordDataStore)? { get }
}

protocol SetPasswordRoutes: CoordinatableRoutes {
}
