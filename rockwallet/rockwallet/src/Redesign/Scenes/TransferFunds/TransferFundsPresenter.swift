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
    
    private var mainSwapViewModel = MainSwapViewModel()
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else {
            viewController?.displayError(responseDisplay: .init())
            return
        }
        
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
                SwapCurrencyViewModel.init(amount: item,
                                           currencyCode: item?.currency.code,
                                           currencyImage: item?.currency.imageSquareBackground)
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
        
        mainSwapViewModel = MainSwapViewModel(from: .init(amount: from,
                                                          formattedFiatString: formattedFiatString,
                                                          formattedTokenString: formattedTokenString))
        
        let continueEnabled = !handleError(actionResponse: actionResponse) && actionResponse.handleErrors
        
        viewController?.displayAmount(responseDisplay: .init(mainSwapViewModel: mainSwapViewModel,
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
        viewController?.displayNavigateAssetSelector(responseDisplay: .init(title: L10n.Receive.selectAsset))
    }
    
    func presentConfirmation(actionResponse: Models.ShowConfirmDialog.ActionResponse) {
        let config: WrapperPopupConfiguration<SwapConfimationConfiguration> = .init(wrappedView: .init())
        
        guard let isDeposit = actionResponse.isDeposit else { return }
        let fromTitle = !isDeposit ? "Send from RockWallet" : "Send from RockWallet PRO"
        let toTitle = !isDeposit ? L10n.Segment.rockWalletPro : L10n.About.AppName.android
        let feeTitle = !isDeposit ? "Estimated Network fee" : "Withdrawal fee"
        
        let wrappedViewModel: SwapConfirmationViewModel = .init(from: .init(title: .text(fromTitle), value: .text("40.85 USDC")),
                                                                to: .init(title: .text(L10n.TransactionDetails.addressToHeader), value: .text(toTitle)),
                                                                rate: .init(title: .text(L10n.Confirmation.amountLabel), value: .text("40.85 USDC")),
                                                                receivingFee: .init(title: .text(feeTitle), value: .text("-0.0001 USDC")),
                                                                totalCost: .init(title: .text(L10n.Swap.youReceive), value: .text("40.8499 USDC")))
        
        let viewModel: WrapperPopupViewModel<SwapConfirmationViewModel> = .init(title: .text(L10n.Confirmation.title),
                                                                                confirm: .init(title: L10n.Button.confirm),
                                                                                cancel: .init(title: L10n.Button.cancel),
                                                                                wrappedView: wrappedViewModel)
        
        viewController?.displayConfirmation(responseDisplay: .init(config: config, viewModel: viewModel))
    }
    
    func presentConfirmTransfer(actionResponse: Models.ConfirmTransfer.ActionResponse) {
        let popupViewModel = PopupViewModel(title: .text(""),
                                            body: "Your Funds were successfully sent to your RockWallet PRO account and will appear when confirmed on the Blockchain. Please swipe down to refresh.",
                                            buttons: [.init(title: L10n.Button.finish)],
                                            closeButton: .init(image: Asset.close.image))
        
        viewController?.displayConfirmTransfer(responseDisplay: .init(popupViewModel: popupViewModel,
                                                                    popupConfig: Presets.Popup.whiteCentered))
    }
    
    func presentConfirm(actionResponse: Models.Confirm.ActionResponse) {
        guard let from = actionResponse.from,
              let to = actionResponse.to,
              let exchangeId = actionResponse.exchangeId else {
            presentError(actionResponse: .init(error: GeneralError(errorMessage: L10n.Swap.notValidPair)))
            return
        }
        viewController?.displayConfirm(responseDisplay: .init(from: from, to: to, exchangeId: "\(exchangeId)"))
    }

    // MARK: - Additional Helpers

    func setupTransferFundsView(isDeposit: Bool) -> TransferFundsHorizontalViewModel? {
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
        let transferFundsModel: TransferFundsHorizontalViewModel? = isDeposit ?
        TransferFundsHorizontalViewModel(fromTransferView: selfCustodialView, toTransferView: custodialView) :
        TransferFundsHorizontalViewModel(fromTransferView: custodialView, toTransferView: selfCustodialView)
        
        return transferFundsModel
    }
}
