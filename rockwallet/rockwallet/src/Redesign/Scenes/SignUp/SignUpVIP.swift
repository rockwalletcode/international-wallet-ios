//
//  SignUpVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 10/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let SignUp = SignUpViewController.self
}

protocol SignUpViewActions: BaseViewActions, FetchViewActions {
    func validate(viewAction: SignUpModels.Validate.ViewAction)
    func toggleTermsTickbox(viewAction: SignUpModels.TermsTickbox.ViewAction)
    func togglePromotionsTickbox(viewAction: SignUpModels.PromotionsTickbox.ViewAction)
    func next(viewAction: SignUpModels.Next.ViewAction)
}

protocol SignUpActionResponses: BaseActionResponses, FetchActionResponses {
    func presentValidate(actionResponse: SignUpModels.Validate.ActionResponse)
    func presentNext(actionResponse: SignUpModels.Next.ActionResponse)
}

protocol SignUpResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displayValidate(responseDisplay: SignUpModels.Validate.ResponseDisplay)
    func displayNext(responseDisplay: SignUpModels.Next.ResponseDisplay)
}

protocol SignUpDataStore: BaseDataStore, FetchDataStore {
    var email: String { get set }
    var password: String { get set }
    var passwordAgain: String { get set }
    var termsTickbox: Bool { get set }
    var promotionsTickbox: Bool { get set }
}

protocol SignUpDataPassing {
    var dataStore: (any SignUpDataStore)? { get }
}

protocol SignUpRoutes: CoordinatableRoutes {
}
