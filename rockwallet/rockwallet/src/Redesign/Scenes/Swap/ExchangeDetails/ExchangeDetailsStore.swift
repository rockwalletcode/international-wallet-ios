//
//  ExchangeDetailsStore.swift
//  breadwallet
//
//  Created by Rok on 06/07/2022.
//
//

import UIKit

class ExchangeDetailsStore: NSObject, BaseDataStore, ExchangeDetailsDataStore {
    
    // MARK: - ExchangeDetailsDataStore
    
    var exchangeType: ExchangeType = .unknown
    var transactionPart: ExchangeDetail.SourceDestination.Part = .one
    var exchangeId: String?
    
    // MARK: - Additional helpers
}
