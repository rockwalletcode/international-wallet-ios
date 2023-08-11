//
//  ProfileVIP.swift
//  breadwallet
//
//  Created by Rok on 26/05/2022.
//
//

import UIKit

extension Scenes {
    static let Profile = ProfileViewController.self
}

protocol ProfileViewActions: BaseViewActions, FetchViewActions {
    func showVerificationInfo(viewAction: ProfileModels.VerificationInfo.ViewAction)
    func navigate(viewAction: ProfileModels.Navigate.ViewAction)
    func logout(viewAction: ProfileModels.Logout.ViewAction)
}

protocol ProfileActionResponses: BaseActionResponses, FetchActionResponses {
    func presentVerificationInfo(actionResponse: ProfileModels.VerificationInfo.ActionResponse)
    func presentNavigation(actionResponse: ProfileModels.Navigate.ActionResponse)
    func presentLogout(actionResponse: ProfileModels.Logout.ActionResponse)
}

protocol ProfileResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displayVerificationInfo(responseDisplay: ProfileModels.VerificationInfo.ResponseDisplay)
    func displayNavigation(responseDisplay: ProfileModels.Navigate.ResponseDisplay)
    func displayLogout(responseDisplay: ProfileModels.Logout.ResponseDisplay)
}

protocol ProfileDataStore: BaseDataStore, FetchDataStore {
}

protocol ProfileDataPassing {
    var dataStore: (any ProfileDataStore)? { get }
}

protocol ProfileRoutes: CoordinatableRoutes {
    func showSecuirtySettings()
    func showPreferences()
}
