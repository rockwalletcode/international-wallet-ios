// 
//  KYCSubmitInfoWorker.swift
//  breadwallet
//
//  Created by Dino Gacevic on 07/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct KYCUserInfoRequestData: RequestModelData {
    let firstName: String
    let lastName: String
    let dateOfBirth: String
    let address: String
    let city: String
    let zip: String
    let country: String
    let state: String?
    let nologSSN: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "first_name": firstName,
            "last_name": lastName,
            "date_of_birth": dateOfBirth,
            "address": address,
            "city": city,
            "zip": zip,
            "country": country,
            "state": state,
            "nolog_ssn": nologSSN
        ]
        
        return params.compactMapValues { $0 }
    }
}

class KYCSubmitInfoWorker: BaseApiWorker<PlainMapper> {
    override func getUrl() -> String {
        return KYCEndpoints.userInformation.url
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func getMethod() -> HTTPMethod {
        return .post
    }
}
