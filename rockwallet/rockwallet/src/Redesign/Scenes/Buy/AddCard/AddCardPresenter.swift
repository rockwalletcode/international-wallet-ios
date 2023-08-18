//
//  AddCardPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 03/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class AddCardPresenter: NSObject, Presenter, AddCardActionResponses {
    typealias Models = AddCardModels

    weak var viewController: AddCardViewController?

    // MARK: - AddCardActionResponses
    
    private var bankCardInputDetailsViewModel: BankCardInputDetailsViewModel = .init()
    
    // MARK: - Additional Helpers
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let sections: [Models.Section] = [
            .notificationPrompt,
            .cardDetails,
            .button
        ]
        
        let bannerModel = item.fromCardWithdrawal ? prepareCardWithdrawalBanner() : LabelViewModel.text(L10n.Buy.addCardPrompt)
        let addCardNotificationModel = InfoViewModel(description: bannerModel, dismissType: .persistent)
        
        bankCardInputDetailsViewModel = BankCardInputDetailsViewModel(number: .init(leading: .image(Asset.card.image),
                                                                                    title: L10n.Buy.cardNumber,
                                                                                    value: item.cardNumber),
                                                                      expiration: .init(title: L10n.Buy.monthYear,
                                                                                        value: item.cardExpDateString,
                                                                                        isUserInteractionEnabled: false),
                                                                      cvv: .init(title: L10n.Buy.cardCVV,
                                                                                 value: item.cardCVV,
                                                                                 trailing: .image(Asset.help.image.withRenderingMode(.alwaysOriginal))))
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .notificationPrompt: [
                addCardNotificationModel
            ],
            .cardDetails: [
                bankCardInputDetailsViewModel
            ],
            .button: [
                ButtonViewModel(title: L10n.Button.continueAction)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentCardInfo(actionResponse: AddCardModels.CardInfo.ActionResponse) {
        bankCardInputDetailsViewModel.number?.value = actionResponse.dataStore?.cardNumber?.chunkFormatted()
        bankCardInputDetailsViewModel.expiration?.value = actionResponse.dataStore?.cardExpDateString
        bankCardInputDetailsViewModel.cvv?.value = actionResponse.dataStore?.cardCVV
        
        viewController?.displayCardInfo(responseDisplay: .init(model: bankCardInputDetailsViewModel))
    }
    
    func presentValidate(actionResponse: AddCardModels.Validate.ActionResponse) {
        viewController?.displayValidate(responseDisplay: .init(isValid: actionResponse.isValid))
    }
    
    func presentSubmit(actionResponse: AddCardModels.Submit.ActionResponse) {
        viewController?.displaySubmit(responseDisplay: .init())
    }
    
    func presentCvvInfoPopup(actionResponse: AddCardModels.CvvInfoPopup.ActionResponse) {
        let model = PopupViewModel(title: .text(L10n.Buy.securityCode),
                                   imageName: Asset.cards.name,
                                   body: L10n.Buy.securityCodePopup)
        
        viewController?.displayCvvInfoPopup(responseDisplay: .init(model: model))
    }
    
    // MARK: - Additional Helpers
    
    private func prepareCardWithdrawalBanner() -> LabelViewModel {
        let attributedString = NSMutableAttributedString(string: L10n.Sell.visaDebitSupport)
        
        let boldRange = attributedString.mutableString.range(of: L10n.Sell.visaDebit)
        attributedString.addAttribute(.font, value: Fonts.Subtitle.two, range: boldRange)
        
        return .attributedText(attributedString)
    }
}
