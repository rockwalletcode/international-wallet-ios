// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import Foundation

protocol ModelResponse: Codable {}

protocol Model {}

extension Array: Model {}

class ModelMapper<T: ModelResponse, U: Any>: Mapper {
    required public init() {}
    
    open func getModel(from response: T?) -> U? {
        return nil
    }
}
