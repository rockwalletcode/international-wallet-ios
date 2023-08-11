// 
//  UpdateSsnWorker.swift
//  breadwallet
//
//  Created by Dino Gacevic on 25/07/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct UpdateSsnRequestData: RequestModelData {
    let ssn: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "ssn": ssn
        ]
        return params.compactMapValues { $0 }
    }
}

class UpdateSsnWorker: BaseApiWorker<ProfileMapper> {
    override func getUrl() -> String {
        return KYCEndpoints.updateSsn.url
    }
    
    override func getMethod() -> HTTPMethod {
        return .put
    }
}
