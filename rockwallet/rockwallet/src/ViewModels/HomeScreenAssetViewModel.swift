//
//  HomeScreenAssetViewModel.swift
//  breadwallet
//
//  Created by Ehsan Rezaie on 2018-01-31.
//  Copyright © 2018-2019 Breadwinner AG. All rights reserved.
//

import Foundation

struct HomeScreenAssetViewModel {
    let currency: Currency
    let proBalancesData: ProBalancesModel?
    
    var exchangeRate: String {
        return currency.state?.currentRate?.localString(forCurrency: currency, usesCustomFormat: true) ?? ""
    }
    
    var fiatBalance: String {
        guard let balance = currency.state?.balance,
            let rate = currency.state?.currentRate
            else { return "" }
        
        return Amount(amount: balance, rate: rate).fiatDescription
    }
    
    var tokenBalance: String {
        guard let balance = currency.state?.balance,
              let text = ExchangeFormatter.current.string(for: balance.tokenValue)
        else { return "" }
        
        return text
    }
    
    var fiatBalancePro: String {
        guard let rate = currency.state?.currentRate else { return "" }
        
        let currencyPro = Store.state.currenciesProWallet.first(where: { $0.code == currency.code })
        let proBalance = proBalancesData?.getProBalance(code: currencyPro?.code ?? "") ?? 0
        let balance = Amount(decimalAmount: proBalance, isFiat: true, currency: currency)
        
        return Amount(amount: balance, rate: rate).fiatDescription
    }
    
    var tokenBalancePro: String {
        let currencyPro = Store.state.currenciesProWallet.first(where: { $0.code == currency.code })
        let balance = proBalancesData?.getProBalance(code: currencyPro?.code ?? "") ?? 0
        
        return ExchangeFormatter.current.string(for: balance) ?? ""
    }
}
