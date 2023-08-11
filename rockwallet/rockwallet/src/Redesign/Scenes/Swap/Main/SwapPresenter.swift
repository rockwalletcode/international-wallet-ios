//
//  SwapPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class SwapPresenter: NSObject, Presenter, SwapActionResponses {
    
    typealias Models = SwapModels
    
    weak var viewController: SwapViewController?
    
    // MARK: - SwapActionResponses
    
    private var exchangeRateViewModel = ExchangeRateViewModel(timer: TimerViewModel())
    private var mainSwapViewModel = MainSwapViewModel()
    var isMinimumImpactedByWithdrawalShown = false
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item,
              let fromAmount = item.fromAmount?.currency,
              let toAmount = item.toAmount?.currency else {
            viewController?.displayError(responseDisplay: .init())
            return
        }
        
        let sections: [AssetModels.Section] = [
            .rateAndTimer,
            .swapCard,
            .accountLimits
        ]
        
        exchangeRateViewModel = .init(timer: TimerViewModel())
        mainSwapViewModel = .init(from: .init(amount: .zero(fromAmount),
                                              fee: .zero(fromAmount),
                                              formattedTokenFeeString: nil,
                                              title: .text(String(format: L10n.Swap.balance(ExchangeFormatter.current.string(for: 0) ?? "", fromAmount.code)))),
                                  to: .init(amount: .zero(toAmount),
                                            fee: .zero(toAmount),
                                            formattedTokenFeeString: nil,
                                            title: .text(L10n.Buy.iWant)))
        
        let sectionRows: [AssetModels.Section: [any Hashable]] = [
            .rateAndTimer: [
                exchangeRateViewModel
            ],
            .accountLimits: [
                LabelViewModel.text("")
            ],
            .swapCard: [
                mainSwapViewModel
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentAmount(actionResponse: AssetModels.Asset.ActionResponse) {
        guard let from = actionResponse.fromAmount,
              let to = actionResponse.toAmount else { return }
        
        let balance = from.currency.state?.balance
        let balanceText = String(format: L10n.Swap.balance(ExchangeFormatter.current.string(for: balance?.tokenValue.doubleValue) ?? "", balance?.currency.code ?? ""))
        let receivingFee = L10n.Swap.receiveNetworkFee
        
        let fromFiatValue = from.fiatValue == 0 ? nil : ExchangeFormatter.fiat.string(for: from.fiatValue)
        let fromTokenValue = from.tokenValue == 0 ? nil : ExchangeFormatter.current.string(for: from.tokenValue)
        let toTokenValue = to.tokenValue == 0 ? nil : ExchangeFormatter.current.string(for: to.tokenValue)
        
        let fromFormattedFiatString = ExchangeFormatter.createAmountString(string: fromFiatValue ?? "")
        let fromFormattedTokenString = ExchangeFormatter.createAmountString(string: fromTokenValue ?? "")
        let toFormattedTokenString = ExchangeFormatter.createAmountString(string: toTokenValue ?? "")
        
        let toFee = actionResponse.toFee
        let formattedToTokenFeeString = String(format: "-%@ %@",
                                               ExchangeFormatter.current.string(for: toFee?.tokenValue) ?? "",
                                               toFee?.currency.code.uppercased() ?? "")
        
        mainSwapViewModel = MainSwapViewModel(from: .init(amount: from,
                                                          formattedFiatString: fromFormattedFiatString,
                                                          formattedTokenString: fromFormattedTokenString,
                                                          title: .text(balanceText)),
                                              to: .init(amount: to,
                                                        formattedTokenString: toFormattedTokenString,
                                                        fee: actionResponse.toFee,
                                                        formattedTokenFeeString: formattedToTokenFeeString,
                                                        title: .text(L10n.Buy.iWant),
                                                        feeDescription: .text(receivingFee)))
        
        let continueEnabled = !handleError(actionResponse: actionResponse) && actionResponse.handleErrors
        
        viewController?.displayAmount(responseDisplay: .init(mainSwapViewModel: mainSwapViewModel,
                                                             continueEnabled: continueEnabled,
                                                             rate: exchangeRateViewModel))
    }
    
    func presentSelectAsset(actionResponse: SwapModels.Assets.ActionResponse) {
        let title = actionResponse.from == nil ? L10n.Swap.youReceive : L10n.Swap.youSend
        
        viewController?.displaySelectAsset(responseDisplay: .init(title: title, from: actionResponse.from, to: actionResponse.to))
    }
    
    func presentConfirmation(actionResponse: SwapModels.ShowConfirmDialog.ActionResponse) {
        guard let from = actionResponse.fromAmount,
              let to = actionResponse.toAmount,
              let rate = actionResponse.quote?.exchangeRate.doubleValue else {
            return
        }
        
        let currencyFormat = Constant.currencyFormat
        
        let rateText = String(format: "1 %@ = \(currencyFormat)",
                              from.currency.code,
                              ExchangeNumberFormatter().string(for: rate) ?? "",
                              to.currency.code)
        
        let fromText = String(format: "\(Constant.currencyFormat) (\(Constant.currencyFormat))",
                              ExchangeFormatter.current.string(for: from.tokenValue.doubleValue) ?? "",
                              from.currency.code,
                              ExchangeFormatter.fiat.string(for: from.fiatValue.doubleValue) ?? "",
                              Constant.usdCurrencyCode)
        let toText = String(format: currencyFormat,
                            ExchangeFormatter.current.string(for: to.tokenValue.doubleValue) ?? "",
                            to.currency.code)
        
        let toFeeText = String(format: "-\(currencyFormat)",
                               ExchangeFormatter.current.string(for: actionResponse.toFee?.tokenValue.doubleValue) ?? "",
                               actionResponse.toFee?.currency.code ?? to.currency.code)
        
        let totalCostText = String(format: currencyFormat,
                                   ExchangeFormatter.current.string(for: to.tokenValue.doubleValue) ?? "",
                                   to.currency.code)
        
        let config: WrapperPopupConfiguration<SwapConfimationConfiguration> = .init(wrappedView: .init())
        
        let wrappedViewModel: SwapConfirmationViewModel = .init(from: .init(title: .text(L10n.TransactionDetails.addressFromHeader), value: .text(fromText)),
                                                                to: .init(title: .text(L10n.TransactionDetails.addressToHeader), value: .text(toText)),
                                                                rate: .init(title: .text(L10n.Swap.rateValue), value: .text(rateText)),
                                                                receivingFee: .init(title: .text(L10n.Swap.receiveNetworkFee), value: .text(toFeeText)),
                                                                totalCost: .init(title: .text(L10n.Swap.youReceive), value: .text(totalCostText)))
        
        let viewModel: WrapperPopupViewModel<SwapConfirmationViewModel> = .init(title: .text(L10n.Confirmation.title),
                                                                                confirm: .init(title: L10n.Button.confirm),
                                                                                cancel: .init(title: L10n.Button.cancel),
                                                                                wrappedView: wrappedViewModel)
        
        viewController?.displayConfirmation(responseDisplay: .init(config: config, viewModel: viewModel))
    }
    
    func presentConfirm(actionResponse: SwapModels.Confirm.ActionResponse) {
        guard let from = actionResponse.from,
              let to = actionResponse.to,
              let exchangeId = actionResponse.exchangeId else {
            presentError(actionResponse: .init(error: GeneralError(errorMessage: L10n.Swap.notValidPair)))
            return
        }
        viewController?.displayConfirm(responseDisplay: .init(from: from, to: to, exchangeId: "\(exchangeId)"))
    }
    
    func presentAssetInfoPopup(actionResponse: SwapModels.AssetInfoPopup.ActionResponse) {
        let popupViewModel = PopupViewModel(title: .text(L10n.Swap.checkAssets),
                                            body: L10n.Swap.checkAssetsBody,
                                            buttons: [.init(title: L10n.Swap.gotItButton)])
        
        viewController?.displayAssetInfoPopup(responseDisplay: .init(popupViewModel: popupViewModel,
                                                                     popupConfig: Presets.Popup.white))
    }
    
    func presentAssetSelectionMessage(actionResponse: SwapModels.AssetSelectionMessage.ActionResponse) {
        let message: String
        if actionResponse.from?.code == actionResponse.selectedDisabledAsset?.subtitle || actionResponse.to?.code == actionResponse.selectedDisabledAsset?.subtitle {
            message = L10n.Swap.sameAssetMessage
        } else {
            message = L10n.Swap.enableAssetFirst
        }
        
        let model = InfoViewModel(description: .text(message), dismissType: .auto)
        let config = Presets.InfoView.warning
        
        viewController?.displayAssetSelectionMessage(responseDisplay: .init(model: model, config: config))
    }
    
    // MARK: - Additional Helpers
    
}
