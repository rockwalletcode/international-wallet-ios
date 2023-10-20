//
//  AuthorizeLoginModels.swift
//  rockwallet
//
//  Created by Dino Gačević on 05/10/2023.
//
//

import UIKit

enum AuthorizeLoginModels {
    typealias Item = (countdownTime: TimeInterval?, location: String?, device: String?, ipAddress: String?)
    
    enum Section: Sectionable {
        case timer
        case description
        case data
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Authorize {
        struct ViewAction { }
        struct ActionResponse {
            var success: Bool
        }
        struct ResponseDisplay {
            var success: Bool
        }
    }
    
    struct Reject {
        struct ViewAction { }
        struct ActionResponse {
            var success: Bool
        }
        struct ResponseDisplay {
            var success: Bool
        }
    }
}
