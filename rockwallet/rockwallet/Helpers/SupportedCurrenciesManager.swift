// 
//  SupportedCurrenciesManager.swift
//  breadwallet
//
//  Created by Dino Gacevic on 24/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

class SupportedCurrenciesManager {
    static let shared = SupportedCurrenciesManager()
    
    private var generalSupportedCurrencies: [String] = []
    private var achSupportedCurrencies: [String] = []
    
    func fetchSupportedCurrencies(completion: (() -> Void)?) {
        SupportedCurrenciesWorker().execute { [weak self] result in
            switch result {
            case .success(let currencies):
                self?.generalSupportedCurrencies = currencies?.supportedCurrencies ?? []
                self?.achSupportedCurrencies = currencies?.achSupportedCurrencies ?? []
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            completion?()
        }
    }
    
    func isSupported(currency code: String, type: PaymentCard.PaymentType) -> Bool {
        let currencies = supportedCurrencies(type: type)
        return currencies.contains(where: { $0.lowercased() == code.lowercased() })
    }
    
    func isSupported(currency code: String) -> Bool {
        let currencies = generalSupportedCurrencies + achSupportedCurrencies
        return currencies.contains(where: { $0.lowercased() == code.lowercased() })
    }
    
    func supportedCurrencies(type: PaymentCard.PaymentType) -> [String] {
        let currencies = type == .card ? generalSupportedCurrencies : achSupportedCurrencies
        return currencies
    }
}
