//
//  PaymailAddressVIP.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.4.23.
//
//

import UIKit

extension Scenes {
    static let PaymailAddress = PaymailAddressViewController.self
}

protocol PaymailAddressViewActions: BaseViewActions, FetchViewActions, CopyValueActions {
    func createPaymailAddress(viewAction: PaymailAddressModels.CreatePaymail.ViewAction)
    func showPaymailPopup(viewAction: PaymailAddressModels.InfoPopup.ViewAction)
    func showSuccessBottomAlert(viewAction: PaymailAddressModels.BottomAlert.ViewAction)
}

protocol PaymailAddressActionResponses: BaseActionResponses, FetchActionResponses, CopyValueResponses {
    func presentPaymailSuccess(actionResponse: PaymailAddressModels.CreatePaymail.ActionResponse)
    func presentPaymailPopup(actionResponse: PaymailAddressModels.InfoPopup.ActionResponse)
    func presentSuccessBottomAlert(actionResponse: PaymailAddressModels.BottomAlert.ActionResponse)
}

protocol PaymailAddressResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displayPaymailSuccess(responseDisplay: PaymailAddressModels.CreatePaymail.ResponseDisplay)
    func displayPaymailPopup(responseDisplay: PaymailAddressModels.InfoPopup.ResponseDisplay)
    func displaySuccessBottomAlert(responseDisplay: PaymailAddressModels.BottomAlert.ResponseDisplay)
}

protocol PaymailAddressDataStore: BaseDataStore, FetchDataStore {
    var screenType: PaymailAddressModels.ScreenType? { get set }
    var paymailAddress: String? { get set }
    var isPaymailFromAssets: Bool { get set }
}

protocol PaymailAddressDataPassing {
    var dataStore: (any PaymailAddressDataStore)? { get }
}

protocol PaymailAddressRoutes: CoordinatableRoutes {
}
