// 
//  ConfirmationCodesWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 09/05/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class ConfirmationCodesWorker: BaseApiWorker<PlainMapper> {
    override func getUrl() -> String {
        guard E.isDevelopment else { return "" }
        return KYCAuthEndpoints.confirmationCodes.url
    }
}
