//
//  SetPasswordPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 10/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

protocol Resolvable {
    init?(address: String)
    
    var type: ResolvableType { get }
    
    func fetchAddress(forCurrency currency: Currency, callback: @escaping (Result<String?, Error>) -> Void)
}

enum ResolvableType {
    case paymail
    
    var label: String {
        switch self {
        case .paymail:
            return "Paymail"
        }
    }
    
    var iconName: String? {
        switch self {
        case .paymail:
            return nil
        }
    }
}

struct ResolvedAddress {
    let humanReadableAddress: String
    let cryptoAddress: String
    let label: String
    let type: ResolvableType
}

enum ResolvableFactory {
    static func resolver(_ address: String) -> Resolvable? {
        if let paymail = Paymail(address: address) {
            return paymail
        }
        
        return nil
    }
}

private class Paymail: Resolvable {
    private let address: String
    
    let type: ResolvableType = .paymail
    
    required init?(address: String) {
        self.address = address
        guard isValidAddress(address) else { return nil }
    }
    
    func fetchAddress(forCurrency currency: Currency, callback: @escaping (Result<String?, Error>) -> Void) {
        guard currency.isBitcoinSV else {
            callback(.failure(GeneralError(errorMessage: ""))) // TODO: Do we need to show error in this case?
            return
        }
        
        PaymailDestinationWorker().execute(requestData: PaymailDestinationRequestData(address: address)) { result in
            switch result {
            case .success(let data):
                callback(.success((data?.output ?? "")))
                
            case .failure:
                callback(.failure(GeneralError(errorMessage: L10n.ErrorMessages.invalidPaymailBSVAddress)))
            }
        }
    }
    
    private func isValidAddress(_ address: String) -> Bool {
        let pattern = ".+\\@.+"
        let range = address.range(of: pattern, options: .regularExpression)
        return range != nil
    }
}
