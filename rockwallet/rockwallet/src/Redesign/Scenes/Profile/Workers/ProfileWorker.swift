// 
//  ProfileWorker.swift
//  breadwallet
//
//  Created by Rok on 06/06/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

typealias ExchangeType = ProfileResponseData.ExchangeLimit.ExchangeType

struct ProfileRequestData: RequestModelData {
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "second_factor_code": secondFactorCode,
            "second_factor_backup": secondFactorBackup
        ]
        return params.compactMapValues { $0 }
    }
}

struct ProfileResponseData: ModelResponse {
    let email: String?
    var country: UserInformationResponseData.UserPlace?
    let kycStatus: String?
    let exchangeLimits: [ExchangeLimit]?
    let kycAccessRights: AccessRights?
    let kycFailureReason: String?
    let isRegistered: Bool?
    let hasPendingLimits: Bool?
    let paymail: String?
    
    struct AccessRights: Codable {
        let hasSwapAccess: Bool
        let hasBuyAccess: Bool
        let hasAchAccess: Bool
        let hasAchSellAccess: Bool
        let hasCardSellAccess: Bool
        let hasExchangeAccess: Bool
        let restrictionReason: String?
    }
    
    struct ExchangeLimit: Codable {
        let exchangeType: ExchangeType?
        let interval: Interval?
        let limit: Decimal?
        let isCustom: Bool?
        
        enum ExchangeType: String, Codable, CaseIterableDefaultsLast {
            case swap = "SWAP"
            case buyCard = "BUY_CARD"
            case buyAch = "BUY_ACH"
            case sellCard = "SELL_CARD"
            case sellAch = "SELL_ACH"
            case instantAch = "INSTANT_ACH"
            
            case unknown
        }
        
        enum Interval: String, Codable, CaseIterableDefaultsLast {
            case daily = "DAILY"
            case weekly = "WEEKLY"
            case monthly = "MONTHLY"
            case lifetime = "LIFETIME"
            case perExchange = "PER_EXCHANGE"
            case minimum = "MINIMUM"
            
            case unknown
            
            var title: String {
                switch self {
                case .daily:
                    return L10n.Account.daily
                    
                case .weekly:
                    return L10n.Account.weekly
                    
                case .monthly:
                    return L10n.Account.monthly
                    
                case .lifetime:
                    return L10n.Account.lifetime
                    
                case .perExchange:
                    return L10n.Account.perExchange
                    
                case .minimum:
                    return L10n.Account.minimum
                    
                case .unknown:
                    return ""
                }
            }
            
            /// Check the order from this link: https://bayes.atlassian.net/browse/RWDO-409
            var priorityOrder: Int {
                switch self {
                case .daily: return 3
                case .weekly: return 2
                case .monthly: return 1
                case .lifetime: return 6
                case .perExchange: return 4
                case .minimum: return 5
                case .unknown: return 7
                }
            }
        }
    }
}

struct Profile: Model {
    let email: String
    var country: Place?
    let status: VerificationStatus
    let limits: [ProfileResponseData.ExchangeLimit]
    let kycAccessRights: AccessRights
    let isMigrated: Bool
    let kycFailureReason: String?
    let hasPendingLimits: Bool
    let paymail: String?
    
    struct AccessRights {
        let hasSwapAccess: Bool
        let hasBuyAccess: Bool
        let hasAchAccess: Bool
        let hasAchSellAccess: Bool
        let hasCardSellAccess: Bool
        let hasExchangeAccess: Bool
        let restrictionReason: RestrictionReason?
        
        enum RestrictionReason: String {
            case kyc
            case country
            case state
            case manuallyConfigured = "manually_configured"
        }
    }
    
    // MARK: Swap
    
    var swapAllowancePerExchange: Decimal { limits.getLimit(interval: .perExchange, exchangeType: .swap) }
    var swapAllowanceDaily: Decimal { limits.getLimit(interval: .daily, exchangeType: .swap) }
    var swapAllowanceLifetime: Decimal { limits.getLimit(interval: .lifetime, exchangeType: .swap) }
    
    // MARK: Buy ACH
    
    var buyAchAllowancePerExchange: Decimal { limits.getLimit(interval: .perExchange, exchangeType: .buyAch) }
    var buyAchAllowanceDaily: Decimal { limits.getLimit(interval: .daily, exchangeType: .buyAch) }
    var buyAchAllowanceWeekly: Decimal { limits.getLimit(interval: .weekly, exchangeType: .buyAch) }
    var buyAchAllowanceMonthly: Decimal { limits.getLimit(interval: .monthly, exchangeType: .buyAch) }
    var buyAchAllowanceLifetime: Decimal { limits.getLimit(interval: .lifetime, exchangeType: .buyAch) }
    
    // MARK: Buy card
    
    var buyAllowancePerExchange: Decimal { limits.getLimit(interval: .perExchange, exchangeType: .buyCard) }
    var buyAllowanceDaily: Decimal { limits.getLimit(interval: .daily, exchangeType: .buyCard) }
    var buyAllowanceWeekly: Decimal { limits.getLimit(interval: .weekly, exchangeType: .buyCard) }
    var buyAllowanceMonthly: Decimal { limits.getLimit(interval: .monthly, exchangeType: .buyCard) }
    var buyAllowanceLifetime: Decimal { limits.getLimit(interval: .lifetime, exchangeType: .buyCard) }
    
    // MARK: Sell ACH
    
    var sellAchAllowancePerExchange: Decimal { limits.getLimit(interval: .perExchange, exchangeType: .sellAch) }
    var sellAchAllowanceDaily: Decimal { limits.getLimit(interval: .daily, exchangeType: .sellAch) }
    var sellAchAllowanceWeekly: Decimal { limits.getLimit(interval: .weekly, exchangeType: .sellAch) }
    var sellAchAllowanceMonthly: Decimal { limits.getLimit(interval: .monthly, exchangeType: .sellAch) }
    var sellAchAllowanceLifetime: Decimal { limits.getLimit(interval: .lifetime, exchangeType: .sellAch) }
    
    // MARK: Sell card
    
    var sellAllowancePerExchange: Decimal { limits.getLimit(interval: .perExchange, exchangeType: .sellCard) }
    var sellAllowanceDaily: Decimal { limits.getLimit(interval: .daily, exchangeType: .sellCard) }
    var sellAllowanceWeekly: Decimal { limits.getLimit(interval: .weekly, exchangeType: .sellCard) }
    var sellAllowanceMonthly: Decimal { limits.getLimit(interval: .monthly, exchangeType: .sellCard) }
    var sellAllowanceLifetime: Decimal { limits.getLimit(interval: .lifetime, exchangeType: .sellCard) }
}

class ProfileMapper: ModelMapper<ProfileResponseData, Profile> {
    override func getModel(from response: ProfileResponseData?) -> Profile? {
        guard let response = response else { return nil }
        
        return Profile(email: response.email ?? "",
                       country: Place(iso2: response.country?.iso2 ?? "", name: response.country?.name ?? ""),
                       status: VerificationStatus(rawValue: response.kycStatus),
                       limits: response.exchangeLimits ?? [],
                       kycAccessRights: .init(hasSwapAccess: response.kycAccessRights?.hasSwapAccess ?? false,
                                              hasBuyAccess: response.kycAccessRights?.hasBuyAccess ?? false,
                                              hasAchAccess: response.kycAccessRights?.hasAchAccess ?? false,
                                              hasAchSellAccess: response.kycAccessRights?.hasAchSellAccess ?? false,
                                              hasCardSellAccess: response.kycAccessRights?.hasCardSellAccess ?? false,
                                              hasExchangeAccess: response.kycAccessRights?.hasExchangeAccess ?? false,
                                              restrictionReason: .init(rawValue: response.kycAccessRights?.restrictionReason ?? "")),
                       isMigrated: response.isRegistered ?? false,
                       kycFailureReason: response.kycFailureReason,
                       hasPendingLimits: response.hasPendingLimits ?? false,
                       paymail: response.paymail)
    }
}

class ProfileWorker: BaseApiWorker<ProfileMapper> {
    override func getUrl() -> String {
        guard let urlParams = (requestData as? ProfileRequestData) else { return "" }
        
        if let code = urlParams.secondFactorCode {
            return APIURLHandler.getUrl(WalletEndpoints.profileSecondFactorCode, parameters: [code])
        } else if let code = urlParams.secondFactorBackup {
            return APIURLHandler.getUrl(WalletEndpoints.profileSecondFactorBackup, parameters: [code])
        } else {
            return APIURLHandler.getUrl(WalletEndpoints.profile)
        }
    }
}

extension Array where Element == ProfileResponseData.ExchangeLimit {
    func getLimit(interval: ProfileResponseData.ExchangeLimit.Interval, exchangeType: ProfileResponseData.ExchangeLimit.ExchangeType) -> Decimal {
        return self.first(where: { $0.interval == interval && $0.exchangeType == exchangeType })?.limit ?? 0
    }
}
