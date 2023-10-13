//
//  AuthorizeLoginVIP.swift
//  rockwallet
//
//  Created by Dino Gačević on 05/10/2023.
//
//

import UIKit

extension Scenes {
    static let AuthorizeLogin = AuthorizeLoginViewController.self
}

protocol AuthorizeLoginViewActions: BaseViewActions, FetchViewActions {
    func authorize(viewAction: AuthorizeLoginModels.Authorize.ViewAction)
    func reject(viewAction: AuthorizeLoginModels.Reject.ViewAction)
}

protocol AuthorizeLoginActionResponses: BaseActionResponses, FetchActionResponses {
    func presentAuthorization(actionResponse: AuthorizeLoginModels.Authorize.ActionResponse)
    func presentRejection(actionResponse: AuthorizeLoginModels.Reject.ActionResponse)
}

protocol AuthorizeLoginResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displayAuthorization(responseDisplay: AuthorizeLoginModels.Authorize.ResponseDisplay)
    func displayRejection(responseDisplay: AuthorizeLoginModels.Reject.ResponseDisplay)
}

protocol AuthorizeLoginDataStore: BaseDataStore {
    var location: String? { get set }
    var device: String? { get set }
    var ipAddress: String? { get set }
}

protocol AuthorizeLoginDataPassing {
    var dataStore: (any AuthorizeLoginDataStore)? { get }
}

protocol AuthorizeLoginRoutes: CoordinatableRoutes {
}
