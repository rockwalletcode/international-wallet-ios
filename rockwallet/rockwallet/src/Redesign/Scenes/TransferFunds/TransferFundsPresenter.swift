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
        
        let transferFundsModel = TransferFundsHorizontalViewModel(fromTransferView: .init(TransferFundsViewModel(headerTitle: L10n.TransactionDetails.addressFromHeader,
                                                                                                                 icon: .image(Asset.iconCustodial.image),
                                                                                                                 title: "\(L10n.About.AppName.android) PRO",
                                                                                                                 subTitle: "(custodial)")),
                                                                  toTransferView: .init(TransferFundsViewModel(headerTitle: L10n.TransactionDetails.addressToHeader,
                                                                                                               icon: .image(Asset.iconSelfCustodial.image),
                                                                                                               title: L10n.About.AppName.android,
                                                                                                               subTitle: "(self-custodial)")))
        
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
        
        let wrappedViewModel: SwapConfirmationViewModel = .init(from: .init(title: .text("Send from RockWallet PRO"), value: .text("40.85 BSV")),
                                                                to: .init(title: .text(L10n.TransactionDetails.addressToHeader), value: .text("RockWallet")),
                                                                rate: .init(title: .text("Amount to send"), value: .text("40.85 BSV")),
                                                                receivingFee: .init(title: .text("Withdrawal fee"), value: .text("-0.0001 BSV")),
                                                                totalCost: .init(title: .text(L10n.Swap.youReceive), value: .text("40.8499 BSV")))
        
        let viewModel: WrapperPopupViewModel<SwapConfirmationViewModel> = .init(title: .text(L10n.Confirmation.title),
                                                                                confirm: .init(title: L10n.Button.confirm),
                                                                                cancel: .init(title: L10n.Button.cancel),
                                                                                wrappedView: wrappedViewModel)
        
        viewController?.displayConfirmation(responseDisplay: .init(config: config, viewModel: viewModel))
    }

    // MARK: - Additional Helpers

}
