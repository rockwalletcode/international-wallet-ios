//
//  ForgotPasswordVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let ForgotPassword = ForgotPasswordViewController.self
}

protocol ForgotPasswordViewActions: BaseViewActions, FetchViewActions {
    func validate(viewAction: ForgotPasswordModels.Validate.ViewAction)
    func next(viewAction: ForgotPasswordModels.Next.ViewAction)
}

protocol ForgotPasswordActionResponses: BaseActionResponses, FetchActionResponses {
    func presentValidate(actionResponse: ForgotPasswordModels.Validate.ActionResponse)
    func presentNext(actionResponse: ForgotPasswordModels.Next.ActionResponse)
}

protocol ForgotPasswordResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displayValidate(responseDisplay: ForgotPasswordModels.Validate.ResponseDisplay)
    func displayNext(responseDisplay: ForgotPasswordModels.Next.ResponseDisplay)
}

protocol ForgotPasswordDataStore: BaseDataStore, FetchDataStore {
    var email: String { get set }
}

protocol ForgotPasswordDataPassing {
    var dataStore: (any ForgotPasswordDataStore)? { get }
}

protocol ForgotPasswordRoutes: CoordinatableRoutes {
}
