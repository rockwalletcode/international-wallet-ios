//
//  VerifyPhoneNumberPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class VerifyPhoneNumberPresenter: NSObject, Presenter, VerifyPhoneNumberActionResponses {
    typealias Models = VerifyPhoneNumberModels
    
    weak var viewController: VerifyPhoneNumberViewController?
    
    // MARK: - VerifyPhoneNumberActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        if let item = actionResponse.item as? (any Models.Item),
           let iso2 = item.country?.iso2,
           let name = item.country?.name,
           let areaCode = item.country?.areaCode {
            presentSetAreaCode(actionResponse: .init(areaCode: .init(iso2: iso2,
                                                                     name: name,
                                                                     areaCode: areaCode),
                                                     phoneNumber: viewController?.dataStore?.phoneNumber))
            return
        }
        
        let sections: [Models.Section] = [
            .instructions,
            .phoneNumber
        ]
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .instructions: [
                LabelViewModel.text(L10n.VerifyPhoneNumber.instructions)
            ],
            .phoneNumber: [
                PhoneNumberViewModel(areaCode: .init(leading: .imageName(Constant.countryUS), title: "+1"),
                                     phoneNumber: .init(placeholder: L10n.VerifyPhoneNumber.PhoneNumber.title))
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentSetAreaCode(actionResponse: VerifyPhoneNumberModels.SetAreaCode.ActionResponse) {
        viewController?.displaySetAreaCode(responseDisplay: .init(model:
                .init(areaCode: .init(leading: .imageName(actionResponse.areaCode.iso2),
                                      title: "+" + (actionResponse.areaCode.areaCode ?? "")),
                      phoneNumber: .init(value: actionResponse.phoneNumber,
                                         placeholder: L10n.VerifyPhoneNumber.PhoneNumber.title))))
    }
    
    func presentValidate(actionResponse: VerifyPhoneNumberModels.Validate.ActionResponse) {
        viewController?.displayValidate(responseDisplay: .init(isValid: actionResponse.isValid))
    }
    
    func presentConfirm(actionResponse: VerifyPhoneNumberModels.Confirm.ActionResponse) {
        viewController?.displayConfirm(responseDisplay: .init())
    }
    
    // MARK: - Additional Helpers
    
}
