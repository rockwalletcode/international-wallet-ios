// 
//  PaymentCardsWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 09/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct PaymentCardsResponseData: ModelResponse {
    struct PaymentInstrument: ModelResponse {
        var type: String
        var id: String?
        var fingerprint: String?
        var expiryMonth: Int?
        var expiryYear: Int?
        var scheme: String?
        var last4: String?
        var accountName: String?
        var status: String?
        var cardType: String?
        var paymentMethodStatus: String?
        var usedOnBuy: Bool?
    }
    
    var paymentInstruments: [PaymentInstrument]
}

struct PaymentCard: ItemSelectable {
    enum Scheme: String {
        case visa = "VISA"
        case mastercard = "MASTERCARD"
        case none = "card"
    }
    
    enum PaymentType: String, CaseIterable {
        case card = "card"
        case ach = "bank_account"
    }
    
    enum Status: String, CaseIterable {
        case statusOk = "OK"
        case requiredLogin = "LOGIN_REQUIRED"
        case pendingExpiration = "LOGIN_PENDING_EXPIRATION"
        case none
    }
    
    enum CardType: String, CaseIterable {
        case credit = "CREDIT"
        case debit = "DEBIT"
        case none
    }
    
    enum PaymentMethodStatus: String, CaseIterableDefaultsLast {
        case active
        case suspended
        case blocked
        case none
        
        var isProblematic: Bool {
            switch self {
            case .active:
                return false
                
            default:
                return true
            }
        }
        
        var unavailableText: NSMutableAttributedString {
            let attributedString = NSMutableAttributedString(string: L10n.PaymentMethod.unavailable)
            
            let maxRange = NSRange(location: 0, length: attributedString.mutableString.length)
            attributedString.addAttribute(.font, value: Fonts.Body.three, range: maxRange)
            attributedString.addAttribute(.foregroundColor, value: Colors.Error.one, range: maxRange)
            
            let range = attributedString.mutableString.range(of: L10n.Buy.PaymentMethodBlocked.link)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
            attributedString.addAttribute(.font, value: Fonts.Subtitle.three, range: range)
            
            return attributedString
        }
    }
    
    var type: PaymentType
    var id: String
    var fingerprint: String
    var expiryMonth: Int
    var expiryYear: Int
    var scheme: Scheme
    var last4: String
    var image: UIImage?
    var accountName: String
    var status: Status
    var cardType: CardType
    var paymentMethodStatus: PaymentMethodStatus
    var verifiedToSell: Bool?
    
    var displayName: String? {
        switch type {
        case .ach:
            return "\(accountName) - \(CardDetailsFormatter.formatBankNumber(last4: last4))"
        default:
            return CardDetailsFormatter.formatNumber(last4: last4)
        }   
    }
    
    var displayImage: ImageViewModel? {
        switch type {
        case .ach:
            return .image(Asset.bank.image) 
        default:
            return .imageName(scheme.rawValue)
        }
    }
}

class PaymentCardsMapper: ModelMapper<PaymentCardsResponseData, [PaymentCard]> {
    override func getModel(from response: PaymentCardsResponseData?) -> [PaymentCard] {
        return response?.paymentInstruments.compactMap {
            return PaymentCard(type: PaymentCard.PaymentType(rawValue: $0.type) ?? .card,
                               id: $0.id ?? "",
                               fingerprint: $0.fingerprint ?? "",
                               expiryMonth: $0.expiryMonth ?? 0,
                               expiryYear: $0.expiryYear ?? 0,
                               scheme: PaymentCard.Scheme(rawValue: $0.scheme ?? "") ?? .none,
                               last4: $0.last4 ?? "",
                               accountName: $0.accountName ?? "",
                               status: PaymentCard.Status(rawValue: $0.status ?? "") ?? .none,
                               cardType: PaymentCard.CardType(rawValue: $0.cardType ?? "") ?? .none,
                               paymentMethodStatus: PaymentCard.PaymentMethodStatus(rawValue: $0.paymentMethodStatus ?? "") ?? .none,
                               verifiedToSell: $0.usedOnBuy)
        } ?? []
    }
}

struct PaymentCardsRequestData: RequestModelData {
    func getParameters() -> [String: Any] {
        return [:]
    }
}

class PaymentCardsWorker: BaseApiWorker<PaymentCardsMapper> {
    override func getUrl() -> String {
        return ExchangeEndpoints.paymentInstruments.url
    }
}

class SellPaymentCardsWorker: BaseApiWorker<PaymentCardsMapper> {
    override func getUrl() -> String {
        return ExchangeEndpoints.sellPaymentInstruments.url
    }
}
