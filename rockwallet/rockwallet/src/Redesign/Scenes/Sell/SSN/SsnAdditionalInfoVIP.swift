//
//  SsnAdditionalInfoVIP.swift
//  breadwallet
//
//  Created by Dino Gacevic on 24/07/2023.
//
//

import UIKit

extension Scenes {
    static let SsnAdditionalInfo = SsnAdditionalInfoViewController.self
}

protocol SsnAdditionalInfoViewActions: BaseViewActions, FetchViewActions {
    func validateSsn(viewAction: SsnAdditionalInfoModels.ValidateSsn.ViewAction)
    func confirmSsn(viewAction: SsnAdditionalInfoModels.ConfirmSsn.ViewAction)
    func showSsnError(viewAction: SsnAdditionalInfoModels.SsnError.ViewAction)
}

protocol SsnAdditionalInfoActionResponses: BaseActionResponses, FetchActionResponses {
    func presentValidateSsn(actionResponse: SsnAdditionalInfoModels.ValidateSsn.ActionResponse)
    func presentConfirmSsn(actionResponse: SsnAdditionalInfoModels.ConfirmSsn.ActinResponse)
    func presentSsnError(actionResponse: SsnAdditionalInfoModels.SsnError.ActionResponse)
}

protocol SsnAdditionalInfoResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayValidateSsn(responseDisplay: SsnAdditionalInfoModels.ValidateSsn.ResponseDisplay)
    func displayConfirmSsn(responseDisplay: SsnAdditionalInfoModels.ConfirmSsn.ResponseDisplay)
}

protocol SsnAdditionalInfoDataStore: BaseDataStore {
    var ssn: String? { get set }
}

protocol SsnAdditionalInfoDataPassing {
    var dataStore: (any SsnAdditionalInfoDataStore)? { get }
}

protocol SsnAdditionalInfoRoutes: CoordinatableRoutes {
}
