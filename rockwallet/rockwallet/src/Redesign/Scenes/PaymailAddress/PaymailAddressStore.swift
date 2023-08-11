//
//  PaymailAddressStore.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.4.23.
//
//

import UIKit

class PaymailAddressStore: NSObject, BaseDataStore, PaymailAddressDataStore {
    // MARK: - PaymailAddressDataStore
    
    var screenType: PaymailAddressModels.ScreenType?
    var paymailAddress: String?
    var isPaymailFromAssets: Bool = false

    // MARK: - Additional helpers
}
