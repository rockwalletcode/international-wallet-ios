// 
//  CopyTextIconGenerator.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 19/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct CopyTextIcon {
    static func generate(with value: String, isCopyable: Bool) -> NSAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = Asset.copy.image.withRenderingMode(.alwaysOriginal)
        imageAttachment.bounds = CGRect(x: 0,
                                        y: -Margins.extraSmall.rawValue,
                                        width: ViewSizes.extraSmall.rawValue,
                                        height: ViewSizes.extraSmall.rawValue)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: "")
        completeText.append(NSAttributedString(string: value))
        
        if isCopyable {
            completeText.append(NSAttributedString(string: "  "))
            completeText.append(attachmentString)
        }
        
        return completeText
    }
}
