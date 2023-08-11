//
//  CheckListPresenter.swift
//  breadwallet
//
//  Created by Rok on 06/06/2022.
//
//

import UIKit

final class CheckListPresenter: NSObject, Presenter, CheckListActionResponses {
    typealias Models = CheckListModels

    weak var viewController: CheckListViewController?

    // MARK: - CheckListActionResponses

    func presentVerificationProgress(actionResponse: CheckListModels.VerificationInProgress.ActionResponse) {
        viewController?.displayVerificationProgress(responseDisplay: .init(status: actionResponse.status))
    }
    
    // MARK: - Additional Helpers

}
