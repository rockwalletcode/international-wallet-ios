//
//  BuyPresenter.swift
//  breadwallet
//
//  Created by Rok on 01/08/2022.
//
//

import UIKit

final class BuyPresenter: NSObject, Presenter, BuyActionResponses {
    typealias Models = BuyModels
    
    weak var viewController: BuyViewController?
    
    var achPaymentModel: CardSelectionViewModel?
    private var exchangeRateViewModel: ExchangeRateViewModel = .init()
    
    // MARK: - BuyActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? AssetModels.Item else { return }
        
        var sections: [AssetModels.Section] = [
            .rateAndTimer,
            .swapCard,
            .paymentMethod,
            .accountLimits,
            .increaseLimits
        ]
        
        if item.achEnabled == true {
            sections.insert(.segment, at: 0)
        }
        
        exchangeRateViewModel = ExchangeRateViewModel(timer: TimerViewModel(), showTimer: false)
        
        let selectedPaymentType = PaymentCard.PaymentType.allCases.firstIndex(where: { $0 == item.type })
        
        let paymentSegment = SegmentControlViewModel(selectedIndex: selectedPaymentType,
                                                     segments: [.init(image: nil, title: L10n.Buy.buyWithCard),
                                                                .init(image: nil, title: L10n.Buy.buyWithAch)])
        let limitsString = NSMutableAttributedString(string: L10n.Buy.increaseYourLimits)
        limitsString.addAttribute(.underlineStyle, value: 1, range: NSRange.init(location: 0, length: limitsString.length))
        
        let paymentMethodViewModel: CardSelectionViewModel
        if item.type == .ach && item.achEnabled == true {
            paymentMethodViewModel = CardSelectionViewModel(title: .text(L10n.Buy.achPayments),
                                                            subtitle: .text(L10n.Buy.linkBankAccount),
                                                            userInteractionEnabled: true)
        } else {
            paymentMethodViewModel = CardSelectionViewModel()
        }
        
        let sectionRows: [AssetModels.Section: [any Hashable]] =  [
            .segment: [paymentSegment],
            .rateAndTimer: [exchangeRateViewModel],
            .swapCard: [SwapCurrencyViewModel(title: .text(L10n.Swap.iWant))],
            .paymentMethod: [paymentMethodViewModel],
            .accountLimits: [
                LabelViewModel.text("")
            ],
            .increaseLimits: [LabelViewModel.attributedText(limitsString)]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentAmount(actionResponse: AssetModels.Asset.ActionResponse) {
        guard let from = actionResponse.fromAmount else { return }
        
        var cryptoModel: SwapCurrencyViewModel
        let cardModel: CardSelectionViewModel
        
        let fromFiatValue = from.fiatValue == 0 ? nil : ExchangeFormatter.fiat.string(for: from.fiatValue)
        let fromTokenValue = from.tokenValue == 0 ? nil : ExchangeFormatter.current.string(for: from.tokenValue)
        
        let formattedFiatString = ExchangeFormatter.createAmountString(string: fromFiatValue ?? "")
        let formattedTokenString = ExchangeFormatter.createAmountString(string: fromTokenValue ?? "")
        
        let fiatCurrency = (actionResponse.quote?.fromFee?.currency ?? Constant.usdCurrencyCode).uppercased()
        let instantAchLimit = actionResponse.quote?.instantAch?.limitUsd ?? 0
        let instantAchLimitAmount = String(format: Constant.currencyFormat,
                                           ExchangeFormatter.fiat.string(for: instantAchLimit) ?? "",
                                           fiatCurrency)
        let instantAchLimitText = L10n.Buy.Ach.Instant.infoButtonTitle(instantAchLimitAmount)
        
        cryptoModel = .init(amount: from,
                            headerInfoButtonTitle: actionResponse.type == .ach ? instantAchLimitText : nil,
                            formattedFiatString: formattedFiatString,
                            formattedTokenString: formattedTokenString,
                            title: .text(L10n.Swap.iWant))
        
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
        
        viewController?.displayAmount(responseDisplay: .init(swapCurrencyViewModel: cryptoModel,
                                                             cardModel: cardModel))
        
        guard actionResponse.handleErrors else { return }
        _ = handleError(actionResponse: actionResponse)
    }
    
    func presentOrderPreview(actionResponse: BuyModels.OrderPreview.ActionResponse) {
        viewController?.displayOrderPreview(responseDisplay: .init(availablePayments: actionResponse.availablePayments))
    }
    
    func presentNavigateAssetSelector(actionResponse: BuyModels.AssetSelector.ActionResponse) {
        viewController?.displayNavigateAssetSelector(responseDisplay: .init(title: L10n.Swap.iWant))
    }
    
    func presentAchSuccess(actionResponse: BuyModels.AchSuccess.ActionResponse) {
        guard let isRelinking = actionResponse.isRelinking else { return }
        
        let description = isRelinking ? L10n.Buy.achPaymentMethodRelinked : L10n.Buy.achSuccess
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(description)),
                                                              config: Presets.InfoView.verification))
    }
    
    func presentMessage(actionResponse: BuyModels.RetryPaymentMethod.ActionResponse) {
        let message = actionResponse.method == .card ? L10n.Buy.switchedToDebitCard : L10n.Buy.switchedToAch
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(message)),
                                                              config: Presets.InfoView.verification))
    }
    
    func presentLimitsInfo(actionResponse: BuyModels.LimitsInfo.ActionResponse) {
        let title = actionResponse.paymentMethod == .card ? L10n.Buy.yourBuyLimits : L10n.Buy.yourAchBuyLimits
        let profile = UserManager.shared.profile
        
        let perTransactionLimit = actionResponse.paymentMethod == .card ? profile?.buyAllowancePerExchange : profile?.achAllowancePerExchange
        let dailyMaxLimit = actionResponse.paymentMethod == .card ? profile?.buyAllowanceDailyMax : profile?.achAllowanceDailyMax
        let weeklyLimit = actionResponse.paymentMethod == .card ? profile?.buyAllowanceWeekly : profile?.achAllowanceWeekly
        let monthlyLimit = actionResponse.paymentMethod == .card ? profile?.buyAllowanceMonthly : profile?.achAllowanceMonthly
        
        let perTransactionLimitText = ExchangeFormatter.current.string(for: perTransactionLimit) ?? ""
        let dailyMaxLimitText = ExchangeFormatter.current.string(for: dailyMaxLimit) ?? ""
        let weeklyLimitText = ExchangeFormatter.current.string(for: weeklyLimit) ?? ""
        let monthlyLimitText = ExchangeFormatter.current.string(for: monthlyLimit) ?? ""
        
        let config: WrapperPopupConfiguration<LimitsPopupConfiguration> = .init(wrappedView: .init())
        let wrappedViewModel: LimitsPopupViewModel = .init(title: .text(title),
                                                           perTransaction: .init(title: .text(L10n.Buy.perTransactionLimit),
                                                                                 value: .text("$\(perTransactionLimitText) \(Constant.usdCurrencyCode)")),
                                                           dailyMax: .init(title: .text(L10n.Buy.dailyMaxLimits),
                                                                           value: .text("$\(dailyMaxLimitText) \(Constant.usdCurrencyCode)")),
                                                           weekly: .init(title: .text(L10n.Account.weekly),
                                                                         value: .text("$\(weeklyLimitText) \(Constant.usdCurrencyCode)")),
                                                           monthly: .init(title: .text(L10n.Account.monthly),
                                                                          value: .text("$\(monthlyLimitText) \(Constant.usdCurrencyCode)")))
        
        let viewModel: WrapperPopupViewModel<LimitsPopupViewModel> = .init(trailing: .init(image: Asset.close.image),
                                                                           wrappedView: wrappedViewModel,
                                                                           hideSeparator: true)
        
        viewController?.displayLimitsInfo(responseDisplay: .init(config: config, viewModel: viewModel))
    }
    
    func presentInstantAchPopup(actionResponse: BuyModels.InstantAchPopup.ActionResponse) {
        let model = PopupViewModel(title: .text(L10n.Buy.Ach.Instant.popupTitle),
                                   body: L10n.Buy.Ach.Instant.popupContent)
        
        viewController?.displayInstantAchPopup(responseDisplay: .init(model: model))
    }
    
    func presentAssetSelectionMessage(actionResponse: BuyModels.AssetSelectionMessage.ActionResponse) {
        let message = L10n.Swap.enableAssetFirst
        let model = InfoViewModel(description: .text(message), dismissType: .auto)
        let config = Presets.InfoView.warning
        
        viewController?.displayAssetSelectionMessage(responseDisplay: .init(model: model, config: config))
    }
    
    // MARK: - Additional Helpers
    
}
