// 
//  RejectLoginWorker.swift
//  rockwallet
//
//  Created by Dino Gačević on 13/10/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class RejectLoginWorker: BaseApiWorker<PlainMapper> {
    override func getUrl() -> String {
        return APIURLHandler.getUrl(WebLoginEndpoints.reject)
    }
}
