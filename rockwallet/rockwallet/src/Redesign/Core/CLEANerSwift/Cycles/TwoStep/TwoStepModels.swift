// 
//  TwoStepModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 18/05/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum TwoStepModels {
    struct NextFailure {
        struct ViewAction {
            var registrationRequestData: RegistrationRequestData?
            var setPasswordRequestData: SetPasswordRequestData?
            let error: Error?
        }
        
        struct ActionResponse {
            let reason: NetworkingError
            var registrationRequestData: RegistrationRequestData?
            var setPasswordRequestData: SetPasswordRequestData?
        }
        struct ResponseDisplay {
            let reason: NetworkingError
            var registrationRequestData: RegistrationRequestData?
            var setPasswordRequestData: SetPasswordRequestData?
        }
    }
}
