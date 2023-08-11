//
//  WaitingVIP.swift
//  breadwallet
//
//  Created by Dino Gacevic on 25/07/2023.
//
//

import UIKit

extension Scenes {
    static let Waiting = WaitingViewController.self
}

protocol WaitingViewActions: BaseViewActions {
    func updateSsn(viewAction: WaitingModels.UpdateSsn.ViewAction)
}

protocol WaitingActionResponses: BaseActionResponses {
    func presentUpdateSsn(actionResponse: WaitingModels.UpdateSsn.ActionResponse)
}

protocol WaitingResponseDisplays: AnyObject, BaseResponseDisplays {
    func displayUpdateSsn(responseDisplay: WaitingModels.UpdateSsn.ResponseDisplay)
}

protocol WaitingDataStore: BaseDataStore {
    var ssn: String? { get set }
}

protocol WaitingDataPassing {
    var dataStore: (any WaitingDataStore)? { get }
}

protocol WaitingRoutes: CoordinatableRoutes {
}
