//
//  OrderPreviewVIP.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.8.22.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WalletKit

extension Scenes {
    static let OrderPreview = OrderPreviewViewController.self
}

protocol OrderPreviewViewActions: BaseViewActions, FetchViewActions, CreateTransactionViewActions {
    func showTermsAndConditions(viewAction: OrderPreviewModels.TermsAndConditions.ViewAction)
    func checkTimeOut(viewAction: OrderPreviewModels.ExpirationValidations.ViewAction)
    func showInfoPopup(viewAction: OrderPreviewModels.InfoPopup.ViewAction)
    func updateCvv(viewAction: OrderPreviewModels.CvvValidation.ViewAction)
    func showCvvInfoPopup(viewAction: OrderPreviewModels.CvvInfoPopup.ViewAction)
    func checkBiometricStatus(viewAction: OrderPreviewModels.BiometricStatusCheck.ViewAction)
    func showAchInstantDrawer(viewAction: OrderPreviewModels.AchInstantDrawer.ViewAction)
    func submit(viewAction: OrderPreviewModels.Submit.ViewAction)
    func toggleTickbox(viewAction: OrderPreviewModels.Tickbox.ViewAction)
    func changeAchDeliveryType(viewAction: OrderPreviewModels.SelectAchDeliveryType.ViewAction)
}

protocol OrderPreviewActionResponses: BaseActionResponses, FetchActionResponses {
    func presentTermsAndConditions(actionResponse: OrderPreviewModels.TermsAndConditions.ActionResponse)
    func presentTimeOut(actionResponse: OrderPreviewModels.ExpirationValidations.ActionResponse)
    func presentInfoPopup(actionResponse: OrderPreviewModels.InfoPopup.ActionResponse)
    func presentCvv(actionResponse: OrderPreviewModels.CvvValidation.ActionResponse)
    func presentCvvInfoPopup(actionResponse: OrderPreviewModels.CvvInfoPopup.ActionResponse)
    func presentThreeDSecure(actionResponse: OrderPreviewModels.ThreeDSecure.ActionResponse)
    func presentVeriffLivenessCheck(actionResponse: OrderPreviewModels.VeriffLivenessCheck.ActionResponse)
    func presentSubmit(actionResponse: OrderPreviewModels.Submit.ActionResponse)
    func presentToggleTickbox(actionResponse: OrderPreviewModels.Tickbox.ActionResponse)
    func presentAchInstantDrawer(actionResponse: OrderPreviewModels.AchInstantDrawer.ActionResponse)
    func presentBiometricStatusFailed(actionResponse: OrderPreviewModels.BiometricStatusFailed.ActionResponse)
    func presentPreview(actionRespone: OrderPreviewModels.Preview.ActionResponse)
}

protocol OrderPreviewResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displayTermsAndConditions(responseDisplay: OrderPreviewModels.TermsAndConditions.ResponseDisplay)
    func displayTimeOut(responseDisplay: OrderPreviewModels.ExpirationValidations.ResponseDisplay)
    func displayInfoPopup(responseDisplay: OrderPreviewModels.InfoPopup.ResponseDisplay)
    func displayContinueEnabled(responseDisplay: OrderPreviewModels.CvvValidation.ResponseDisplay)
    func displayCvvInfoPopup(responseDisplay: OrderPreviewModels.CvvInfoPopup.ResponseDisplay)
    func displayThreeDSecure(responseDisplay: OrderPreviewModels.ThreeDSecure.ResponseDisplay)
    func displayVeriffLivenessCheck(responseDisplay: OrderPreviewModels.VeriffLivenessCheck.ResponseDisplay)
    func displaySubmit(responseDisplay: OrderPreviewModels.Submit.ResponseDisplay)
    func displayFailure(responseDisplay: OrderPreviewModels.Failure.ResponseDisplay)
    func displayAchInstantDrawer(responseDisplay: OrderPreviewModels.AchInstantDrawer.ResponseDisplay)
    func displayBiometricStatusFailed(responseDisplay: OrderPreviewModels.BiometricStatusFailed.ResponseDisplay)
    func displayPreview(responseDisplay: OrderPreviewModels.Preview.ResponseDsiaply)
}

protocol OrderPreviewDataStore: BaseDataStore, FetchDataStore, CreateTransactionDataStore, TwoStepDataStore {
    var type: PreviewType? { get set }
    var to: Amount? { get set }
    var from: Decimal? { get set }
    var toCurrency: String? { get set }
    var card: PaymentCard? { get set }
    var quote: Quote? { get set }
    var networkFee: Amount? { get }
    var cvv: String? { get set }
    var paymentReference: String? { get set }
    var paymentstatus: AddCard.Status? { get set }
    var availablePayments: [PaymentCard.PaymentType]? { get set }
    var isAchAccount: Bool { get }
    var createTransactionModel: CreateTransactionModels.Transaction.ViewAction? { get set }
}

protocol OrderPreviewDataPassing {
    var dataStore: (any OrderPreviewDataStore)? { get }
}

protocol OrderPreviewRoutes: CoordinatableRoutes {
    func showOrderPreview(type: PreviewType?,
                          coreSystem: CoreSystem?,
                          keyStore: KeyStore?,
                          to: Amount?,
                          from: Decimal?,
                          fromFeeBasis: WalletKit.TransferFeeBasis?,
                          card: PaymentCard?,
                          quote: Quote?,
                          availablePayments: [PaymentCard.PaymentType]?,
                          createTransactionModel: CreateTransactionModels.Transaction.ViewAction?)
    func showTermsAndConditions(url: URL)
    func showTimeout(type: PreviewType?)
    func showThreeDSecure(url: URL)
}
