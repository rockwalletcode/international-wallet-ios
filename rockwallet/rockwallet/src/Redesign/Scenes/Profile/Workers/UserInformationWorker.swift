// 
//  UserInformationWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 01/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct UserInformationResponseData: ModelResponse {
    struct UserPlace: ModelResponse {
        var iso2: String?
        var name: String?
    }
    
    var firstName: String?
    var lastName: String?
    var dateOfBirth: String?
    var address: String?
    var city: String?
    var zip: String?
    var country: UserPlace?
    var state: UserPlace?
    var nologSsn: String?
}

struct UserInformation: Model {
    var firstName: String?
    var lastName: String?
    var dateOfBirth: String?
    var address: String?
    var city: String?
    var zip: String?
    var country: Place?
    var state: Place?
    var nologSsn: String?
}

class UserInformationWorkerMapper: ModelMapper<UserInformationResponseData, UserInformation> {
    override func getModel(from response: UserInformationResponseData?) -> UserInformation? {
        return .init(firstName: response?.firstName,
                     lastName: response?.lastName,
                     dateOfBirth: response?.dateOfBirth,
                     address: response?.address,
                     city: response?.city,
                     zip: response?.zip,
                     country: Place(iso2: response?.country?.iso2 ?? "", name: response?.country?.name ?? ""),
                     state: Place(iso2: response?.state?.iso2 ?? "", name: response?.state?.name ?? ""),
                     nologSsn: response?.nologSsn)
    }
}

class UserInformationWorker: BaseApiWorker<UserInformationWorkerMapper> {
    override func getUrl() -> String {
        return KYCEndpoints.userInformation.url
    }
}
