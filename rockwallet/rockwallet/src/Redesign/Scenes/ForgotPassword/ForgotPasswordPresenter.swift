//
//  ForgotPasswordPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class ForgotPasswordPresenter: NSObject, Presenter, ForgotPasswordActionResponses {
    
    typealias Models = ForgotPasswordModels
    
    weak var viewController: ForgotPasswordViewController?
    
    // MARK: - ProfileActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let value = actionResponse.item as? String else { return }
        
        let sections: [Models.Section] =  [
            .notice,
            .email
        ]
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .email: [TextFieldModel(title: L10n.Account.email, value: value)],
            .notice: [LabelViewModel.text(L10n.Account.resetPasswordMessage)]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentValidate(actionResponse: ForgotPasswordModels.Validate.ActionResponse) {
        let isValid = actionResponse.isEmailValid
        
        viewController?.displayValidate(responseDisplay:
                .init(email: actionResponse.email,
                      isEmailValid: actionResponse.isEmailValid,
                      isEmailEmpty: actionResponse.isEmailEmpty,
                      emailModel: .init(title: L10n.Account.email,
                                        hint: actionResponse.emailState == .error ? L10n.Account.invalidEmail : nil,
                                        trailing: actionResponse.emailState == .error ? .image(Asset.warning.image.tinted(with: Colors.Error.one)) : nil,
                                        displayState: actionResponse.emailState),
                      isValid: isValid))
    }
    
    func presentNext(actionResponse: ForgotPasswordModels.Next.ActionResponse) {
        viewController?.displayNext(responseDisplay: .init())
    }
    
    // MARK: - Additional Helpers
    
}
