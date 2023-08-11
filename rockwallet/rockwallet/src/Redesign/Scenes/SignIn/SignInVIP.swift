//
//  SignInVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 09/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let SignIn = SignInViewController.self
}

protocol SignInViewActions: BaseViewActions, FetchViewActions, TwoStepViewActions {
    func validate(viewAction: SignInModels.Validate.ViewAction)
    func next(viewAction: SignInModels.Next.ViewAction)
}

protocol SignInActionResponses: BaseActionResponses, FetchActionResponses, TwoStepActionResponses {
    func presentValidate(actionResponse: SignInModels.Validate.ActionResponse)
    func presentNext(actionResponse: SignInModels.Next.ActionResponse)
}

protocol SignInResponseDisplays: BaseResponseDisplays, FetchResponseDisplays, TwoStepResponseDisplays {
    func displayValidate(responseDisplay: SignInModels.Validate.ResponseDisplay)
    func displayNext(responseDisplay: SignInModels.Next.ResponseDisplay)
}

protocol SignInDataStore: BaseDataStore, FetchDataStore, TwoStepDataStore {
    var email: String { get set }
    var password: String { get set }
}

protocol SignInDataPassing {
    var dataStore: (any SignInDataStore)? { get }
}

protocol SignInRoutes: CoordinatableRoutes {
}
