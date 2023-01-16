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

protocol SignInViewActions: BaseViewActions, FetchViewActions {
    func validate(viewAction: SignInModels.Validate.ViewAction)
}

protocol SignInActionResponses: BaseActionResponses, FetchActionResponses {
    func presentValidate(actionResponse: SignInModels.Validate.ActionResponse)
}

protocol SignInResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayValidate(responseDisplay: SignInModels.Validate.ResponseDisplay)
}

protocol SignInDataStore: BaseDataStore, FetchDataStore {
    var email: String? { get set }
    var password: String? { get set }
}

protocol SignInDataPassing {
    var dataStore: SignInDataStore? { get }
}

protocol SignInRoutes: CoordinatableRoutes {
}
