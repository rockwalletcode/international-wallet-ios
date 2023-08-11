//
//  BackupCodesModels.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 23.3.23.
//
//

import UIKit

enum BackupCodesModels {
    typealias Item = ([String])
    
    enum Section: Sectionable {
        case instructions
        case backupCodes
        case getNewCodes
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct BackupCodes {
        struct ViewAction {
            var method: HTTPMethod
        }
    }
    
    struct SkipBackupCodeSaving {
        struct ViewAction {}
        
        struct ActionResponse {}
        
        struct ResponseDisplay {
            var popupViewModel: PopupViewModel
            var popupConfig: PopupConfiguration
        }
    }
}
