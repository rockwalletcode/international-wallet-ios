//
//  OrderPreviewModels.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.8.22.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum PreviewType {
    case buy
    case sell
    
    var title: String {
        switch self {
        case .buy: return L10n.Buy.orderPreview
        case .sell: return L10n.Sell.orderPreview
        }
    }
    
    var disclaimer: String {
        switch self {
        case .buy: return L10n.Buy.achPaymentDurationWarning
        case .sell: return L10n.Sell.achDurationWarning
        }
    }
}

enum OrderPreviewModels {
    
    typealias Item = (type: PreviewType?,
                      to: Amount?,
                      from: Decimal?,
                      quote: Quote?,
                      networkFee: Amount?,
                      card: PaymentCard?,
                      isAchAccount: Bool?,
                      achDeliveryType: AchDeliveryType?)
    
    enum Section: Sectionable {
        case achSegment
        case disclaimer
        case orderInfoCard
        case payment
        case termsAndConditions
        case submit
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct InfoPopup {
        struct ViewAction {
            var isCardFee: Bool
        }
        struct ActionResponse {
            var isCardFee: Bool
            var fee: Decimal?
        }
        struct ResponseDisplay {
            var model: PopupViewModel
        }
    }
    
    struct AchInstantDrawer {
        struct ViewAction {}
        struct ActionResponse {
            var quote: Quote?
            var to: Amount?
        }
        struct ResponseDisplay {
            var model: DrawerViewModel
            var config: DrawerConfiguration
            let callbacks: [(() -> Void)]
        }
    }
    
    struct VeriffLivenessCheck {
        struct ActionResponse {
            var quoteId: String?
            var isBiometric: Bool?
        }
        
        struct ResponseDisplay {
            var quoteId: String?
            var isBiometric: Bool?
        }
    }
    
    struct BiometricStatusCheck {
        struct ViewAction {
            let resetCounter: Bool
        }
    }
    
    struct BiometricStatusFailed {
        struct ActionResponse {
            var reason: BaseInfoModels.FailureReason?
        }
        
        struct ResponseDisplay {
            var reason: BaseInfoModels.FailureReason?
        }
    }
    
    struct ThreeDSecure {
        struct ActionResponse {
            var url: URL
        }
        
        struct ResponseDisplay {
            var url: URL
        }
    }
    
    struct ThreeDSecureStatus {
        struct ViewAction {}
    }
    
    struct CvvValidation {
        struct ViewAction {
            var cvv: String?
        }
        
        struct ActionResponse {
            var isValid: Bool
        }
        
        struct ResponseDisplay {
            var continueEnabled: Bool
        }
    }
    
    struct TermsAndConditions {
        struct ViewAction {}
        
        struct ActionResponse {
            var url: URL
        }
        
        struct ResponseDisplay {
            var url: URL
        }
    }
    
    struct ExpirationValidations {
        struct ViewAction {}
        
        struct ActionResponse {
            var isTimedOut: Bool
        }
        
        struct ResponseDisplay {
            var isTimedOut: Bool
        }
    }
    
    struct CvvInfoPopup {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {
            var model: PopupViewModel
        }
    }
    
    struct Submit {
        struct ViewAction {}
        
        struct ActionResponse {
            var paymentReference: String?
            var previewType: PreviewType?
            var isAch: Bool?
            var achDeliveryType: AchDeliveryType?
            var failed: Bool?
            var responseCode: String?
            var errorDescription: String?
        }
        
        struct ResponseDisplay {
            var paymentReference: String
            var reason: BaseInfoModels.SuccessReason
        }
    }
    
    struct Failure {
        struct ResponseDisplay {
            var reason: BaseInfoModels.FailureReason
        }
    }
    
    struct Tickbox {
        struct ViewAction {
            var value: Bool
        }
        
        struct ActionResponse {
            var value: Bool
        }
        
        struct ResponseDisplay {}
    }
    
    enum AchDeliveryType: CaseIterable {
        case instant
        case normal
    }
    
    struct SelectAchDeliveryType {
        struct ViewAction {
            var achDeliveryType: AchDeliveryType
        }
    }
    
    struct Preview {
        struct ActionResponse {
            var item: Item
        }
        struct ResponseDsiaply {
            var infoModel: BuyOrderViewModel
        }
    }
}
