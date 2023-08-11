//
//  SsnAdditionalInfoPresenter.swift
//  breadwallet
//
//  Created by Dino Gacevic on 24/07/2023.
//
//

import UIKit

final class SsnAdditionalInfoPresenter: NSObject, Presenter, SsnAdditionalInfoActionResponses {
    typealias Models = SsnAdditionalInfoModels

    weak var viewController: SsnAdditionalInfoViewController?

    // MARK: - SsnAdditionalInfoActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let ssn = actionResponse.item as? String
        
        let sections: [Models.Section] = [
            .ssn
        ]
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .ssn: [SsnInputViewModel(textFieldViewModel: .init(value: ssn, placeholder: L10n.Account.socialSecurityNumber))]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentValidateSsn(actionResponse: SsnAdditionalInfoModels.ValidateSsn.ActionResponse) {
        let inputViewModel = SsnInputViewModel(buttonViewModel: .init(title: L10n.Button.confirm, enabled: actionResponse.isValid))
        viewController?.displayValidateSsn(responseDisplay: .init(viewModel: inputViewModel))
    }
    
    func presentConfirmSsn(actionResponse: SsnAdditionalInfoModels.ConfirmSsn.ActinResponse) {
        viewController?.displayConfirmSsn(responseDisplay: .init(ssn: actionResponse.ssn))
    }
    
    func presentSsnError(actionResponse: SsnAdditionalInfoModels.SsnError.ActionResponse) {
        guard let error = actionResponse.error else { return }
        let inputViewModel = SsnInputViewModel(textFieldViewModel: .init(value: actionResponse.ssn,
                                                                         placeholder: L10n.Account.socialSecurityNumber,
                                                                         displayState: .error),
                                               buttonViewModel: .init(title: L10n.Button.confirm, enabled: false))
        viewController?.displayValidateSsn(responseDisplay: .init(viewModel: inputViewModel))
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(error)),
                                                              config: Presets.InfoView.error))
    }

    // MARK: - Additional Helpers

}
