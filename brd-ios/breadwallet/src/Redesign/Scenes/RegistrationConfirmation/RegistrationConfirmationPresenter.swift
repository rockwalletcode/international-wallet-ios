//
//  RegistrationConfirmationPresenter.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

final class RegistrationConfirmationPresenter: NSObject, Presenter, RegistrationConfirmationActionResponses {
    typealias Models = RegistrationConfirmationModels

    weak var viewController: RegistrationConfirmationViewController?

    // MARK: - RegistrationConfirmationActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let email = item.email
        let confirmationType = item.confirmationType
        
        var sections: [Models.Section] = [
            .image,
            .title,
            .instructions,
            .input,
            .help
        ]
        
        if confirmationType == .twoStep {
            sections = sections.filter({ $0 != .image })
        }
        
        let title = confirmationType == .twoStep ? "We’ve sent you an SMS" : L10n.AccountCreation.verifyEmail
        let instructions = confirmationType == .twoStep ? "Enter the security code we’ve sent to:" : "\(L10n.AccountCreation.enterCode)\(": \n")\(email ?? "")"
        var help: [ButtonViewModel] = [ButtonViewModel(title: L10n.AccountCreation.resendCode,
                                                       isUnderlined: true,
                                                       shouldTemporarilyDisableAfterTap: confirmationType == .twoStep)]
        
        if UserManager.shared.profile?.status == .emailPending {
            help.append(ButtonViewModel(title: L10n.AccountCreation.changeEmail, isUnderlined: true))
        }
        
        if confirmationType == .twoStep {
            help.append(ButtonViewModel(title: "Change my phone number", isUnderlined: true))
        }
        
        let sectionRows: [Models.Section: [Any]] = [
            .image: [
                ImageViewModel.image(Asset.email.image)
            ],
            .title: [
                LabelViewModel.text(title)
            ],
            .instructions: [
                LabelViewModel.text(instructions)
            ],
            .input: [
                TextFieldModel()
            ],
            .help: [
                MultipleButtonsViewModel(buttons: help)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentConfirm(actionResponse: RegistrationConfirmationModels.Confirm.ActionResponse) {
        viewController?.displayConfirm(responseDisplay: .init())
    }
    
    func presentResend(actionResponse: RegistrationConfirmationModels.Resend.ActionResponse) {
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(L10n.AccountCreation.codeSent)),
                                                              config: Presets.InfoView.verification))
    }
    
    func presentError(actionResponse: RegistrationConfirmationModels.Error.ActionResponse) {
        viewController?.displayError(responseDisplay: .init())
    }
    
    // MARK: - Additional Helpers

}
