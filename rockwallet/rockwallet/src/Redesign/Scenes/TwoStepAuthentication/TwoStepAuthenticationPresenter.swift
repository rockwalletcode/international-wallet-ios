//
//  TwoStepAuthenticationPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 27/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class TwoStepAuthenticationPresenter: NSObject, Presenter, TwoStepAuthenticationActionResponses {
    typealias Models = TwoStepAuthenticationModels
    
    weak var viewController: TwoStepAuthenticationViewController?
    
    // MARK: - TwoStepAuthenticationActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let authType = actionResponse.item as? TwoStepSettingsResponseData.TwoStepType?
        
        var sections: [Models.Section] = [
            .email,
            .app
        ]
        
        let authExists = actionResponse.item != nil
        
        if authExists {
            sections.insert(.instructions, at: 0)
            sections.append(contentsOf: [.emptySection, .backupCodes, .settings, .disable])
        }
        
        var authMethodDescription: String?
        if authType == .email {
            authMethodDescription = L10n.TwoStep.Method.Email.description
            
            sections.removeAll(where: { $0 == .backupCodes })
        } else if authType == .authenticator {
            authMethodDescription = L10n.TwoStep.Method.App.description
        }
        
        let isTwoStepEnabled = authExists ? LabelViewModel.text(authMethodDescription) : nil
        let emailAuthCheckmark = authType == .email ? Asset.radiobuttonSelected.image : Asset.radiobutton.image
        let appAuthCheckmark = authType == .authenticator ? Asset.radiobuttonSelected.image : Asset.radiobutton.image
        let settingsChevron = Asset.chevronRight.image.tinted(with: Colors.Text.three)
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .instructions: [
                isTwoStepEnabled
            ],
            .email: [
                IconTitleSubtitleToggleViewModel(icon: .image(Asset.mail.image),
                                                 title: .text(L10n.Account.EmailAddress.title),
                                                 subtitle: .text(UserDefaults.email ?? ""),
                                                 checkmark: .image(emailAuthCheckmark),
                                                 isInteractable: authType != .email)
            ],
            .app: [
                IconTitleSubtitleToggleViewModel(icon: .image(Asset.phone.image),
                                                 title: .text(L10n.TwoStep.Methods.AuthApp.title),
                                                 checkmark: .image(appAuthCheckmark),
                                                 isInteractable: authType != .authenticator)
            ],
            .emptySection: [EmptyViewModel()],
            .backupCodes: [
                IconTitleSubtitleToggleViewModel(title: .text(L10n.BackupCodes.title),
                                                 checkmark: .image(settingsChevron))
            ],
            .settings: [
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.AuthSettings.title),
                                                 checkmark: .image(settingsChevron))
            ],
            .disable: [
                IconTitleSubtitleToggleViewModel(title: .text(L10n.TwoStep.Disable.title),
                                                 isDestructive: true)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentChangeMethod(actionResponse: TwoStepAuthenticationModels.ChangeMethod.ActionResponse) {
        viewController?.displayChangeMethod(responseDisplay: .init(indexPath: actionResponse.indexPath))
    }
    
    // MARK: - Additional Helpers
    
}
