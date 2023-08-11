// 
//  SuccessViewController.swift
//  breadwallet
//
//  Created by Rok on 12/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let Success = SuccessViewController.self
}

class SuccessViewController: BaseInfoViewController {
    var reason: BaseInfoModels.SuccessReason? {
        didSet {
            prepareData()
        }
    }
    
    var exchangeType: ExchangeType = .unknown
    let canUseAch = UserManager.shared.profile?.kycAccessRights.hasAchAccess ?? false
    
    override var imageName: String? { return reason?.iconName }
    override var titleText: String? { return reason?.title }
    override var descriptionText: String? { return reason?.description }
    override var buttonViewModels: [ButtonViewModel] {
        var buttons: [ButtonViewModel] = [
            .init(title: reason?.firstButtonTitle, callback: { [weak self] in
                self?.shouldDismiss = true
                
                self?.didTapMainButton?()
            }),
            .init(title: reason?.secondButtonTitle, isUnderlined: reason?.secondButtonUnderlined ?? true, callback: { [weak self] in
                self?.shouldDismiss = true
                
                self?.didTapSecondaryButton?()
                
            }),
            .init(title: reason?.thirdButtonTitle, isUnderlined: reason?.thirdButtoUnderlined ?? true, callback: { [weak self] in
                self?.shouldDismiss = true
                
                self?.didTapThirdButton?()
            })
        ]
        
        buttons.removeAll(where: { $0.title == nil })
        
        return buttons
    }
    
    override var buttonConfigurations: [ButtonConfiguration] {
        let buttons = [Presets.Button.primary,
                       reason?.secondButtonConfig ?? Presets.Button.noBorders,
                       reason?.thirdButtonConfig ?? Presets.Button.noBorders]
        
        return buttons
    }
    
    override func displayAssetSelectionData(responseDisplay: BaseInfoModels.Assets.ResponseDisplay) {
        LoadingView.hideIfNeeded()
        
        guard let coordinator = coordinator as? ExchangeCoordinator else { return }
        
        coordinator.showAssetSelector(title: responseDisplay.title ?? "",
                                                            currencies: responseDisplay.currencies,
                                      supportedCurrencies: responseDisplay.supportedCurrencies) { [weak self] selectedCurrency in
            guard let model = selectedCurrency as? AssetViewModel,
                  let currency = Store.state.currencies.first(where: { $0.code == model.subtitle }) else { return }
            
            self?.coordinator?.dismissFlow()
            
            let wallet = Store.state.wallets[currency.uid]?.wallet
            let accountViewController = AssetDetailsViewController(currency: currency, wallet: wallet)
            coordinator.navigationController.pushViewController(accountViewController, animated: true)
        }
    }
}
