// 
//  RetrieveAddressWorker.swift
//  breadwallet
//
//  Created by Dino Gacevic on 15/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct RetrievedAddressRequestModel: RequestModelData {
    let id: String?
    
    func getParameters() -> [String: Any] {
        let params = [
            "Id": id
        ]
        
        return params.compactMapValues { $0 }
    }
}

class RetrieveAddressWorker: BaseApiWorker<RetrievedAddressMapper> {
    override func getUrl() -> String {
        guard let urlParams = (requestData as? RetrievedAddressRequestModel),
              let id = urlParams.id else {
            return ""
        }
                
        return APIURLHandler.getUrl(LoquateEndpoints.retrieve, parameters: [E.loqateKey, id])
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func setDecodingStrategy() -> JSONDecoder.KeyDecodingStrategy {
        return .convertFromPascalCase
    }
}

struct RetrievedAddressResponseModel: Codable {
    var id: String?
    var street: String?
    var buildingNumber: String?
    var city: String?
    var postalCode: String?
    var countryName: String?
    var countryIso2: String?
    var provinceName: String?
    var provinceCode: String?
}

struct RetrievedAddressResponseData: ModelResponse {
    var items: [RetrievedAddressResponseModel]?
}

struct RetrievedAddress: Model {
    var id: String?
    var street: String?
    var buildingNumber: String?
    var city: String?
    var postalCode: String?
    var countryName: String?
    var countryIso2: String?
    var province: String?
    var provinceCode: String?
    
    init(with response: RetrievedAddressResponseModel?) {
        id = response?.id
        street = response?.street
        buildingNumber = response?.buildingNumber
        city = response?.city
        postalCode = response?.postalCode
        countryName = response?.countryName
        countryIso2 = response?.countryIso2
        province = response?.provinceName
        provinceCode = response?.provinceCode
    }
}

class RetrievedAddressMapper: ModelMapper<RetrievedAddressResponseData, [RetrievedAddress]> {
    override func getModel(from response: RetrievedAddressResponseData?) -> [RetrievedAddress]? {
        return response?.items?.compactMap { .init(with: $0) }
    }
}
