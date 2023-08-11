//
//  DeleteProfileInfoVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 19/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let DeleteProfileInfo = DeleteProfileInfoViewController.self
}

protocol DeleteProfileInfoViewActions: BaseViewActions, FetchViewActions {
    func deleteProfile(viewAction: DeleteProfileInfoModels.DeleteProfile.ViewAction)
    func wipeWallet(viewAction: DeleteProfileInfoModels.WipeWalletNoPrompt.ViewAction)
    func toggleTickbox(viewAction: DeleteProfileInfoModels.Tickbox.ViewAction)
}

protocol DeleteProfileInfoActionResponses: BaseActionResponses, FetchActionResponses {
    func presentToggleTickbox(actionResponse: DeleteProfileInfoModels.Tickbox.ActionResponse)
    func presentDeleteProfile(actionResponse: DeleteProfileInfoModels.DeleteProfile.ActionResponse)
}

protocol DeleteProfileInfoResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displayToggleTickbox(responseDisplay: DeleteProfileInfoModels.Tickbox.ResponseDisplay)
    func displayDeleteProfile(responseDisplay: DeleteProfileInfoModels.DeleteProfile.ResponseDisplay)
}

protocol DeleteProfileInfoDataStore: BaseDataStore, FetchDataStore {
    var keyStore: KeyStore? { get set }
}

protocol DeleteProfileInfoDataPassing {
    var dataStore: (any DeleteProfileInfoDataStore)? { get }
}

protocol DeleteProfileInfoRoutes: CoordinatableRoutes {
}
