//
//  TwoStepSettingsVIP.swift
//  breadwallet
//
//  Created by Dino Gacevic on 17/04/2023.
//
//

import UIKit

extension Scenes {
    static let TwoStepSettings = TwoStepSettingsViewController.self
}

protocol TwoStepSettingsViewActions: BaseViewActions, FetchViewActions {
    func toggleSetting(viewAction: TwoStepSettingsModels.ToggleSetting.ViewAction)
}

protocol TwoStepSettingsActionResponses: BaseActionResponses, FetchActionResponses {
}

protocol TwoStepSettingsResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
}

protocol TwoStepSettingsDataStore: BaseDataStore, FetchDataStore {
}

protocol TwoStepSettingsDataPassing {
    var dataStore: (any TwoStepSettingsDataStore)? { get }
}

protocol TwoStepSettingsRoutes: CoordinatableRoutes {
}
