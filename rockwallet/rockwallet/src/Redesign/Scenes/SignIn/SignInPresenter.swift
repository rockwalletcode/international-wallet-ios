//
//  SignInPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 09/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class SignInPresenter: NSObject, Presenter, SignInActionResponses {
    
    typealias Models = SignInModels
    
    weak var viewController: SignInViewController?
    
    // MARK: - ProfileActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let sections: [Models.Section] =  [
            .email,
            .password,
            .forgotPassword,
            .termsDescription,
            .terms,
            .termsPro
        ]
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .email: [TextFieldModel(title: L10n.Account.enterEmail, value: item.email)],
            .password: [TextFieldModel(title: L10n.Account.enterPassword, value: item.password, showPasswordToggle: true)],
            .forgotPassword: [MultipleButtonsViewModel(buttons: [ButtonViewModel(title: L10n.Account.forgotPassword, isUnderlined: true)])],
            .termsDescription: [LabelViewModel.text(L10n.Account.termsDescription)],
            .terms: [LabelViewModel.attributedText(prepareTermsTickboxText(termsText: "・\(L10n.About.AppName.android)'s"))],
            .termsPro: [LabelViewModel.attributedText(prepareTermsTickboxText(termsText: "・\(L10n.Segment.rockWalletPro)'s"))]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentValidate(actionResponse: SignInModels.Validate.ActionResponse) {
        let isValid = actionResponse.isEmailValid &&
        actionResponse.isPasswordValid
        
        viewController?.displayValidate(responseDisplay:
                .init(email: actionResponse.email,
                      password: actionResponse.password,
                      isEmailValid: actionResponse.isEmailValid,
                      isEmailEmpty: actionResponse.isEmailEmpty,
                      emailModel: .init(title: L10n.Account.enterEmail,
                                        hint: actionResponse.emailState == .error ? L10n.Account.invalidEmail : nil,
                                        trailing: actionResponse.emailState == .error ? .image(Asset.warning.image.tinted(with: Colors.Error.one)) : nil,
                                        displayState: actionResponse.emailState),
                      isPasswordValid: actionResponse.isPasswordValid,
                      isPasswordEmpty: actionResponse.isPasswordEmpty,
                      passwordModel: .init(title: L10n.Account.enterPassword,
                                           displayState: actionResponse.passwordState,
                                           showPasswordToggle: true),
                      isValid: isValid))
    }
    
    func presentNext(actionResponse: SignInModels.Next.ActionResponse) {
        viewController?.displayNext(responseDisplay: .init())
    }
    
    // MARK: - Additional Helpers
    
    private func prepareTermsTickboxText(termsText: String) -> NSMutableAttributedString {
        let partOneAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: Colors.Text.two,
            NSAttributedString.Key.backgroundColor: UIColor.clear,
            NSAttributedString.Key.font: Fonts.Body.two]
        let partTwoAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: Colors.secondary,
            NSAttributedString.Key.backgroundColor: UIColor.clear,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.font: Fonts.Subtitle.two]
        
        let partOne = NSMutableAttributedString(string: termsText + " ", attributes: partOneAttributes)
        let partTwo = NSMutableAttributedString(string: L10n.About.terms, attributes: partTwoAttributes)
        let combined = NSMutableAttributedString()
        combined.append(partOne)
        combined.append(partTwo)
        
        return combined
    }
}
