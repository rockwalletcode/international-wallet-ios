// 
//  AssetSelectionDisplayable.swift
//  breadwallet
//
//  Created by Rok on 18/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation

protocol AssetSelectionDisplayable {
    func showAssetSelector(title: String,
                           currencies: [Currency]?,
                           supportedCurrencies: [String]?,
                           selected: ((Any?) -> Void)?)
    func isDisabledAsset(code: String?, supportedCurrencies: [String]?) -> Bool?
}

extension AssetSelectionDisplayable where Self: BaseCoordinator {
    func showAssetSelector(title: String,
                           currencies: [Currency]?,
                           supportedCurrencies: [String]?,
                           selected: ((Any?) -> Void)?) {
        let allCurrencies = Currencies.shared.currencies
        
        let supportedAssets = allCurrencies.filter { item in currencies?.contains(where: { $0.code.lowercased() == item.code }) ?? false }
        
        var data: [AssetViewModel]? = currencies?.compactMap {
            let currencyFormat = Constant.currencyFormat
            let topRightText = String(format: currencyFormat,
                                      ExchangeFormatter.current.string(for: $0.state?.balance?.tokenValue) ?? "",
                                      $0.code.uppercased())
            let bottomRightText = String(format: currencyFormat,
                                         ExchangeFormatter.fiat.string(for: $0.state?.balance?.fiatValue) ?? "",
                                         Constant.usdCurrencyCode)
            
            let isDisabledAsset = isDisabledAsset(code: $0.code, supportedCurrencies: supportedCurrencies) ?? false
            
            return AssetViewModel(icon: $0.imageSquareBackground,
                                  title: $0.name,
                                  subtitle: $0.code,
                                  topRightText: topRightText,
                                  bottomRightText: bottomRightText,
                                  isDisabled: isDisabledAsset)
        }
        
        let unsupportedAssets = supportedAssets.filter { item in !(data?.contains(where: { $0.subtitle?.lowercased() == item.code }) ?? false) }
        let disabledData: [AssetViewModel]? = unsupportedAssets.compactMap {
            return AssetViewModel(icon: $0.imageSquareBackground,
                                  title: $0.name,
                                  subtitle: $0.code.uppercased(),
                                  isDisabled: true)
        }
        
        data?.append(contentsOf: disabledData ?? [])
        
        let sortedCurrencies = data?.sorted { !$0.isDisabled && $1.isDisabled }
        
        openModally(coordinator: ExchangeCoordinator.self,
                    scene: Scenes.AssetSelection,
                    presentationStyle: .formSheet) { vc in
            vc?.dataStore?.items = sortedCurrencies ?? []
            vc?.dataStore?.sceneTitle = title
            vc?.itemSelected = selected
        }
    }
    
    func isDisabledAsset(code: String?, supportedCurrencies: [String]?) -> Bool? {
        guard let assetCode = code else { return false }
        
        return !(supportedCurrencies?.contains(where: { $0.lowercased() == assetCode.lowercased() }) ?? false)
    }
}
