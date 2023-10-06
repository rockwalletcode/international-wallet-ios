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
            .timer: [CountdownTimerViewModel(countdownTime: Constant.authorizeLoginTime, countdownTimeCritical: Constant.authorizeLoginTimeCritical)],
            .description: [InfoViewModel(title: .text("About this request"),
                                         description: .text("By confirming, you'll grant login access to the RockWallet web app"))],
            .data: [GroupedTitleValuesViewModel(models: [TitleValueViewModel(title: .text("Where"), value: .text(item.location)),
                                                         TitleValueViewModel(title: .text("Device"), value: .text(item.device)),
                                                         TitleValueViewModel(title: .text("IP"), value: .text(item.ipAddress))])]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentAuthorization(actionResponse: AuthorizeLoginModels.Authorize.ActionResponse) {
        viewController?.displayAuthorization(responseDisplay: .init(success: actionResponse.success))
    }

    // MARK: - Additional Helpers

}
