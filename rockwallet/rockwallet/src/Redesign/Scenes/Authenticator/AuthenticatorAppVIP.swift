//
//  AuthenticatorAppVIP.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 29.3.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let AuthenticatorApp = AuthenticatorAppViewController.self
}

protocol AuthenticatorAppViewActions: BaseViewActions, FetchViewActions, CopyValueActions {
    func openTotpUrl(viewAction: AuthenticatorAppModels.OpenTotpUrl.ViewAction)
    func next(viewAction: AuthenticatorAppModels.Next.ViewAction)
}

protocol AuthenticatorAppActionResponses: BaseActionResponses, FetchActionResponses, CopyValueResponses {
    func presentOpenTotpUrl(actionResponse: AuthenticatorAppModels.OpenTotpUrl.ActionResponse)
    func presentNext(actionResponse: AuthenticatorAppModels.Next.ActionResponse)
}

protocol AuthenticatorAppResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displayNext(responseDisplay: AuthenticatorAppModels.Next.ResponseDisplay)
    func displayOpenTotpUrl(responseDisplay: AuthenticatorAppModels.OpenTotpUrl.ResponseDisplay)
}

protocol AuthenticatorAppDataStore: BaseDataStore, FetchDataStore {
    var setTwoStepAppModel: SetTwoStepAuth? { get set }
}

protocol AuthenticatorAppDataPassing {
    var dataStore: (any AuthenticatorAppDataStore)? { get }
}

protocol AuthenticatorAppRoutes: CoordinatableRoutes {
}
