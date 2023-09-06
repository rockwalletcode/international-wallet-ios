//
//  ProfilePresenter.swift
//  breadwallet
//
//  Created by Rok on 26/05/2022.
//
//

import UIKit

final class ProfilePresenter: NSObject, Presenter, ProfileActionResponses {
    
    typealias Models = ProfileModels

    weak var viewController: ProfileViewController?

    // MARK: - ProfileActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let profile = UserManager.shared.profile,
              let infoView: InfoViewModel = profile.status.viewModel else { return }
        
        let sections: [Models.Section] = [
            .profile,
            .verification,
            .navigation
        ]
        
        var navigationItems = Models.NavigationItems.allCases
        let navigationModel = navigationItems.compactMap { $0.model }
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .profile: [
                ProfileViewModel(name: profile.email, image: Asset.avatar.name)
            ],
            .verification: [
                infoView
            ],
            .navigation: navigationModel
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentVerificationInfo(actionResponse: ProfileModels.VerificationInfo.ActionResponse) {
        let title = actionResponse.verified ? L10n.Account.verifiedAccountTitle : L10n.Account.whyVerify
        let body = actionResponse.verified ? L10n.Account.verifiedAccountTextInternational : L10n.Account.verifyAccountTextInternational
        
        let model = PopupViewModel(title: .text(title),
                                   body: body)
        
        viewController?.displayVerificationInfo(responseDisplay: .init(model: model))
    }
    
    func presentNavigation(actionResponse: ProfileModels.Navigate.ActionResponse) {
        let item = Models.NavigationItems.allCases[actionResponse.index]
        viewController?.displayNavigation(responseDisplay: .init(item: item))
    }
    
    func presentLogout(actionResponse: ProfileModels.Logout.ActionResponse) {
        viewController?.displayMessage(responseDisplay: .init(model: .init(description: .text(L10n.Account.logoutMessage)),
                                                              config: Presets.InfoView.verification))
        
        viewController?.displayLogout(responseDisplay: .init())
    }
    
    // MARK: - Additional Helpers
    
}
