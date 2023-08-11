//
//  SsnAdditionalInfoModels.swift
//  breadwallet
//
//  Created by Dino Gacevic on 24/07/2023.
//
//

import UIKit

enum SsnAdditionalInfoModels {
    typealias Item = (String?)
    
    enum Section: Sectionable {
        case ssn
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct ValidateSsn {
        struct ViewAction {
            let value: String?
        }
        struct ActionResponse {
            let isValid: Bool
        }
        struct ResponseDisplay {
            let viewModel: SsnInputViewModel
        }
    }
    
    struct ConfirmSsn {
        struct ViewAction {}
        struct ActinResponse {
            let ssn: String?
        }
        struct ResponseDisplay {
            let ssn: String?
        }
    }
    
    struct SsnError {
        struct ViewAction {
            let error: String?
        }
        struct ActionResponse {
            let ssn: String?
            let error: String?
        }
    }
}
