//
//  BaseInfoInteractor.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 13.7.22.
//
//

import UIKit

class BaseInfoInteractor: NSObject, Interactor, BaseInfoViewActions {
    
    typealias Models = BaseInfoModels

    var presenter: BaseInfoPresenter?
    var dataStore: BaseInfoStore?
    
    // MARK: - SwapInfoViewActions
    func getData(viewAction: FetchModels.Get.ViewAction) {
        presenter?.presentData(actionResponse: .init(item: nil))
    }
    
    func getAssetSelectionData(viewModel: BaseInfoModels.Assets.ViewAction) {
        let currencies = SupportedCurrenciesManager.shared.supportedCurrencies(type: viewModel.type)
        presenter?.presentAssetSelectionData(actionResponse: .init(supportedCurrencies: currencies))
    }

    // MARK: - Additional helpers
}
