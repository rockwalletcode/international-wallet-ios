// 
//  FeeFetchable.swift
//  breadwallet
//
//  Created by Rok on 01/09/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import WalletKit

protocol FeeFetchable {
    func fetchWalletKitFee(for amount: Amount,
                           with sender: Sender,
                           address: String,
                           completion: @escaping ((TransferFeeBasis?) -> Void))
}

extension FeeFetchable {
    func fetchWalletKitFee(for amount: Amount,
                           with sender: Sender,
                           address: String,
                           completion: @escaping ((TransferFeeBasis?) -> Void)) {
        sender.estimateFee(address: address,
                           amount: amount,
                           tier: .priority,
                           isStake: false) { result in
            switch result {
            case .success(let fee):
                completion(fee)
                
            case .failure(let error):
                debugPrint(error)
                
                completion(nil)
            }
        }
    }
}
