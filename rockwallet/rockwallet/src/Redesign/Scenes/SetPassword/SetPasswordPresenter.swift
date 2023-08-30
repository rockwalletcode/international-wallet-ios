//
//  SetPasswordPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class SetPasswordPresenter: NSObject, Presenter, SetPasswordActionResponses {
    
    typealias Models = SetPasswordModels
    
    weak var viewController: SetPasswordViewController?
    
    // MARK: - ProfileActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let sections: [Models.Section] =  [
            .password,
            .confirmPassword,
            .notice
        ]
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .password: [TextFieldModel(title: L10n.Account.enterPassword, value: item.password, showPasswordToggle: true)],
            .confirmPassword: [TextFieldModel(title: L10n.Account.confirmPassword, value: item.password, showPasswordToggle: true)],
            .notice: [LabelViewModel.text(L10n.Account.passwordRequirements)]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentValidate(actionResponse: SetPasswordModels.Validate.ActionResponse) {
        let isValid = actionResponse.isPasswordValid &&
        actionResponse.isPasswordAgainValid &&
        actionResponse.passwordsMatch
        
        let textColor = (actionResponse.passwordState == .error || actionResponse.passwordAgainState == .error) && !isValid ? Colors.Error.one : Colors.Text.two
        
        let noticeConfiguration = LabelConfiguration(font: Fonts.Body.three, textColor: textColor)
        
        viewController?.displayValidate(responseDisplay:
                .init(password: actionResponse.password,
                      passwordAgain: actionResponse.passwordAgain,
                      isPasswordValid: actionResponse.isPasswordValid,
                      isPasswordEmpty: actionResponse.isPasswordEmpty,
                      passwordModel: .init(title: L10n.Account.enterPassword,
                                           hint: !actionResponse.passwordsMatch && !actionResponse.isPasswordEmpty
                                           && !actionResponse.isPasswordAgainEmpty ? L10n.Account.passwordDoNotMatch : nil,
                                           displayState: actionResponse.passwordState,
                                           showPasswordToggle: true),
                      isPasswordAgainValid: actionResponse.isPasswordAgainValid,
                      isPasswordAgainEmpty: actionResponse.isPasswordAgainEmpty,
                      passwordAgainModel: .init(title: L10n.Account.confirmPassword,
                                                hint: !actionResponse.passwordsMatch && !actionResponse.isPasswordEmpty
                                                && !actionResponse.isPasswordAgainEmpty ? L10n.Account.passwordDoNotMatch : nil,
                                                displayState: actionResponse.passwordAgainState,
                                                showPasswordToggle: true),
                      noticeConfiguration: noticeConfiguration,
                      isValid: isValid))
    }
    
    func presentNext(actionResponse: SetPasswordModels.Next.ActionResponse) {
        viewController?.displayNext(responseDisplay: .init())
    }
    
    // MARK: - Additional Helpers
    
}
