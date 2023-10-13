//
//  AuthorizeLoginPresenter.swift
//  rockwallet
//
//  Created by Dino Gačević on 05/10/2023.
//
//

import UIKit

final class AuthorizeLoginPresenter: NSObject, Presenter, AuthorizeLoginActionResponses {
    typealias Models = AuthorizeLoginModels

    weak var viewController: AuthorizeLoginViewController?

    // MARK: - AuthorizeLoginActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let sections: [Models.Section] = [.timer, .description, .data]
        let sectionRows: [Models.Section: [any Hashable]] = [
            .timer: [CountdownTimerViewModel(countdownTime: item.countdownTime ?? Constant.authorizeLoginTime,
                                             countdownTimeCritical: Constant.authorizeLoginTimeCritical)],
            .description: [InfoViewModel(title: .text(L10n.Account.AuthorizeLogin.Info.title),
                                         description: .text(L10n.Account.AuthorizeLogin.Info.description))],
            .data: [GroupedTitleValuesViewModel(models: [TitleValueViewModel(title: .text(L10n.Account.AuthorizeLogin.where),
                                                                             value: .text(item.location)),
                                                         TitleValueViewModel(title: .text(L10n.Account.AuthorizeLogin.device),
                                                                             value: .text(item.device)),
                                                         TitleValueViewModel(title: .text(L10n.Account.AuthorizeLogin.ip), 
                                                                             value: .text(item.ipAddress))])]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentAuthorization(actionResponse: AuthorizeLoginModels.Authorize.ActionResponse) {
        viewController?.displayAuthorization(responseDisplay: .init(success: actionResponse.success))
    }
    
    func presentRejection(actionResponse: AuthorizeLoginModels.Reject.ActionResponse) {
        viewController?.displayRejection(responseDisplay: .init(success: actionResponse.success))
    }

    // MARK: - Additional Helpers

}
