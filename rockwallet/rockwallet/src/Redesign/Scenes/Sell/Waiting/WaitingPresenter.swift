//
//  WaitingPresenter.swift
//  breadwallet
//
//  Created by Dino Gacevic on 25/07/2023.
//
//

import UIKit

final class WaitingPresenter: NSObject, Presenter, WaitingActionResponses {
    typealias Models = WaitingModels

    weak var viewController: WaitingViewController?

    // MARK: - WaitingActionResponses
    
    func presentUpdateSsn(actionResponse: WaitingModels.UpdateSsn.ActionResponse) {
        viewController?.displayUpdateSsn(responseDisplay: .init(error: actionResponse.error?.localizedDescription))
    }

    // MARK: - Additional Helpers

}
