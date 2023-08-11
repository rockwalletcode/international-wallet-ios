//
//  KYCAddressPresenter.swift
//  breadwallet
//
//  Created by Rok on 06/01/2023.
//
//

import UIKit

final class KYCAddressPresenter: NSObject, Presenter, KYCAddressActionResponses {
    typealias Models = KYCAddressModels

    weak var viewController: KYCAddressViewController?

    // MARK: - KYCAddressActionResponses
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        var sections: [Models.Section] = [
            .mandatory,
            .address,
            .country,
            .cityAndState,
            .postalCode,
            .confirm
        ]
        
        let trailingModel: ImageViewModel? = item.country?.iso2 == Constant.countryUS ? .image(Asset.chevronDown.image) : nil
        
        if item.country?.iso2 == Constant.countryUS && !E.isProduction {
            let confirmIndex = sections.firstIndex(of: .confirm) ?? 0
            sections.insert(contentsOf: [.ssn, .ssnInfo], at: confirmIndex)
        }
        
        let state = item.state?.name.isEmpty == true ? item.state?.iso2 : item.state?.name
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .mandatory: [LabelViewModel.text(L10n.Account.mandatoryFields)],
            .address: [
                TextFieldModel(title: "\(L10n.Buy.address)*",
                               value: item.address,
                               isUserInteractionEnabled: false)
            ],
            .country: [
                TextFieldModel(title: L10n.Account.countryRegion,
                               value: item.country?.name ?? "",
                               trailing: .image(Asset.chevronDown.image),
                               isUserInteractionEnabled: false)
            ],
            .cityAndState: [
                DoubleHorizontalTextboxViewModel(primary: .init(title: L10n.Account.city,
                                                                value: item.city),
                                                 secondary: .init(title: L10n.Buy.stateProvince,
                                                                  value: state,
                                                                  trailing: trailingModel,
                                                                  isUserInteractionEnabled: item.country?.iso2 != Constant.countryUS))
            ],
            .postalCode: [
                TextFieldModel(title: L10n.Account.postalCode,
                               value: item.postalCode)
            ],
            .ssn: [
                TextFieldModel(title: L10n.Account.socialSecurityNumber,
                               value: item.ssn)
            ],
            .ssnInfo: [MultipleButtonsViewModel(buttons: [ButtonViewModel(title: L10n.Account.infoLinkSSN,
                                                                          isUnderlined: true)])
                      ],
            .confirm: [
                ButtonViewModel(title: L10n.Button.confirm, enabled: item.isValid)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentForm(actionResponse: KYCAddressModels.FormUpdated.ActionResponse) {
        viewController?.displayForm(responseDisplay: .init(isValid: actionResponse.isValid ?? false))
    }
    
    func presentExternalKYC(actionResponses: KYCAddressModels.ExternalKYC.ActionResponse) {
        viewController?.displayExternalKYC(responseDisplay: .init())
    }
    
    func presentSsnInfo(actionResponse: KYCAddressModels.SsnInfo.ActionResponse) {
        let model = PopupViewModel(title: .text(L10n.Account.socialSecurityNumber),
                                   body: L10n.Account.explanationSSN)
        
        viewController?.displaySsnInfo(responseDisplay: .init(model: model))
    }

    // MARK: - Additional Helpers

}
