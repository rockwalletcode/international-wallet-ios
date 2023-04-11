//
//  SellVIP.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit

extension Scenes {
    static let Sell = SellViewController.self
}

protocol SellViewActions: BaseViewActions,
                          FetchViewActions,
                          ExchangeRateViewActions,
                          AchViewActions {
    func setAmount(viewAction: SellModels.Amounts.ViewAction)
}

protocol SellActionResponses: BaseActionResponses,
                              FetchActionResponses,
                              ExchangeRateActionResponses,
                              AchActionResponses {
    func presentAmount(actionResponse: SellModels.Amounts.ActionResponse)
}

protocol SellResponseDisplays: AnyObject,
                               BaseResponseDisplays,
                               FetchResponseDisplays,
                               ExchangeRateResponseDisplays,
                               AchResponseDisplays {
}

protocol SellDataStore: BaseDataStore, ExchangeDataStore, AchDataStore {
}

protocol SellDataPassing {
    var dataStore: (any SellDataStore)? { get }
}

protocol SellRoutes: CoordinatableRoutes {
}
