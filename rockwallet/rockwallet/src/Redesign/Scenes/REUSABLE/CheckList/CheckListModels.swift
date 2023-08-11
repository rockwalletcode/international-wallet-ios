//
//  CheckListModels.swift
//  breadwallet
//
//  Created by Rok on 06/06/2022.
//
//

import UIKit

enum CheckListModels {
    
    enum Section: Sectionable {
        case title
        case checkmarks
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    enum VerificationResponse {
        case success
        case failure(BaseInfoModels.FailureReason)
    }
    
    enum VerificationInProgress {
        struct ViewAction { }
        struct ActionResponse {
            let status: VerificationResponse
        }
        struct ResponseDisplay {
            let status: VerificationResponse
        }
    }
}
