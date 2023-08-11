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
        
        let confirmationType = item.type
        let email = item.email ?? ""
        let emailString = ":\n\(email)"
        
        let sections: [Models.Section] = confirmationType.sections
        
        var help: [ButtonViewModel] = [ButtonViewModel(title: confirmationType.buttonTitle,
                                                       isUnderlined: true,
                                                       callback: viewController?.resendCodeTapped)]
        
        if UserManager.shared.profile?.status == .emailPending || confirmationType == .forgotPassword {
            help.append(ButtonViewModel(title: L10n.AccountCreation.changeEmail,
                                        isUnderlined: true,
                                        callback: viewController?.changeEmailTapped))
        }
        
        if confirmationType == .twoStepAppLogin || confirmationType == .twoStepAppResetPassword || confirmationType == .twoStepAppSendFunds
            || confirmationType == .twoStepAppBuy || confirmationType == .twoStepAppRequired {
            help = [ButtonViewModel(title: L10n.TwoStep.App.CantAccess.title,
                                    isUnderlined: true,
                                    callback: viewController?.enterBackupCode)]
        }
        
        if case .twoStepAppBackupCode = confirmationType {
            help.removeAll()
        }
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .image: [ImageViewModel.image(Asset.email.image)],
            .title: [LabelViewModel.text(confirmationType.title)],
            .instructions: [LabelViewModel.text(confirmationType.getInstructions(email: emailString))],
            .input: [TextFieldModel()],
            .help: [MultipleButtonsViewModel(buttons: help)]
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
    
    // MARK: - Additional Helpers

}
