//
//  TransferFundsVIP.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 21.9.23.
//
//

import UIKit

extension Scenes {
    static let TransferFunds = TransferFundsViewController.self
}

protocol TransferFundsViewActions: BaseViewActions, FetchViewActions, AssetViewActions {
    func navigateAssetSelector(viewAction: TransferFundsModels.AssetSelector.ViewAction)
    func showAssetSelectionMessage(viewAction: TransferFundsModels.AssetSelectionMessage.ViewAction)
}

protocol TransferFundsActionResponses: BaseActionResponses, FetchActionResponses, AssetActionResponses {
    func presentNavigateAssetSelector(actionResponse: TransferFundsModels.AssetSelector.ActionResponse)
    func presentAssetSelectionMessage(actionResponse: TransferFundsModels.AssetSelectionMessage.ActionResponse)
}

protocol TransferFundsResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays, AssetResponseDisplays {
    func displayNavigateAssetSelector(responseDisplay: TransferFundsModels.AssetSelector.ResponseDisplay)
    func displayAssetSelectionMessage(responseDisplay: TransferFundsModels.AssetSelectionMessage.ResponseDisplay)
}

protocol TransferFundsDataStore: BaseDataStore, FetchDataStore, AssetDataStore {
    var from: Decimal? { get set }
    var to: Decimal? { get set }
    var toAmount: Amount? { get set }
    var publicToken: String? { get set }
    var mask: String? { get set }
    var availablePayments: [PaymentCard.PaymentType] { get set }
}

protocol TransferFundsDataPassing {
    var dataStore: (any TransferFundsDataStore)? { get }
}

protocol TransferFundsRoutes: CoordinatableRoutes {
}