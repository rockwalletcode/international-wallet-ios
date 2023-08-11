// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import Foundation

enum KYCEndpoints: String, URLType {
    static var baseURL: String = "https://" + E.apiUrl + "blocksatoshi/one/kyc/%@"
    
    case countriesList = "countries"
    case userInformation = "user-information"
    case updateSsn = "ssn"
    
    var url: String {
        return String(format: Self.baseURL, rawValue)
    }
}
