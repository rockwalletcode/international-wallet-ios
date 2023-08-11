//
//  RecoveryKeyIntroModels.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 04/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum RecoveryKeyIntroModels {
    typealias Item = ()
    
    enum Section: Sectionable {
        case title
        case image
        case writePhrase
        case keepPhrasePrivate
        case storePhraseSecurely
        case tickbox
        
        var header: AccessoryType? { return nil }
        var footer: AccessoryType? { return nil }
    }
    
    struct Tickbox {
        struct ViewAction {
            var value: Bool
        }
        
        struct ActionResponse {
            var value: Bool
        }
        
        struct ResponseDisplay {
            var model: ButtonViewModel
        }
    }
}
