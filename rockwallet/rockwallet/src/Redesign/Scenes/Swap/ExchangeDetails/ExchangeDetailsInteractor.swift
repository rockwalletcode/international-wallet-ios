//
//  ExchangeDetailsInteractor.swift
//  breadwallet
//
//  Created by Rok on 06/07/2022.
//
//

import UIKit

class ExchangeDetailsInteractor: NSObject, Interactor, ExchangeDetailsViewActions {
    typealias Models = ExchangeDetailsModels

    var presenter: ExchangeDetailsPresenter?
    var dataStore: ExchangeDetailsStore?
    
    // MARK: - ExchangeDetailsViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        let data = ExchangeDetailsRequestData(exchangeId: dataStore?.exchangeId ?? "")
        ExchangeDetailsWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let data):
                guard let data = data,
                      let part = self?.dataStore?.transactionPart else { return }
                
                let item = ExchangeDetailsModels.Item(detail: data, part: part)
                self?.presenter?.presentData(actionResponse: .init(item: item))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func showInfoPopup(viewAction: ExchangeDetailsModels.InfoPopup.ViewAction) {
        presenter?.presentInfoPopup(actionResponse: .init(isCardFee: viewAction.isCardFee))
    }
    
    // MARK: - Additional helpers
}
