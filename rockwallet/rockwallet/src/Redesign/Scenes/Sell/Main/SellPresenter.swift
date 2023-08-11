//
//  SellPresenter.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit

final class SellPresenter: NSObject, Presenter, SellActionResponses {
    
    typealias Models = SellModels
    
    weak var viewController: SellViewController?
    
    var achPaymentModel: CardSelectionViewModel? = CardSelectionViewModel()
    private var exchangeRateViewModel: ExchangeRateViewModel = .init()
    
    // MARK: - SellActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let sections: [AssetModels.Section] = [
            .rateAndTimer,
            .swapCard,
            .paymentMethod,
            .accountLimits,
            .limitActions
        ]
        
        exchangeRateViewModel = ExchangeRateViewModel(timer: TimerViewModel(), showTimer: false)
        
        let sectionRows: [AssetModels.Section: [any Hashable]] = [
            .rateAndTimer: [
                exchangeRateViewModel
            ],
            .swapCard: [
                MainSwapViewModel(from: .init(selectionDisabled: false),
                                  to: .init(selectionDisabled: true))
            ],
            .paymentMethod: [
                achPaymentModel
            ],
            .accountLimits: [
                LabelViewModel.text("")
            ],
            .limitActions: [
                MultipleButtonsViewModel(buttons: [])
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentAmount(actionResponse: AssetModels.Asset.ActionResponse) {
        guard let from = actionResponse.fromAmount else { return }
        
        var cryptoModel: MainSwapViewModel
        let cardModel: CardSelectionViewModel
        
        let balance = from.currency.state?.balance
        let balanceText = String(format: L10n.Swap.balance(ExchangeFormatter.current.string(for: balance?.tokenValue.doubleValue) ?? "", balance?.currency.code ?? ""))
        
        let fromTokenValue = from.tokenValue == 0 ? nil : ExchangeFormatter.current.string(for: from.tokenValue)
        let toFiatValue = from.fiatValue == 0 ? nil : ExchangeFormatter.fiat.string(for: from.fiatValue)
        
        let fromFormattedTokenString = ExchangeFormatter.createAmountString(string: fromTokenValue ?? "")
        let toFormattedFiatString = ExchangeFormatter.createAmountString(string: toFiatValue ?? "")
        
        cryptoModel = MainSwapViewModel(from: .init(amount: from,
                                                    formattedTokenString: fromFormattedTokenString,
                                                    title: .text(balanceText),
                                                    selectionDisabled: false),
                                        
                                        to: .init(currencyCode: Constant.usdCurrencyCode,
                                                  currencyImage: Asset.us.image,
                                                  formattedTokenString: toFormattedFiatString,
                                                  title: .text(L10n.Sell.iReceive),
                                                  selectionDisabled: true))
        
        switch actionResponse.type {
        case .ach:
            if let paymentCard = actionResponse.card {
                switch actionResponse.card?.status {
                case .statusOk:
                    cardModel = .init(title: .text(L10n.Buy.transferFromBank),
                                      subtitle: nil,
                                      logo: .image(Asset.bank.image),
                                      cardNumber: .text(paymentCard.displayName),
                                      userInteractionEnabled: false)
                    
                default:
                    cardModel = .init(title: .text(L10n.Buy.achPayments),
                                      subtitle: .text(L10n.Buy.relinkBankAccount),
                                      userInteractionEnabled: true)
                    
                    let model = InfoViewModel(description: .text(L10n.Buy.Ach.accountUnlinked),
                                              dismissType: .auto)
                    let config = Presets.InfoView.error
                    
                    viewController?.displayMessage(responseDisplay: .init(model: model,
                                                                          config: config))
                }
            } else {
                cardModel = CardSelectionViewModel(title: .text(L10n.Buy.achPayments),
                                                   subtitle: .text(L10n.Buy.linkBankAccount),
                                                   userInteractionEnabled: true)
            }
            
        default:
            if let paymentCard = actionResponse.card {
                cardModel = .init(logo: paymentCard.displayImage,
                                  cardNumber: .text(paymentCard.displayName),
                                  expiration: .text(CardDetailsFormatter.formatExpirationDate(month: paymentCard.expiryMonth, year: paymentCard.expiryYear)),
                                  userInteractionEnabled: true)
            } else {
                cardModel = .init(userInteractionEnabled: true)
            }
        }
        
        viewController?.displayAmount(responseDisplay: .init(mainSwapViewModel: cryptoModel,
                                                             cardModel: cardModel,
                                                             limitActions: .init(buttons: setupLimitsButtons(type: actionResponse.type))))
        
        guard actionResponse.handleErrors else { return }
        _ = handleError(actionResponse: actionResponse)
    }
    
    func presentOrderPreview(actionResponse: SellModels.OrderPreview.ActionResponse) {
        viewController?.displayOrderPreview(responseDisplay: .init(availablePayments: actionResponse.availablePayments))
    }
    
    func presentNavigateAssetSelector(actionResponse: SellModels.AssetSelector.ActionResponse) {
        viewController?.displayNavigateAssetSelector(responseDisplay: .init(title: L10n.Swap.iWant))
    }
    
    func presentAchSuccess(actionResponse: SellModels.AchSuccess.ActionResponse) {
        guard let isRelinking = actionResponse.isRelinking else { return }
        
        let description = isRelinking ? L10n.Buy.achPaymentMethodRelinked : L10n.Buy.achSuccess
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(description)),
                                                              config: Presets.InfoView.verification))
    }
    
    func presentLimitsInfo(actionResponse: SellModels.LimitsInfo.ActionResponse) {
        let title = actionResponse.paymentMethod == .card ? L10n.Buy.yourBuyLimits : L10n.Buy.yourAchBuyLimits
        let profile = UserManager.shared.profile
        
        let perTransactionLimit = actionResponse.paymentMethod == .card ? profile?.buyAllowancePerExchange : profile?.achAllowancePerExchange
        let weeklyLimit = actionResponse.paymentMethod == .card ? profile?.buyAllowanceWeekly : profile?.achAllowanceWeekly
        let monthlyLimit = actionResponse.paymentMethod == .card ? profile?.buyAllowanceMonthly : profile?.achAllowanceMonthly
        
        let perTransactionLimitText = ExchangeFormatter.current.string(for: perTransactionLimit) ?? ""
        let weeklyLimitText = ExchangeFormatter.current.string(for: weeklyLimit) ?? ""
        let monthlyLimitText = ExchangeFormatter.current.string(for: monthlyLimit) ?? ""
        
        let config: WrapperPopupConfiguration<LimitsPopupConfiguration> = .init(wrappedView: .init())
        let wrappedViewModel: LimitsPopupViewModel = .init(title: .text(title),
                                                           perTransaction: .init(title: .text(L10n.Buy.perTransactionLimit),
                                                                                 value: .text("\(perTransactionLimitText) \(Constant.usdCurrencyCode)")),
                                                           weekly: .init(title: .text(L10n.Account.weekly),
                                                                         value: .text("\(weeklyLimitText) \(Constant.usdCurrencyCode)")),
                                                           monthly: .init(title: .text(L10n.Account.monthly),
                                                                          value: .text("\(monthlyLimitText) \(Constant.usdCurrencyCode)")))
        
        let viewModel: WrapperPopupViewModel<LimitsPopupViewModel> = .init(trailing: .init(image: Asset.close.image),
                                                                           wrappedView: wrappedViewModel,
                                                                           hideSeparator: true)
        
        viewController?.displayLimitsInfo(responseDisplay: .init(config: config, viewModel: viewModel))
    }
    
    func presentInstantAchPopup(actionResponse: SellModels.InstantAchPopup.ActionResponse) {
        let model = PopupViewModel(title: .text(L10n.Buy.Ach.Instant.popupTitle),
                                   body: L10n.Buy.Ach.Instant.popupContent)
        
        viewController?.displayInstantAchPopup(responseDisplay: .init(model: model))
    }
    
    func presentAssetSelectionMessage(actionResponse: SellModels.AssetSelectionMessage.ActionResponse) {
        let message = L10n.Swap.enableAssetFirst
        let model = InfoViewModel(description: .text(message), dismissType: .auto)
        let config = Presets.InfoView.warning
        
        viewController?.displayAssetSelectionMessage(responseDisplay: .init(model: model, config: config))
    }
    
    // MARK: - Additional Helpers
    
    private func isCustomLimits(for paymentMethod: PaymentCard.PaymentType?) -> Bool {
        guard let userLimits = UserManager.shared.profile?.limits else { return false }
        let limits = userLimits.filter { ($0.interval == .daily || $0.interval == .weekly || $0.interval == .monthly) && $0.isCustom == true }
        
        switch paymentMethod {
        case .ach:
            return !limits.filter({ $0.exchangeType == .sell }).isEmpty
            
        default:
            return false
        }
    }
    
    private func setupLimitsButtons(type: PaymentCard.PaymentType?) -> [ButtonViewModel] {
        var buttons = [ButtonViewModel]()
        
        if isCustomLimits(for: type) == true {
            var button = ButtonViewModel(title: L10n.Button.moreLimits,
                                         isUnderlined: true)
            button.callback = { [weak self] in
                self?.viewController?.limitsInfoTapped()
            }
            
            buttons.append(button)
        }
        
        return buttons
    }
}
