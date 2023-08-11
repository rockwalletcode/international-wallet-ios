//
//  KYCAddressModels.swift
//  breadwallet
//
//  Created by Rok on 06/01/2023.
//
//

import UIKit

enum KYCAddressModels {
    typealias Item = KYCAddressStore
    
    enum Section: Sectionable {
        case mandatory
        case address
        case cityAndState
        case postalCode
        case country
        case ssn
        case ssnInfo
        case confirm
        
        var header: AccessoryType? { nil }
        var footer: AccessoryType? { nil }
    }
    
    struct FormUpdated {
        struct ViewAction {
            var section: AnyHashable
            var value: Any?
        }
        
        struct ActionResponse {
            var isValid: Bool?
        }
        
        struct ResponseDisplay {
            var isValid: Bool
        }
    }
    
    struct ExternalKYC {
        struct ViewAction {}
        
        struct ActionResponse {}
        
        struct ResponseDisplay {}
    }
    
    enum Submit {
        struct ViewAction {}
    }
        
    struct SsnInfo {
        struct ViewAction {}
        struct ActionResponse {}
        struct ResponseDisplay {
            var model: PopupViewModel
        }
    }
    
    struct Address {
        struct ViewAction {
            var address: ResidentialAddress
        }
    }
    
    struct Validate {
        struct ViewAction {}
    }
}
