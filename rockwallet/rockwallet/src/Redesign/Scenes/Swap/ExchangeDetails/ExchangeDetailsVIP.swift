//
//  ExchangeDetailsVIP.swift
//  breadwallet
//
//  Created by Rok on 06/07/2022.
//
//

import UIKit

extension Scenes {
    static let ExchangeDetails = ExchangeDetailsViewController.self
}

protocol ExchangeDetailsViewActions: BaseViewActions, FetchViewActions, CopyValueActions {
    func showInfoPopup(viewAction: ExchangeDetailsModels.InfoPopup.ViewAction)
}

protocol ExchangeDetailsActionResponses: BaseActionResponses, FetchActionResponses, CopyValueResponses {
    func presentInfoPopup(actionResponse: ExchangeDetailsModels.InfoPopup.ActionResponse)
}

protocol ExchangeDetailsResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displayInfoPopup(responseDisplay: ExchangeDetailsModels.InfoPopup.ResponseDisplay)
}

protocol ExchangeDetailsDataStore: BaseDataStore, FetchDataStore {
    var exchangeType: ExchangeType { get set }
    var transactionPart: ExchangeDetail.SourceDestination.Part { get set }
    var exchangeId: String? { get set }
}

protocol ExchangeDetailsDataPassing {
    var dataStore: (any ExchangeDetailsDataStore)? { get }
}

protocol ExchangeDetailsRoutes: CoordinatableRoutes {
}
