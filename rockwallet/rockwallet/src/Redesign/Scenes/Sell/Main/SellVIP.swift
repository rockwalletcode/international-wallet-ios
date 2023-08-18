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
                          AssetViewActions,
                          PaymentMethodsViewActions,
                          CreateTransactionViewActions {
    func showOrderPreview(viewAction: SellModels.OrderPreview.ViewAction)
    func navigateAssetSelector(viewAction: SellModels.AssetSelector.ViewAction)
    func showLimitsInfo(viewAction: SellModels.LimitsInfo.ViewAction)
    func showInstantAchPopup(viewAction: SellModels.InstantAchPopup.ViewAction)
    func showAssetSelectionMessage(viewAction: SellModels.AssetSelectionMessage.ViewAction)
}

protocol SellActionResponses: BaseActionResponses,
                              FetchActionResponses,
                              AssetActionResponses,
                              PaymentMethodsActionResponses {
    func presentOrderPreview(actionResponse: SellModels.OrderPreview.ActionResponse)
    func presentNavigateAssetSelector(actionResponse: SellModels.AssetSelector.ActionResponse)
    func presentAchSuccess(actionResponse: SellModels.AchSuccess.ActionResponse)
    func presentLimitsInfo(actionResponse: SellModels.LimitsInfo.ActionResponse)
    func presentInstantAchPopup(actionResponse: SellModels.InstantAchPopup.ActionResponse)
    func presentAssetSelectionMessage(actionResponse: SellModels.AssetSelectionMessage.ActionResponse)
}

protocol SellResponseDisplays: BaseResponseDisplays,
                               FetchResponseDisplays,
                               AssetResponseDisplays,
                               PaymentMethodsResponseDisplays {
    func displayOrderPreview(responseDisplay: SellModels.OrderPreview.ResponseDisplay)
    func displayNavigateAssetSelector(responseDisplay: SellModels.AssetSelector.ResponseDisplay)
    func displayLimitsInfo(responseDisplay: SellModels.LimitsInfo.ResponseDisplay)
    func displayInstantAchPopup(responseDisplay: SellModels.InstantAchPopup.ResponseDisplay)
    func displayAssetSelectionMessage(responseDisplay: SellModels.AssetSelectionMessage.ResponseDisplay)
}

protocol SellDataStore: BaseDataStore, FetchDataStore, AssetDataStore, PaymentMethodsDataStore, CreateTransactionDataStore, TwoStepDataStore {
    // MARK: - SellDataStore
    
    var availablePayments: [PaymentCard.PaymentType] { get set }
    var fromRate: Decimal? { get set }
    var fromAmount: Amount? { get set }
    var exchange: Exchange? { get set }
    var createTransactionModel: CreateTransactionModels.Transaction.ViewAction? { get set }
    var hasCardSellAccess: Bool { get }
    var hasAchSellAccess: Bool { get }
}

protocol SellDataPassing {
    var dataStore: (any SellDataStore)? { get }
}

protocol SellRoutes: CoordinatableRoutes {
}
