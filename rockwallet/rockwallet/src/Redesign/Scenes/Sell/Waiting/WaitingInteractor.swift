//
//  WaitingInteractor.swift
//  breadwallet
//
//  Created by Dino Gacevic on 25/07/2023.
//
//

import UIKit

class WaitingInteractor: NSObject, Interactor, WaitingViewActions {
    typealias Models = WaitingModels

    var presenter: WaitingPresenter?
    var dataStore: WaitingStore?

    // MARK: - WaitingViewActions
    
    func updateSsn(viewAction: WaitingModels.UpdateSsn.ViewAction) {
        let request = UpdateSsnRequestData(ssn: dataStore?.ssn)
        UpdateSsnWorker().execute(requestData: request) { [weak self] result in
            switch result {
            case .success(let profile):
                UserManager.shared.profile = profile
                self?.presenter?.presentUpdateSsn(actionResponse: .init(error: nil))
                
            case .failure(let error):
                self?.presenter?.presentUpdateSsn(actionResponse: .init(error: error))
            }
        }
    }

    // MARK: - Aditional helpers
}
