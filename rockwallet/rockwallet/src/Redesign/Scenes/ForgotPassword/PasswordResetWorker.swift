// 
//  PasswordResetWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 16/01/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct PasswordResetRequestData: RequestModelData {
    let email: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "email": email
        ]
        return params.compactMapValues { $0 }
    }
}

class PasswordResetWorker: BaseApiWorker<PlainMapper> {
    override func getUrl() -> String {
        return WalletEndpoints.reset.url
    }

    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }

    override func getMethod() -> HTTPMethod {
        return .post
    }
}
