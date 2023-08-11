// 
//  CopyValueModels.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 24.4.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

enum CopyValueModels {
    enum Copy {
        struct ViewAction {
            var value: String?
            var message: String?
        }
        struct ActionResponse {
            var message: String?
        }
        struct ResponseDisplay {}
    }
}
