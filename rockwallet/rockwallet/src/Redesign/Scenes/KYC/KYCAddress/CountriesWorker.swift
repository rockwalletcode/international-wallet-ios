// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import Foundation

struct CountriesResponseData: ModelResponse {
    struct CountryResponseData: ModelResponse {
        var iso2: String
        var localizedName: String
        var states: [Place]?
    }
    
    var countries: [CountryResponseData]
}

struct Place: ModelResponse, ItemSelectable {
    var iso2: String
    var name: String
    
    var displayName: String? { return name }
    var displayImage: ImageViewModel? { return nil }
}

struct Country: Model, ItemSelectable {
    var iso2: String
    var name: String
    var areaCode: String?
    
    var states: [Place]?
    
    var displayName: String? { return name }
    var displayImage: ImageViewModel? { return .imageName(iso2) }
}

class CountriesMapper: ModelMapper<CountriesResponseData, [Country]> {
    override func getModel(from response: CountriesResponseData?) -> [Country]? {
        var countries = response?.countries.compactMap({ return Country(iso2: $0.iso2, name: $0.localizedName, states: $0.states) })
        
        if let firstIndexUS = countries?.firstIndex(where: { $0.iso2 == Constant.countryUS }), let us = countries?[firstIndexUS] {
            countries?.remove(at: firstIndexUS)
            countries?.insert(us, at: 0)
        }
        
        return countries
    }
}

struct CountriesRequestData: RequestModelData {
    func getParameters() -> [String: Any] {
        return [
            "_locale": Locale.current.identifier
        ]
    }
}

class CountriesWorker: BaseApiWorker<CountriesMapper> {
    override func getUrl() -> String {
        return APIURLHandler.getUrl(KYCEndpoints.countriesList)
    }
    
    override func getParameters() -> [String: Any] {
        return requestData?.getParameters() ?? [:]
    }
    
    override func getMethod() -> HTTPMethod {
        return .get
    }
}
