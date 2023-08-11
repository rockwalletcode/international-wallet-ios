// 
//  PaymailDestinationWorker.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 10/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct PaymailDestinationRequestData: RequestModelData {
    let address: String
    
    func getParameters() -> [String: Any] {
        let params = [
            "address": address
        ]
        return params
    }
}

struct PaymailDestinationResponseData: ModelResponse {
    var output: String?
}

struct PaymailDestinationModel: Model {
    var output: String?
}

class PaymailDestinationWorkerMapper: ModelMapper<PaymailDestinationResponseData, PaymailDestinationModel> {
    override func getModel(from response: PaymailDestinationResponseData?) -> PaymailDestinationModel? {
        return .init(output: response?.output)
    }
}

class PaymailDestinationWorker: BaseApiWorker<PaymailDestinationWorkerMapper> {
    override func getUrl() -> String {
        return BlocksatoshiEndpoints.paymailDestination.url
    }

    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }

    override func getMethod() -> HTTPMethod {
        return .post
    }
}
