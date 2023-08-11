//
//  BackupCodesInteractor.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 23.3.23.
//
//

import UIKit

class BackupCodesInteractor: NSObject, Interactor, BackupCodesViewActions {
    typealias Models = BackupCodesModels

    var presenter: BackupCodesPresenter?
    var dataStore: BackupCodesStore?

    private var method: HTTPMethod = .get
    
    // MARK: - BackupCodesViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        let data = GetRecoveryCodesRequestData(method: method)
        GetRecoveryCodesWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let data):
                self?.presenter?.presentData(actionResponse: .init(item: data?.codes ?? []))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func getBackupCodes(viewAction: BackupCodesModels.BackupCodes.ViewAction) {
        method = viewAction.method
        
        getData(viewAction: .init())
    }
    
    func skipSaving(viewAction: BackupCodesModels.SkipBackupCodeSaving.ViewAction) {
        presenter?.presentSkipSaving(actionResponse: .init())
    }
    
    // MARK: - Additional helpers
}
