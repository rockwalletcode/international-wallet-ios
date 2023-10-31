//
//  SignUpPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 10/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class SignUpPresenter: NSObject, Presenter, SignUpActionResponses {
    
    typealias Models = SignUpModels
    
    weak var viewController: SignUpViewController?
    
    // MARK: - ProfileActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        guard let termsAndConditionsURL = URL(string: Constant.termsAndConditions) else { return }
        
        let sections: [Models.Section] =  [
            .email,
            .password,
            .confirmPassword,
            .notice,
            .termsTickbox,
            .termsTickboxPro,
            .promotionsTickbox
        ]
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .email: [TextFieldModel(title: L10n.Account.enterEmail, value: item.email)],
            .password: [TextFieldModel(title: L10n.Account.createPassword, value: item.password, showPasswordToggle: true)],
            .confirmPassword: [TextFieldModel(title: L10n.Account.confirmPassword, value: item.password, showPasswordToggle: true)],
            .notice: [LabelViewModel.text(L10n.Account.passwordRequirements)],
            .termsTickbox: [TickboxItemViewModel(title: .attributedText(prepareTermsTickboxText(termsText: L10n.Account.termsTickbox)), url: termsAndConditionsURL)],
            .termsTickboxPro: [TickboxItemViewModel(title: .attributedText(prepareTermsTickboxText(termsText: "I agree to RockWallet PRO’s")), url: termsAndConditionsURL)],
            .promotionsTickbox: [TickboxItemViewModel(title: .text(L10n.Account.promotionsTickbox))]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentValidate(actionResponse: SignUpModels.Validate.ActionResponse) {
        let isValid = actionResponse.isEmailValid &&
        actionResponse.isPasswordValid &&
        actionResponse.isPasswordAgainValid &&
        actionResponse.passwordsMatch &&
        actionResponse.isTermsTickboxValid
        
        let textColor = (actionResponse.passwordState == .error || actionResponse.passwordAgainState == .error) && !isValid ? Colors.Error.one : Colors.Text.two
        
        let noticeConfiguration = LabelConfiguration(font: Fonts.Body.three, textColor: textColor)
        
        viewController?.displayValidate(responseDisplay:
                .init(email: actionResponse.email,
                      password: actionResponse.password,
                      passwordAgain: actionResponse.passwordAgain,
                      isEmailValid: actionResponse.isEmailValid,
                      isEmailEmpty: actionResponse.isEmailEmpty,
                      emailModel: .init(title: L10n.Account.enterEmail,
                                        hint: actionResponse.emailState == .error ? L10n.Account.invalidEmail : nil,
                                        trailing: actionResponse.emailState == .error ? .image(Asset.warning.image.tinted(with: Colors.Error.one)) : nil,
                                        displayState: actionResponse.emailState),
                      isPasswordValid: actionResponse.isPasswordValid,
                      isPasswordEmpty: actionResponse.isPasswordEmpty,
                      passwordModel: .init(title: L10n.Account.createPassword,
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
                      isTermsTickboxValid: actionResponse.isTermsTickboxValid,
                      noticeConfiguration: noticeConfiguration,
                      isValid: isValid))
    }
    
    func presentNext(actionResponse: SignUpModels.Next.ActionResponse) {
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
