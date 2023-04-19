// 
//  TwoStepDeleteWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 19/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct TwoStepDeleteRequestData: RequestModelData {
    var updateCode: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "update_code": updateCode
        ]
        
        return params.compactMapValues { $0 }
    }
}

class TwoStepDeleteWorker: BaseApiWorker<PlainMapper> {
    override func getUrl() -> String {
        var url = TwoStepEndpoints.delete.url
        var modifiedUrl = url.remove(at: url.index(before: url.endIndex))
        
        return modifiedUrl
    }
    
    override func getMethod() -> HTTPMethod {
        return .delete
    }
}
