//
//  MenuItem.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-04-01.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

struct MenuItem {
    
    enum Icon {
        static let scan = Asset.qr.image
        static let feedback = Asset.love.image
        static let wallet = Asset.wallet.image
        static let preferences = Asset.settings.image
        static let support = Asset.chat.image
        static let tellFriend = Asset.friend.image
        static let about = Asset.info.image
        static let atmMap = Asset.placemark.image
        static let export = Asset.withdrawal.image
        static let paymailAddress = Asset.paymailAddress.image
    }
    
    var title: String
    var subTitle: String?
    let icon: UIImage?
    var color: UIColor?
    let accessoryText: (() -> String)?
    let callback: () -> Void
    let faqButton: UIButton? = nil
    var shouldShow: () -> Bool = { return true }
    
    init(title: String, subTitle: String? = nil, icon: UIImage? = nil, color: UIColor? = nil, accessoryText: (() -> String)? = nil, callback: @escaping () -> Void) {
        self.title = title
        self.subTitle = subTitle
        self.icon = icon?.withRenderingMode(.alwaysTemplate)
        self.color = color
        self.accessoryText = accessoryText
        self.callback = callback
    }
    
    init(title: String, icon: UIImage? = nil, subMenu: [MenuItem], rootNav: RootNavigationController, faqButton: UIButton? = nil) {
        let subMenuVC = MenuViewController(items: subMenu, title: title, faqButton: faqButton)
        self.init(title: title, icon: icon, accessoryText: nil) {
            rootNav.pushViewController(subMenuVC, animated: true)
        }
    }
}
