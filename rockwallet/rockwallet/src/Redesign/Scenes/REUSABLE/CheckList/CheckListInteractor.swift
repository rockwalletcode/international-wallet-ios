//
//  CheckListInteractor.swift
//  breadwallet
//
//  Created by Rok on 06/06/2022.
//
//

import UIKit

class CheckListInteractor: NSObject, Interactor, CheckListViewActions {
    typealias Models = CheckListModels

    var presenter: CheckListPresenter?
    var dataStore: CheckListStore?

    // MARK: - CheckListViewActions
    
    func checkVerificationProgress(viewAction: CheckListModels.VerificationInProgress.ViewAction) {
        UserManager.shared.refresh { [weak self] result in
            switch result {
            case .success(let profile):
                switch profile?.status {
                case .levelTwo(.levelTwo), .levelTwo(.kycWithSsn), .levelTwo(.kycWithoutSsn):
                    self?.presenter?.presentVerificationProgress(actionResponse: .init(status: .success))
                    
                case .levelTwo(.declined):
                    self?.presenter?.presentVerificationProgress(actionResponse: .init(status: .failure(.documentVerification)))
                    
                case .levelTwo(.resubmit):
                    self?.presenter?.presentVerificationProgress(actionResponse: .init(status: .failure(.documentVerificationRetry)))
                             
                default:
                    // waiting for verification, check every 30 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + Presets.Delay.repeatingAction.rawValue, execute: {
                        self?.checkVerificationProgress(viewAction: .init())
                    })
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                
                self?.presenter?.presentVerificationProgress(actionResponse: .init(status: .failure(.documentVerification)))
                
            default:
                return
            }
        }
    }

    // MARK: - Additional helpers
}
