//
//  BuyVIP.swift
//  breadwallet
//
//  Created by Rok on 01/08/2022.
//
//

import UIKit
import WalletKit

extension Scenes {
    static let Buy = BuyViewController.self
}

protocol BuyViewActions: BaseViewActions,
                         FetchViewActions,
                         AssetViewActions,
                         PaymentMethodsViewActions {
    func showOrderPreview(viewAction: BuyModels.OrderPreview.ViewAction)
    func navigateAssetSelector(viewAction: BuyModels.AssetSelector.ViewAction)
    func selectPaymentMethod(viewAction: BuyModels.PaymentMethod.ViewAction)
    func retryPaymentMethod(viewAction: BuyModels.RetryPaymentMethod.ViewAction)
    func showLimitsInfo(viewAction: BuyModels.LimitsInfo.ViewAction)
    func showInstantAchPopup(viewAction: BuyModels.InstantAchPopup.ViewAction)
    func showAssetSelectionMessage(viewAction: BuyModels.AssetSelectionMessage.ViewAction)
}

protocol BuyActionResponses: BaseActionResponses,
                             FetchActionResponses,
                             AssetActionResponses,
                             PaymentMethodsActionResponses {
    func presentOrderPreview(actionResponse: BuyModels.OrderPreview.ActionResponse)
    func presentNavigateAssetSelector(actionResponse: BuyModels.AssetSelector.ActionResponse)
    func presentMessage(actionResponse: BuyModels.RetryPaymentMethod.ActionResponse)
    func presentAchSuccess(actionResponse: BuyModels.AchSuccess.ActionResponse)
    func presentLimitsInfo(actionResponse: BuyModels.LimitsInfo.ActionResponse)
    func presentInstantAchPopup(actionResponse: BuyModels.InstantAchPopup.ActionResponse)
    func presentAssetSelectionMessage(actionResponse: BuyModels.AssetSelectionMessage.ActionResponse)
}

protocol BuyResponseDisplays: BaseResponseDisplays, FetchResponseDisplays, AssetResponseDisplays, PaymentMethodsResponseDisplays {
    func displayOrderPreview(responseDisplay: BuyModels.OrderPreview.ResponseDisplay)
    func displayNavigateAssetSelector(responseDisplay: BuyModels.AssetSelector.ResponseDisplay)
    func displayLimitsInfo(responseDisplay: BuyModels.LimitsInfo.ResponseDisplay)
    func displayInstantAchPopup(responseDisplay: BuyModels.InstantAchPopup.ResponseDisplay)
    func displayAssetSelectionMessage(responseDisplay: BuyModels.AssetSelectionMessage.ResponseDisplay)
}

protocol BuyDataStore: BaseDataStore, FetchDataStore, AssetDataStore, PaymentMethodsDataStore, TwoStepDataStore, CreateTransactionDataStore {
    var from: Decimal? { get set }
    var to: Decimal? { get set }
    var toAmount: Amount? { get set }
    var publicToken: String? { get set }
    var mask: String? { get set }
    var availablePayments: [PaymentCard.PaymentType] { get set }
}

protocol BuyDataPassing: PaymentMethodsDataStore {
    var dataStore: (any BuyDataStore)? { get }
}

protocol BuyRoutes: CoordinatableRoutes {
}
