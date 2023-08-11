// 
//  ConvertBchWorker.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 21.4.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct ConvertBchRequestData: RequestModelData {
    let address: String
    
    func getParameters() -> [String: Any] {
        let params = [
            "address": address
        ]
        return params
    }
}

struct ConvertBchResponseData: ModelResponse {
    var legacyAddress: String?
    var cashAddress: String?
}

struct ConvertBchModel: Model {
    var legacyAddress: String?
    var cashAddress: String?
}

class ConvertBchMapper: ModelMapper<ConvertBchResponseData, ConvertBchModel> {
    override func getModel(from response: ConvertBchResponseData?) -> ConvertBchModel? {
        return .init(legacyAddress: response?.legacyAddress,
                     cashAddress: response?.cashAddress)
    }
}

class ConvertBchWorker: BaseApiWorker<ConvertBchMapper> {
    override func getUrl() -> String {
        guard let urlParams = (requestData as? ConvertBchRequestData)?.address else { return "" }
        
        return APIURLHandler.getUrl(BlocksatoshiEndpoints.convertBchAddress, parameters: urlParams)
    }
}
