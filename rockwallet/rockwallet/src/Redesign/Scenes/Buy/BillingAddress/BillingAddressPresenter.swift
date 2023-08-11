//
//  BillingAddressPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 01/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class BillingAddressPresenter: NSObject, Presenter, BillingAddressActionResponses {
    typealias Models = BillingAddressModels

    weak var viewController: BillingAddressViewController?

    // MARK: - BillingAddressActionResponses

    // MARK: - Additional Helpers
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        
        let sections: [Models.Section] = [
            .name,
            .country,
            .stateProvince,
            .cityAndZipPostal,
            .address,
            .confirm
        ]
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .name: [
                DoubleHorizontalTextboxViewModel(primary: .init(title: L10n.Buy.firstName,
                                                                value: item.firstName),
                                                 secondary: .init(title: L10n.Buy.lastName,
                                                                  value: item.lastName))
            ],
            .country: [
                TextFieldModel(title: L10n.Account.country,
                               value: item.country?.name ?? "",
                               trailing: .image(Asset.chevronDown.image),
                               isUserInteractionEnabled: false)
            ],
            .stateProvince: [
                TextFieldModel(title: L10n.Buy.stateProvince,
                               value: item.state?.name ?? "")
            ],
            .cityAndZipPostal: [
                DoubleHorizontalTextboxViewModel(primary: .init(title: L10n.Buy.city,
                                                                value: item.city),
                                                 secondary: .init(title: L10n.Buy.zipPostalCode,
                                                                  value: item.zipPostal))
            ],
            .address: [
                TextFieldModel(title: L10n.Buy.address,
                               value: item.address)
            ],
            .confirm: [
                ButtonViewModel(title: L10n.Button.confirm)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentThreeDSecure(actionResponse: BillingAddressModels.ThreeDSecure.ActionResponse) {
        viewController?.displayThreeDSecure(responseDisplay: .init(url: actionResponse.url))
    }
    
    func presentValidate(actionResponse: BillingAddressModels.Validate.ActionResponse) {
        viewController?.displayValidate(responseDisplay: .init(isValid: actionResponse.isValid))
    }
    
    func presentSubmit(actionResponse: BillingAddressModels.Submit.ActionResponse) {
        viewController?.displaySubmit(responseDisplay: .init())
    }
}
