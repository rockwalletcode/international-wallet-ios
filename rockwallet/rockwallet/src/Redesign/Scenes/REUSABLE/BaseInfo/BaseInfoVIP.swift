//
//  BaseInfoVIP.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 13.7.22.
//
//

import UIKit

extension Scenes {
    static let BaseInfo = BaseInfoViewController.self
}

protocol BaseInfoViewActions: BaseViewActions, FetchViewActions {
    func getAssetSelectionData(viewModel: BaseInfoModels.Assets.ViewAction)
}

protocol BaseInfoActionResponses: BaseActionResponses, FetchActionResponses {
    func presentAssetSelectionData(actionResponse: BaseInfoModels.Assets.ActionResponse)
}

protocol BaseInfoResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displayAssetSelectionData(responseDisplay: BaseInfoModels.Assets.ResponseDisplay)
}

protocol BaseInfoDataStore: BaseDataStore, FetchDataStore {
    var item: Any? { get set }
    var coreSystem: CoreSystem? { get set }
    var keyStore: KeyStore? { get set }
    var id: String? { get set }
    var restrictionReason: Profile.AccessRights.RestrictionReason? { get set }
}

protocol BaseInfoDataPassing {
    var dataStore: (any BaseInfoDataStore)? { get }
}

protocol BaseInfoRoutes: CoordinatableRoutes {
}
