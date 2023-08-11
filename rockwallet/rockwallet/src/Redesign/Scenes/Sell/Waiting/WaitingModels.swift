//
//  WaitingModels.swift
//  breadwallet
//
//  Created by Dino Gacevic on 25/07/2023.
//
//

import UIKit

enum WaitingModels {
    struct UpdateSsn {
        struct ViewAction {}
        struct ActionResponse {
            let error: Error?
        }
        struct ResponseDisplay {
            let error: String?
        }
    }
}
