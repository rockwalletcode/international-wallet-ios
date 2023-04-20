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
        guard let confirmationType = actionResponse.item as? Models.Item else { return }
        
        let email = "\(": \n")\(UserDefaults.email ?? "")"
        
        var sections: [Models.Section] = [
            .image,
            .title,
            .instructions,
            .input,
            .help
        ]
        
        if confirmationType == .twoStepApp {
            sections = sections.filter({ $0 != .image })
            sections = sections.filter({ $0 != .instructions })
            sections = sections.filter({ $0 != .help })
        }
        
        if confirmationType == .twoStepAppLogin {
            sections = sections.filter({ $0 != .image })
            sections = sections.filter({ $0 != .instructions })
        }
        
        if confirmationType == .enterAppBackupCode {
            sections = sections.filter({ $0 != .image })
        }
        
        let title: String
        let instructions: String
        
        switch confirmationType {
        case .account, .acountTwoStepEmailSettings, .acountTwoStepAppSettings:
            title = L10n.AccountCreation.verifyEmail
            instructions = "\(L10n.AccountCreation.enterCode)\(email)"
            
        case .twoStepEmail, .twoStepEmailLogin, .disable:
            title = "We’ve sent you a code"
            instructions = "\(L10n.AccountCreation.enterCode)\(email)"
            
        case .twoStepApp, .twoStepAppLogin:
            title = "Enter one of your backup codes"
            instructions = ""
        
        case .enterAppBackupCode:
            title = "Enter the code from your Authenticator app"
            instructions = "Confirm you’ve stored your backup codes securely by entering one of them."
            
        }
        
        var help: [ButtonViewModel] = [ButtonViewModel(title: L10n.AccountCreation.resendCode,
                                                       isUnderlined: true,
                                                       callback: viewController?.resendCodeTapped)]
        
        if UserManager.shared.profile?.status == .emailPending {
            help.append(ButtonViewModel(title: L10n.AccountCreation.changeEmail,
                                        isUnderlined: true,
                                        callback: viewController?.changeEmailTapped))
        }
        
        if confirmationType == .twoStepAppLogin {
            help = [ButtonViewModel(title: "I can’t access my Authenticator App",
                                    isUnderlined: true,
                                    callback: viewController?.enterBackupCode)]
        }
        
        if confirmationType == .enterAppBackupCode {
            help.removeAll()
        }
        
        let sectionRows: [Models.Section: [any Hashable]] = [
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
    
    func presentNextFailure(actionResponse: RegistrationConfirmationModels.NextFailure.ActionResponse) {
        viewController?.displayNextFailure(responseDisplay: .init(reason: actionResponse.reason,
                                                                  registrationRequestData: actionResponse.registrationRequestData))
    }
    
    // MARK: - Additional Helpers

}
