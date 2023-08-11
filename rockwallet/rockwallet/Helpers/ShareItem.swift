// 
//  ShareItem.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 10.4.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import LinkPresentation

class ShareItem: NSObject, UIActivityItemSource {
    var title: String
    var shareText: String
    
    init(title: String, shareText: String) {
        self.title = title
        self.shareText = shareText
        
        super.init()
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return shareText
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return shareText
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.originalURL = URL(string: shareText)
        return metadata
    }
}
