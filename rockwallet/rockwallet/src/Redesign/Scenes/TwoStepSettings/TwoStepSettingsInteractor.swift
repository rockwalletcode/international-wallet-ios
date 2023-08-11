//
//  TwoStepSettingsInteractor.swift
//  breadwallet
//
//  Created by Dino Gacevic on 17/04/2023.
//
//

import UIKit

class TwoStepSettingsInteractor: NSObject, Interactor, TwoStepSettingsViewActions {
    typealias Models = TwoStepSettingsModels

    var presenter: TwoStepSettingsPresenter?
    var dataStore: TwoStepSettingsStore?
    
    private var requestData: TwoStepSettingsRequestData?
    
    // MARK: - TwoStepSettingsViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        requestData = TwoStepSettingsRequestData(method: .get)
        
        TwoStepSettingsWorker().execute(requestData: requestData) { [weak self] result in
            switch result {
            case .success(let data):
                self?.presenter?.presentData(actionResponse: .init(item: data))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func toggleSetting(viewAction: TwoStepSettingsModels.ToggleSetting.ViewAction) {
        requestData = TwoStepSettingsRequestData(method: .put,
                                                 sending: viewAction.sending,
                                                 buy: viewAction.buy)
        
        TwoStepSettingsWorker().execute(requestData: requestData) { [weak self] result in
            switch result {
            case .success:
                self?.getData(viewAction: .init())
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    // MARK: - Additional helpers
}
