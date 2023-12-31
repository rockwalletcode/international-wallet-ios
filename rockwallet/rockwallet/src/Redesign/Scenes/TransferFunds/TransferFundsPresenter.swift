//
//  TransferFundsPresenter.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 21.9.23.
//
//

import UIKit

final class TransferFundsPresenter: NSObject, Presenter, TransferFundsActionResponses {
   
    typealias Models = TransferFundsModels

    weak var viewController: TransferFundsViewController?

    // MARK: - TransferFundsActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let sections: [AssetModels.Section] = [
            .transferFunds,
            .swapCard
        ]
        
        let transferFundsModel = setupTransferFundsView(isDeposit: true)
        
        let sectionRows: [AssetModels.Section: [any Hashable]] = [
            .transferFunds: [
                transferFundsModel
            ],
            .swapCard: [
                SwapCurrencyViewModel.init(amount: item.amount,
                                           currencyCode: item.amount?.currency.code,
                                           currencyImage: item.amount?.currency.imageSquareBackground,
                                           balanceTitle: L10n.Exchange.rockWalletBalance,
                                           balance: item.balance)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentAmount(actionResponse: AssetModels.Asset.ActionResponse) {
        guard let from = actionResponse.fromAmount else { return }
        
        let fromFiatValue = from.fiatValue == 0 ? nil : ExchangeFormatter.fiat.string(for: from.fiatValue)
        let fromTokenValue = from.tokenValue == 0 ? nil : ExchangeFormatter.current.string(for: from.tokenValue)
        
        let formattedFiatString = ExchangeFormatter.createAmountString(string: fromFiatValue ?? "")
        let formattedTokenString = ExchangeFormatter.createAmountString(string: fromTokenValue ?? "")
        
        let swapCurrencyViewModel = SwapCurrencyViewModel(amount: from,
                                                          formattedFiatString: formattedFiatString,
                                                          formattedTokenString: formattedTokenString,
                                                          balanceTitle: L10n.Exchange.rockWalletBalance,
                                                          balance: actionResponse.balanceValue)
        
        let continueEnabled = actionResponse.isDeposit ? !actionResponse.handleErrors : !handleError(actionResponse: actionResponse)
        
        viewController?.displayAmount(responseDisplay: .init(swapCurrencyViewModel: swapCurrencyViewModel,
                                                             continueEnabled: continueEnabled))
    }
    
    func presentSwitchPlaces(actionResponse: Models.SwitchPlaces.ActionResponse) {
        guard let isDeposit = actionResponse.isDeposit else { return }
        
        let transferFundsModel = setupTransferFundsView(isDeposit: isDeposit)
        viewController?.displaySwitchPlaces(responseDisplay: .init(mainHorizontalViewModel: transferFundsModel))
    }
    
    func presentAssetSelectionMessage(actionResponse: Models.AssetSelectionMessage.ActionResponse) {
        let message = L10n.Swap.enableAssetFirst
        let model = InfoViewModel(description: .text(message), dismissType: .auto)
        let config = Presets.InfoView.warning
        
        viewController?.displayAssetSelectionMessage(responseDisplay: .init(model: model, config: config))
    }
    
    func presentNavigateAssetSelector(actionResponse: Models.AssetSelector.ActionResponse) {
        viewController?.displayNavigateAssetSelector(responseDisplay: .init(title: L10n.Receive.selectAsset,
                                                                            proBalancesData: actionResponse.proBalancesData,
                                                                            isDeposit: actionResponse.isDeposit))
    }
    
    func presentConfirmation(actionResponse: Models.ShowConfirmDialog.ActionResponse) {
        let config: WrapperPopupConfiguration<SwapConfimationConfiguration> = .init(wrappedView: .init())

        guard let from = actionResponse.fromAmount,
              let fromCurrency = actionResponse.fromCurrency,
              let isDeposit = actionResponse.isDeposit,
              let fromFee = actionResponse.fromFee else { return }
        
        let fromTitle = !isDeposit ? "\(L10n.Exchange.sendFrom) \(L10n.About.AppName.android)" : "\(L10n.Exchange.sendFrom) \(L10n.Segment.rockWalletPro)"
        let toTitle = !isDeposit ? L10n.Segment.rockWalletPro : L10n.About.AppName.android
        let feeTitle = !isDeposit ? L10n.Exchange.estimatedNetworkFee : L10n.Exchange.withdrawalFee
        
        let currencyFormat = isDeposit ? "-\(Constant.currencyFormat)" : "\(Constant.currencyFormat)"
        let feeCurrencyCode = !isDeposit && fromCurrency.isERC20Token ? Constant.ETH : fromCurrency.code
        let toFeeText = String(format: currencyFormat,
                               ExchangeFormatter.current.string(for: fromFee.tokenValue.doubleValue) ?? "",
                               feeCurrencyCode)
        
        let fromText = String(format: "\(Constant.currencyFormat) (\(Constant.currencyFormat))",
                              ExchangeFormatter.current.string(for: from.tokenValue.doubleValue) ?? "",
                              from.currency.code,
                              ExchangeFormatter.fiat.string(for: from.fiatValue.doubleValue) ?? "",
                              Constant.usdCurrencyCode)
        let fromValue = String(format: Constant.currencyFormat,
                                   ExchangeFormatter.current.string(for: from.tokenValue) ?? "",
                                   fromCurrency.code)
        
        let totalAmount = isDeposit ? from.tokenValue - fromFee.tokenValue : from.tokenValue
        let totalCostText = String(format: Constant.currencyFormat,
                                   ExchangeFormatter.current.string(for: totalAmount) ?? "",
                                   fromCurrency.code)
        
        let wrappedViewModel: SwapConfirmationViewModel = .init(from: .init(title: .text(fromTitle), value: .text(fromText)),
                                                                to: .init(title: .text(L10n.TransactionDetails.addressToHeader), value: .text(toTitle)),
                                                                rate: .init(title: .text(L10n.Confirmation.amountLabel), value: .text(fromValue)),
                                                                receivingFee: .init(title: .text(feeTitle), value: .text(toFeeText)),
                                                                totalCost: .init(title: .text(L10n.Swap.youReceive), value: .text(totalCostText)))
        
        let viewModel: WrapperPopupViewModel<SwapConfirmationViewModel> = .init(title: .text(L10n.Confirmation.title),
                                                                                confirm: .init(title: L10n.Button.confirm),
                                                                                cancel: .init(title: L10n.Button.cancel),
                                                                                wrappedView: wrappedViewModel)
        
        viewController?.displayConfirmation(responseDisplay: .init(config: config, viewModel: viewModel))
    }
    
    func presentConfirm(actionResponse: Models.Confirm.ActionResponse) {
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(L10n.Transfer.successMessage)),
                                                              config: Presets.InfoView.verification))
        
        viewController?.displayConfirm(responseDisplay: .init())
    }

    // MARK: - Additional Helpers

    func setupTransferFundsView(isDeposit: Bool) -> SwitchFromToHorizontalViewModel? {
        let selfCustodialView: TransferFundsViewModel? = .init(TransferFundsViewModel(headerTitle: isDeposit ?
                                                                                L10n.TransactionDetails.addressFromHeader : L10n.TransactionDetails.addressToHeader,
                                                                                 icon: .image(Asset.iconSelfCustodial.image),
                                                                                 title: L10n.About.AppName.android,
                                                                                      subTitle: "(\(L10n.Exchange.selfCustodial))"))
        
        let custodialView: TransferFundsViewModel? = .init(TransferFundsViewModel(headerTitle: !isDeposit ?
                                                                                 L10n.TransactionDetails.addressFromHeader : L10n.TransactionDetails.addressToHeader,
                                                                                 icon: .image(Asset.iconCustodial.image),
                                                                                 title: L10n.Segment.rockWalletPro,
                                                                                 subTitle: "(\(L10n.Exchange.custodial))"))
        let transferFundsModel: SwitchFromToHorizontalViewModel? = isDeposit ?
        SwitchFromToHorizontalViewModel(fromTransferView: selfCustodialView, toTransferView: custodialView) :
        SwitchFromToHorizontalViewModel(fromTransferView: custodialView, toTransferView: selfCustodialView)
        
        return transferFundsModel
    }
}
