// 
//  WithdrawalFixedFees.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 16.11.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

struct WithdrawalFixedFeesResponseData: ModelResponse {
    var fees: Fees?
    
    struct Fees: ModelResponse {
        var eth: Decimal?
        var btc: Decimal?
        var usdc: Decimal?
        var bsv: Decimal?
    }
}

struct WithdrawalFixedFees: Model {
    var fees: Fees
    
    struct Fees: Model {
        var eth: Decimal
        var btc: Decimal
        var usdc: Decimal
        var bsv: Decimal
    }
    
    func getFixedFees(code: String) -> Decimal? {
        switch code {
        case Constant.BSV:
            return fees.bsv
            
        case Constant.ETH:
            return fees.eth
            
        case Constant.BTC:
            return fees.btc
            
        case Constant.USDC:
            return fees.usdc
            
        default:
            return nil
        }
    }
}

class WithdrawalFixedFeesWorkerMapper: ModelMapper<WithdrawalFixedFeesResponseData, WithdrawalFixedFees> {
    override func getModel(from response: WithdrawalFixedFeesResponseData?) -> WithdrawalFixedFees {
        let fees = WithdrawalFixedFees.Fees(eth: response?.fees?.eth ?? 0,
                                            btc: response?.fees?.btc ?? 0,
                                            usdc: response?.fees?.usdc ?? 0,
                                            bsv: response?.fees?.bsv ?? 0)
        
        return WithdrawalFixedFees(fees: fees)
    }
}

class WithdrawalFixedFeesWorker: BaseApiWorker<WithdrawalFixedFeesWorkerMapper> {
    override func getUrl() -> String {
        return ProEndpoints.withdrawalFixedFees.url
    }
}
