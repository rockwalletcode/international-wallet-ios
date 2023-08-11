//
//  FetchModels.swift
//  
//
//  Created by Rok Cresnik on 02/12/2021.
//

import UIKit

enum AccessoryType: Hashable {
    case plain(String)
    case attributed(NSAttributedString)
    case action(String)
    case advanced(UIImage?, String, String?)
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title.hashValue)
    }
    
    var title: String {
        switch self {
        case .attributed(let title):
            return title.string
            
        case .plain(let title),
                .action(let title),
                .advanced(_, let title, _):
            return title
        }
    }
}

protocol Sectionable: Hashable {
    var header: AccessoryType? { get }
    var footer: AccessoryType? { get }
}

enum FetchModels: Hashable {
    typealias Item = Any
    
    struct Get {
        struct ViewAction {
            init() {}
        }
        
        struct ActionResponse {
            let item: Any?
            
            init(item: Any?) {
                self.item = item
            }
        }
        
        struct ResponseDisplay {
            var sections: [AnyHashable]
            var sectionRows: [AnyHashable: [any Hashable]]
            
            init(sections: [AnyHashable],
                 sectionRows: [AnyHashable: [any Hashable]]) {
                self.sections = sections
                self.sectionRows = sectionRows
            }
        }
    }
}
