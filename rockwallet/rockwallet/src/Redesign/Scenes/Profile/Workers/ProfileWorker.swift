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
            case sell = "SELL_ACH"
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
        let restrictionReason: RestrictionReason?
        
        enum RestrictionReason: String {
            case kyc
            case country
            case state
            case manuallyConfigured = "manually_configured"
        }
    }
    
    var swapAllowancePerExchange: Decimal {
        return limits.first(where: { $0.interval == .perExchange && $0.exchangeType == .swap })?.limit ?? 0
    }
    var swapAllowanceDaily: Decimal {
        return limits.first(where: { $0.interval == .daily && $0.exchangeType == .swap })?.limit ?? 0
    }
    var swapAllowanceLifetime: Decimal {
        return limits.first(where: { $0.interval == .lifetime && $0.exchangeType == .swap })?.limit ?? 0
    }
    
    var achAllowanceLifetime: Decimal {
        return limits.first(where: { $0.interval == .lifetime && $0.exchangeType == .buyAch })?.limit ?? 0
    }
    var achAllowanceDaily: Decimal {
        return limits.first(where: { $0.interval == .daily && $0.exchangeType == .buyAch })?.limit ?? 0
    }
    var achAllowancePerExchange: Decimal {
        return limits.first(where: { $0.interval == .perExchange && $0.exchangeType == .buyAch })?.limit ?? 0
    }
    
    var buyAllowancePerExchange: Decimal {
        return limits.first(where: { $0.interval == .perExchange && $0.exchangeType == .buyCard })?.limit ?? 0
    }
    var buyAllowanceDaily: Decimal {
        return limits.first(where: { $0.interval == .daily && $0.exchangeType == .buyCard })?.limit ?? 0
    }
    var buyAllowanceWeekly: Decimal {
        return limits.first(where: { $0.interval == .weekly && $0.exchangeType == .buyCard })?.limit ?? 0
    }
    var buyAllowanceMonthly: Decimal {
        return limits.first(where: { $0.interval == .monthly && $0.exchangeType == .buyCard })?.limit ?? 0
    }
    var buyAllowanceDailyMin: Decimal {
        return limits.first(where: { $0.interval == .minimum && $0.exchangeType == .buyCard })?.limit ?? 0
    }
    var buyAllowanceDailyMax: Decimal {
        return limits.first(where: { $0.interval == .daily && $0.exchangeType == .buyCard })?.limit ?? 0
    }
    var buyAllowanceLifetime: Decimal {
        return limits.first(where: { $0.interval == .lifetime && $0.exchangeType == .buyCard })?.limit ?? 0
    }
    
    var achAllowanceDailyMin: Decimal {
        return limits.first(where: { $0.interval == .minimum && $0.exchangeType == .buyAch })?.limit ?? 0
    }
    var achAllowanceDailyMax: Decimal {
        return limits.first(where: { $0.interval == .daily && $0.exchangeType == .buyAch })?.limit ?? 0
    }
    var achAllowanceWeekly: Decimal {
        return limits.first(where: { $0.interval == .weekly && $0.exchangeType == .buyAch })?.limit ?? 0
    }
    var achAllowanceMonthly: Decimal {
        return limits.first(where: { $0.interval == .monthly && $0.exchangeType == .buyAch })?.limit ?? 0
    }
    
    var sellAllowanceLifetime: Decimal {
        return limits.first(where: { $0.interval == .lifetime && $0.exchangeType == .sell })?.limit ?? 0
    }
    var sellAllowanceDaily: Decimal {
        return limits.first(where: { $0.interval == .daily && $0.exchangeType == .sell })?.limit ?? 0
    }
    var sellAllowanceWeekly: Decimal {
        return limits.first(where: { $0.interval == .weekly && $0.exchangeType == .sell })?.limit ?? 0
    }
    var sellAllowancePerExchange: Decimal {
        return limits.first(where: { $0.interval == .perExchange && $0.exchangeType == .sell })?.limit ?? 0
    }
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
