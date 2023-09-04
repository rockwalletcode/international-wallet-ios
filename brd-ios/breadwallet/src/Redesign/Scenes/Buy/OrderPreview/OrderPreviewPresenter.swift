//
//  OrderPreviewPresenter.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.8.22.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WalletKit

final class OrderPreviewPresenter: NSObject, Presenter, OrderPreviewActionResponses {
    
    typealias Models = OrderPreviewModels
    
    weak var viewController: OrderPreviewViewController?
    
    // MARK: - OrderPreviewActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item,
              let card = item.card,
              let isAchAccount = item.isAchAccount else { return }
        
        let wrappedViewModel = prepareOrderPreviewViewModel(for: item)
        
        let achTermsModel = InfoViewModel(description: .text(L10n.Buy.Terms.description),
                                          button: .init(title: L10n.About.terms, isUnderlined: true),
                                          tickbox: .init(title: .text(L10n.Buy.understandAndAgree)),
                                          dismissType: .persistent)
        
        let termsText = NSMutableAttributedString(string: L10n.Buy.Terms.description + " ")
        termsText.addAttribute(NSAttributedString.Key.font,
                               value: Fonts.Body.three,
                               range: NSRange(location: 0, length: termsText.length))
        termsText.addAttribute(NSAttributedString.Key.foregroundColor,
                               value: LightColors.Text.two,
                               range: NSRange(location: 0, length: termsText.length))
        
        let interactableText = NSMutableAttributedString(string: L10n.About.terms)
        interactableText.addAttribute(NSAttributedString.Key.font,
                                      value: Fonts.Body.three,
                                      range: NSRange(location: 0, length: interactableText.length))
        let linkAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: LightColors.primary,
            NSAttributedString.Key.underlineColor: LightColors.primary,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        interactableText.addAttributes(linkAttributes, range: NSRange(location: 0, length: interactableText.length))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        termsText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: termsText.length))
        
        termsText.append(interactableText)
        
        var sections: [Models.Section] = [
            .orderInfoCard,
            .payment,
            .termsAndConditions,
            .submit
        ]
        
        switch (isAchAccount, item.type) {
        case (true, .sell):
            sections.insert(.disclaimer, at: 0)
            
        case (true, .buy):
            sections.insert(.achSegment, at: 0)
            
        default:
            break
        }
        
        let selectedSegment = Models.AchDeliveryType.allCases.firstIndex(where: { $0.hashValue == item.achDeliveryType?.hashValue })
        let achSegment = SegmentControlViewModel(selectedIndex: selectedSegment,
                                                 segments: [.init(image: Asset.flash.image, title: L10n.Buy.Ach.Instant.title),
                                                            .init(image: Asset.timelapse.image, title: L10n.Buy.Ach.Hybrid.title)])
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .disclaimer: [InfoViewModel(description: .text(item.type?.disclaimer))],
            .achSegment: [achSegment],
            .orderInfoCard: [wrappedViewModel],
            .payment: [PaymentMethodViewModel(methodTitle: .text(L10n.Buy.paymentMethod),
                                              logo: card.displayImage,
                                              type: card.type,
                                              previewFor: item.type,
                                              cardNumber: .text(card.displayName),
                                              expiration: .text(CardDetailsFormatter.formatExpirationDate(month: card.expiryMonth, year: card.expiryYear)))],
            .termsAndConditions: [isAchAccount || item.type == .sell ? achTermsModel : LabelViewModel.attributedText(termsText)],
            .submit: [ButtonViewModel(title: L10n.Button.confirm, enabled: false)]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentInfoPopup(actionResponse: OrderPreviewModels.InfoPopup.ActionResponse) {
        let model: PopupViewModel
        
        if actionResponse.isCardFee {
            let feeText = L10n.Buy.cardFee
            model = .init(title: .text(L10n.Swap.cardFee), body: feeText)
        } else {
            model = .init(title: .text(L10n.Buy.networkFees),
                          body: L10n.Buy.networkFeeMessage)
        }
        
        viewController?.displayInfoPopup(responseDisplay: .init(model: model))
    }
    
    func presentThreeDSecure(actionResponse: OrderPreviewModels.ThreeDSecure.ActionResponse) {
        viewController?.displayThreeDSecure(responseDisplay: .init(url: actionResponse.url))
    }
    
    func presentVeriffLivenessCheck(actionResponse: OrderPreviewModels.VeriffLivenessCheck.ActionResponse) {
        viewController?.displayVeriffLivenessCheck(responseDisplay: .init(quoteId: actionResponse.quoteId, isBiometric: actionResponse.isBiometric))
    }
    
    func presentBiometricStatusFailed(actionResponse: OrderPreviewModels.BiometricStatusFailed.ActionResponse) {
        viewController?.displayBiometricStatusFailed(responseDisplay: .init(reason: actionResponse.reason))
    }
    
    func presentCvv(actionResponse: OrderPreviewModels.CvvValidation.ActionResponse) {
        viewController?.displayContinueEnabled(responseDisplay: .init(continueEnabled: actionResponse.isValid))
    }
    
    func presentCvvInfoPopup(actionResponse: OrderPreviewModels.CvvInfoPopup.ActionResponse) {
        let model = PopupViewModel(title: .text(L10n.Buy.securityCode),
                                   imageName: Asset.cards.name,
                                   body: L10n.Buy.securityCodePopup)
        
        viewController?.displayCvvInfoPopup(responseDisplay: .init(model: model))
    }
    
    func presentTimeOut(actionResponse: OrderPreviewModels.ExpirationValidations.ActionResponse) {
        viewController?.displayTimeOut(responseDisplay: .init(isTimedOut: actionResponse.isTimedOut))
    }
    
    func presentTermsAndConditions(actionResponse: OrderPreviewModels.TermsAndConditions.ActionResponse) {
        viewController?.displayTermsAndConditions(responseDisplay: .init(url: actionResponse.url))
    }
    
    func presentSubmit(actionResponse: OrderPreviewModels.Submit.ActionResponse) {
        guard let reference = actionResponse.paymentReference,
              actionResponse.failed == false else {
            let responseCode = actionResponse.responseCode ?? ""
            var failureReason: BaseInfoModels.FailureReason {
                switch (actionResponse.isAch, actionResponse.previewType) {
                case (true, .buy):
                    return .buyAch(actionResponse.achDeliveryType, responseCode)
                    
                case (false, .buy):
                    return .buyCard(actionResponse.errorDescription)
                    
                default:
                    return .sell
                }
            }
            
            viewController?.displayFailure(responseDisplay: .init(reason: failureReason))
            
            return
        }
        
        var successReason: BaseInfoModels.SuccessReason {
            switch (actionResponse.isAch, actionResponse.previewType) {
            case (true, .buy):
                return .buyAch(actionResponse.achDeliveryType)
                
            case (false, .buy):
                return .buyCard
                
            default:
                return .sell
            }
        }
        viewController?.displaySubmit(responseDisplay: .init(paymentReference: reference, reason: successReason))
    }
    
    func presentAchInstantDrawer(actionResponse: OrderPreviewModels.AchInstantDrawer.ActionResponse) {
        guard let instantLimit = actionResponse.quote?.instantAch?.limitUsd,
              let cryptoLimit = actionResponse.quote?.instantAch?.limitInToCurrency,
              let toAmount = actionResponse.to else { return }
        let fiatCurrency = (actionResponse.quote?.fromFee?.currency ?? Constant.usdCurrencyCode).uppercased()
        let cryptoCurrency = toAmount.currency.code.uppercased()
        let currencyFormat = "%@ %@"
        
        var description: String {
            if toAmount.fiatValue > instantLimit {
                let regularCrypto = toAmount.tokenValue - cryptoLimit
                let regularFiat = toAmount.fiatValue - instantLimit
                
                let cryptoInstantAmount = String(format: currencyFormat, ExchangeFormatter.current.string(for: cryptoLimit) ?? "", cryptoCurrency)
                let cryptoRegularAmount = String(format: currencyFormat, ExchangeFormatter.current.string(for: regularCrypto) ?? "", cryptoCurrency)
                let fiatInstantAmount = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: instantLimit) ?? "", fiatCurrency)
                let fiatRegularAmount = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: regularFiat) ?? "", fiatCurrency)

                return L10n.Buy.Ach.Instant.hybridConfirmationDrawer(cryptoInstantAmount, fiatInstantAmount, cryptoRegularAmount, fiatRegularAmount)
            } else {
                let cryptoAmount = String(format: currencyFormat, ExchangeFormatter.current.string(for: toAmount.tokenValue) ?? "", cryptoCurrency)
                let fiatAmount = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: toAmount.fiatValue) ?? "", fiatCurrency)
                
                return L10n.Buy.Ach.Instant.ConfirmationDrawer.description(cryptoAmount, fiatAmount)
            }
        }

        let drawerConfig = DrawerConfiguration(buttons: [Presets.Button.primary])
        let drawerViewModel = DrawerViewModel(title: .text(L10n.Buy.Ach.Instant.ConfirmationDrawer.title),
                                              description: .text(description),
                                              buttons: [.init(title: L10n.Buy.Ach.Instant.ConfirmationDrawer.confirmAction)],
                                              notice: .init(title: L10n.Buy.Ach.Instant.ConfirmationDrawer.notice, image: Asset.flash.image))
        let drawerCallbacks: [ (() -> Void) ] = [ { [weak self] in
            self?.viewController?.showPinInput()
        }]
        
        viewController?.displayAchInstantDrawer(responseDisplay: .init(model: drawerViewModel,
                                                                       config: drawerConfig,
                                                                       callbacks: drawerCallbacks))
    }
    
    func presentToggleTickbox(actionResponse: OrderPreviewModels.Tickbox.ActionResponse) {
        viewController?.displayContinueEnabled(responseDisplay: .init(continueEnabled: actionResponse.value))
    }
    
    func presentPreview(actionRespone: OrderPreviewModels.Preview.ActionResponse) {
        viewController?.displayPreview(responseDisplay: .init(infoModel: prepareOrderPreviewViewModel(for: actionRespone.item)))
    }
    
    // MARK: - Additional Helpers
    
    private func prepareOrderPreviewViewModel(for item: Models.Item) -> BuyOrderViewModel {
        let model: BuyOrderViewModel
        
        guard let toAmount = item.to,
              let quote = item.quote,
              let isAchAccount = item.isAchAccount else {
            return .init(amount: .init(title: .text(""), value: .text("")), cardFee: .init(title: .text(""), value: .text("")),
                         networkFee: .init(title: .text(""), value: .text("")), totalCost: .init(title: .text(""), value: .text("")))
        }
        
        let to = toAmount.fiatValue
        let infoImage = Asset.help.image.withRenderingMode(.alwaysOriginal)
        let toFiatValue = toAmount.fiatValue
        let toCryptoValue = ExchangeFormatter.current.string(for: toAmount.tokenValue) ?? ""
        let toCryptoDisplayImage = item.to?.currency.imageSquareBackground
        let toCryptoDisplayName = item.to?.currency.displayName ?? ""
        let from = item.from ?? 0
        var cardFee = from * (quote.buyFee ?? 0) / 100 + (quote.buyFeeUsd ?? 0)
        
        // Add fixed rate for small purchases (buy with card only)
        let fromFeeRateThreshold = quote.fromFeeRateThreshold ?? 0
        if item.type == .buy && !isAchAccount, from < fromFeeRateThreshold, let feeRate = quote.fromFeeRate {
            cardFee += feeRate
        }
        
        let cardFeeValue: Decimal = item.type == .sell ? -cardFee : cardFee

        let usdCurrency = Constant.usdCurrencyCode.uppercased()
        let fiatCurrency = item.type == .sell ? usdCurrency : (quote.fromFee?.currency.uppercased() ?? usdCurrency)
        let instantAchFee = (item.quote?.instantAch?.feePercentage ?? 0) / 100
        let instantAchLimit = item.quote?.instantAch?.limitUsd ?? 0
        
        let isInstantAch: Bool = (isAchAccount && item.achDeliveryType == .instant)
        
        // If purchase value exceeds instant ach limit the purchase is split, so network fee is applied to both instant and normal purchase
        var networkFee: Decimal {
            guard isInstantAch, toFiatValue >= instantAchLimit else {
                return item.networkFee?.fiatValue ?? 0
            }
            
            return 2 * (item.networkFee?.fiatValue ?? 0)
        }
        
        let currencyFormat = "%@ %@"
        let amountText = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: to) ?? "", fiatCurrency)
        let cardFeeText = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: cardFeeValue) ?? "", fiatCurrency)
        let networkFeeText = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: networkFee) ?? "", fiatCurrency)
        
        let rate = String(format: Constant.exchangeFormat, toAmount.currency.code, ExchangeFormatter.fiat.string(for: 1 / quote.exchangeRate) ?? "", fiatCurrency)
        
        let cardFeeModel: TitleValueViewModel = isAchAccount ?
            .init(title: isInstantAch ? .text("\(L10n.Sell.achFee) (\(L10n.Buy.Ach.Hybrid.title))") : .text(L10n.Sell.achFee),
                  value: .text(cardFeeText)) :
            .init(title: .text(L10n.Swap.cardFee),
                  value: .text(cardFeeText),
                  infoImage: .image(infoImage))
        
        let buyFee = ((quote.buyFee ?? 0) / 100) + 1
        // If purchase value exceeds the instant ach limit we use the latter as a basis for instant ach fee
        let instantAchFeeBasis = min(to, instantAchLimit)
        let instantAchFeeUsd = instantAchFeeBasis * instantAchFee * buyFee
        
        let achFeeDescription: String = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: instantAchFeeUsd) ?? "", fiatCurrency)
        let instantBuyFee: TitleValueViewModel? = isInstantAch ? .init(title: .text(L10n.Buy.Ach.Instant.Fee.Alternative.title), value: .text(achFeeDescription)) : nil
        let exceedsInstantBuyLimit: Bool = toFiatValue > instantAchLimit
        
        var instantAchNoticeText: String {
            if exceedsInstantBuyLimit {
                let regularPart = toFiatValue - instantAchLimit
                let instantAmount = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: instantAchLimit) ?? "", fiatCurrency)
                let regularAmount = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: regularPart) ?? "", fiatCurrency)
                return L10n.Buy.Ach.Instant.OrderPreview.hybridNotice(instantAmount, regularAmount)
            } else {
                let formatedAmount = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: toFiatValue) ?? "", fiatCurrency)
                return L10n.Buy.Ach.Instant.OrderPreview.notice(formatedAmount)
            }
        }
        
        switch item.type {
        case .sell:
            let totalText = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: toFiatValue - networkFee - cardFee) ?? "", fiatCurrency)
            model = .init(title: .text(L10n.Sell.yourOrder),
                          currencyIcon: .image(toCryptoDisplayImage),
                          currencyAmountName: .text(toCryptoValue + " " + toCryptoDisplayName),
                          rate: .init(title: .text(L10n.Sell.rate), value: .text(rate), infoImage: nil),
                          amount: .init(title: .text(L10n.Sell.subtotal), value: .text(amountText)),
                          networkFee: cardFeeModel,
                          totalCost: .init(title: .text(L10n.Swap.youReceive), value: .text(totalText)))
            
        default:
            var totalFee = toFiatValue + networkFee + cardFee
            // Opting for instant ach adds instant ach fee
            if isInstantAch {
                totalFee += instantAchFeeUsd
            }
            
            let totalText = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: totalFee) ?? "", fiatCurrency)
            model = .init(notice: isInstantAch ? .text(instantAchNoticeText) : nil,
                          currencyIcon: .image(toCryptoDisplayImage),
                          currencyAmountName: .text(toCryptoValue + " " + toCryptoDisplayName),
                          rate: .init(title: .text(L10n.Swap.rateValue), value: .text(rate), infoImage: nil),
                          amount: .init(title: .text(L10n.Swap.amountPurchased), value: .text(amountText), infoImage: nil),
                          cardFee: cardFeeModel,
                          instantBuyFee: instantBuyFee,
                          networkFee: .init(title: .text(L10n.Swap.miningNetworkFee),
                                            value: .text(networkFeeText),
                                            infoImage: .image(infoImage)),
                          totalCost: .init(title: .text(L10n.Swap.total), value: .text(totalText)),
            exceedInstantBuyLimit: exceedsInstantBuyLimit)
        }
        
        return model
    }
}
