// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import Foundation

struct PlainResponseData: ModelResponse {}
struct PlainResponse: Model {}

class PlainMapper: Mapper {
    required init() {}
    
    func getModel(from response: PlainResponseData?) -> Bool? {
        return response != nil
    }
}
