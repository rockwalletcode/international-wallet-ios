//
//  ExchangeDetailsPresenter.swift
//  breadwallet
//
//  Created by Rok on 06/07/2022.
//
//

import UIKit

final class ExchangeDetailsPresenter: NSObject, Presenter, ExchangeDetailsActionResponses {
    typealias Models = ExchangeDetailsModels

    weak var viewController: ExchangeDetailsViewController?

    // MARK: - ExchangeDetailsActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let detail = item.detail
        let part = item.part
        let type = detail.type
        let destination = detail.destination?.part == part ? detail.destination : detail.instantDestination
        
        var sections = [AnyHashable]()
        
        switch type {
        case .swap:
            sections = [
                Models.Section.header,
                Models.Section.order,
                Models.Section.fromCurrency,
                Models.Section.image,
                Models.Section.toCurrency,
                Models.Section.timestamp,
                Models.Section.transactionFrom,
                Models.Section.transactionTo
            ]
            
        case .buyCard, .buyAch, .sell:
            sections = [
                Models.Section.header,
                Models.Section.toCurrency,
                Models.Section.buyOrder,
                Models.Section.order,
                Models.Section.timestamp,
                Models.Section.transactionTo
            ]
            
        default:
            break
        }
        
        guard let status = destination?.status, let header = status.viewModel else { return }
        
        let destinationCurrencyAmount: Decimal = (detail.destination?.currencyAmount ?? 0) + (detail.instantDestination?.currencyAmount ?? 0)
        
        let fromImage = getBaseCurrencyImage(currencyCode: detail.source.currency)
        let toImage = getBaseCurrencyImage(currencyCode: destination?.currency ?? "")
        
        let currencyCode = Constant.usdCurrencyCode
        
        let formattedUsdAmountString = ExchangeFormatter.fiat.string(for: detail.source.usdAmount) ?? ""
        let formattedCurrencyAmountString = ExchangeFormatter.current.string(for: detail.source.currencyAmount) ?? ""
        let formattedCurrencyAmountDestination = ExchangeFormatter.current.string(for: destinationCurrencyAmount) ?? ""
        
        let timestamp = TimeInterval(detail.timestamp) / 1000
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM YYYY, H:mm a"
        let dateString = formatter.string(from: date)
        
        let orderValue = "\(detail.orderId)"
        let transactionFromValue = String(describing: detail.source.transactionId ?? "")
        let transactionToValue = String(describing: destination?.transactionId ?? status.rawValue.capitalized)
        let transactionToValueIsCopyable = destination?.transactionId != nil
        
        var toCurrencyAssetViewModel = AssetViewModel()
        
        switch type {
        case .swap:
            toCurrencyAssetViewModel = AssetViewModel(icon: toImage,
                                                      title: "\(L10n.TransactionDetails.addressToHeader) \(destination?.currency ?? "")",
                                                      topRightText: "\(formattedCurrencyAmountDestination) \(destination?.currency ?? "")")
            
        case .buyCard, .buyAch:
            toCurrencyAssetViewModel = AssetViewModel(icon: toImage,
                                                      title: "\(formattedCurrencyAmountDestination) \(destination?.currency ?? "")",
                                                      topRightText: nil)
            
        case .sell:
            toCurrencyAssetViewModel = AssetViewModel(icon: fromImage,
                                                      title: "\(formattedCurrencyAmountString) \(detail.source.currency)",
                                                      topRightText: nil)
        
        default:
            break
        }
        
        let sectionRows = [
            Models.Section.header: [header] as [any Hashable],
            Models.Section.order: [
                OrderViewModel(title: L10n.Swap.transactionID,
                               value: CopyTextIcon.generate(with: orderValue, isCopyable: true),
                               isCopyable: true)
            ],
            Models.Section.buyOrder: [
                prepareOrderViewModel(detail, destination: destination, for: type)
            ],
            Models.Section.fromCurrency: [
                AssetViewModel(icon: fromImage,
                               title: "\(L10n.TransactionDetails.addressFromHeader) \(detail.source.currency)",
                               topRightText: "\(formattedCurrencyAmountString) / \(formattedUsdAmountString) \(currencyCode)")
            ],
            Models.Section.image: [
                ImageViewModel.image(Asset.arrowDown.image.tinted(with: Colors.Text.three))
            ],
            Models.Section.toCurrency: [
                toCurrencyAssetViewModel
            ],
            Models.Section.timestamp: [
                OrderViewModel(title: L10n.Swap.timestamp,
                               value: CopyTextIcon.generate(with: dateString, isCopyable: false),
                               isCopyable: false)
            ],
            Models.Section.transactionFrom: [
                OrderViewModel(title: "\(detail.source.currency) \(L10n.TransactionDetails.txHashHeader)",
                               value: CopyTextIcon.generate(with: transactionFromValue, isCopyable: true),
                               isCopyable: true)
            ],
            Models.Section.transactionTo: [
                OrderViewModel(title: "\(destination?.currency ?? "") \(L10n.TransactionDetails.txHashHeader)",
                               value: CopyTextIcon.generate(with: transactionToValue,
                                                            isCopyable: transactionToValueIsCopyable),
                               isCopyable: transactionToValueIsCopyable)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentInfoPopup(actionResponse: ExchangeDetailsModels.InfoPopup.ActionResponse) {
        let model: PopupViewModel
        
        if actionResponse.isCardFee {
            model = .init(title: .text(L10n.Swap.cardFee),
                          body: L10n.Buy.cardFee)
        } else {
            model = .init(title: .text(L10n.Buy.networkFees),
                          body: L10n.Buy.networkFeeMessage)
        }
        
        viewController?.displayInfoPopup(responseDisplay: .init(model: model))
    }

    // MARK: - Additional Helpers
    
    private func getBaseCurrencyImage(currencyCode: String) -> UIImage? {
        guard let currency = Store.state.currencies.first(where: { $0.code == currencyCode }) else { return nil }
        
        return currency.imageSquareBackground
    }
    
    private func prepareOrderViewModel(_ detail: ExchangeDetail, destination: ExchangeDetail.SourceDestination?, for type: ExchangeType) -> BuyOrderViewModel? {
        guard let destination else { return nil }
        
        let currencyCode = Constant.usdCurrencyCode
        let card = type == .sell ? destination.paymentInstrument : detail.source.paymentInstrument
        let infoImage = Asset.help.image.withRenderingMode(.alwaysOriginal)
        
        let currencyFormat = Constant.currencyFormat
        var rate: String {
            guard type == .sell else {
                return String(format: Constant.exchangeFormat, destination.currency, ExchangeNumberFormatter().string(for: 1 / detail.rate) ?? "", currencyCode)
            }
            
            return String(format: Constant.exchangeFormat, detail.source.currency, ExchangeNumberFormatter().string(for: detail.rate) ?? "", currencyCode)
        }
        
        let totalAmount: Decimal = type == .sell ? destination.currencyAmount : detail.source.currencyAmount
        let totalText = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: totalAmount) ?? "",
                               currencyCode)
        var amountValue: Decimal {
            guard type == .sell else {
                return detail.source.currencyAmount - detail.source.usdFee - (detail.destination?.usdFee ?? 0) - (detail.instantDestination?.usdFee ?? 0)
            }
            
            return destination.currencyAmount + destination.usdFee
        }
        let amountText = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: amountValue) ?? "",
                                currencyCode)
        let cardFeeText = String(format: currencyFormat, ExchangeFormatter.fiat.string(for: detail.source.usdFee) ?? "",
                                 currencyCode)
        
        var networkFee: Decimal {
            guard type == .sell else {
                return (detail.destination?.usdFee ?? 0) + (detail.instantDestination?.usdFee ?? 0)
            }
            
            return 0 - (detail.destination?.usdFee ?? 0) - (detail.instantDestination?.usdFee ?? 0)
        }
        let networkFeeText = String(format: currencyFormat,
                                    ExchangeFormatter.fiat.string(for: networkFee) ?? "",
                                    currencyCode)
        
        let displayFeeTitle = card?.type == .card ? L10n.Swap.cardFee : L10n.Sell.achFee
        
        let method = PaymentMethodViewModel(methodTitle: .text(L10n.Sell.widrawToBank),
                                            logo: card?.displayImage,
                                            type: card?.type,
                                            previewFor: .sell,
                                            cardNumber: .text(card?.displayName ?? ""),
                                            expiration: .text(CardDetailsFormatter.formatExpirationDate(month: card?.expiryMonth ?? 0,
                                                                                                        year: card?.expiryYear ?? 0)),
                                            cvvTitle: nil,
                                            cvv: nil)
        
        let model: BuyOrderViewModel
        switch type {
        case .sell:
            model = BuyOrderViewModel(rate: .init(title: .text(L10n.Sell.rate), value: .text(rate), infoImage: nil),
                                      amount: .init(title: .text("\(L10n.Sell.subtotal)"), value: .text(amountText), infoImage: nil),
                                      cardFee: .init(title: .text(displayFeeTitle), value: .text(networkFeeText)),
                                      totalCost: .init(title: .text(L10n.Sell.youWillReceive), value: .text(totalText)),
                                      paymentMethod: method)
            
        default:
            model = BuyOrderViewModel(rate: .init(title: .text(L10n.Swap.rateValue), value: .text(rate), infoImage: nil),
                                      amount: .init(title: .text("\(L10n.Swap.amountPurchased)"), value: .text(amountText), infoImage: nil),
                                      cardFee: .init(title: .text(displayFeeTitle),
                                                     value: .text(cardFeeText),
                                                     infoImage: card?.type == .card ? .image(infoImage) : nil),
                                      networkFee: .init(title: .text(L10n.Swap.miningNetworkFee), value: .text(networkFeeText), infoImage: .image(infoImage)),
                                      totalCost: .init(title: .text(L10n.Swap.total), value: .text(totalText)),
                                      paymentMethod: .init(methodTitle: .text(L10n.Swap.paidWith),
                                                           logo: card?.displayImage,
                                                           type: card?.type,
                                                           cardNumber: .text(card?.displayName),
                                                           expiration: .text(CardDetailsFormatter.formatExpirationDate(month: card?.expiryMonth ?? 0,
                                                                                                                       year: card?.expiryYear ?? 0)),
                                                           cvvTitle: nil, cvv: nil))
        }
        return model
    }
}
