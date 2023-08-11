// 
//  LogoutWorker.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 4.4.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class LogoutWorker: BaseApiWorker<PlainMapper> {
    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCAuthEndpoints.logout)
    }
    
    override func getMethod() -> HTTPMethod {
        return .post
    }
}
