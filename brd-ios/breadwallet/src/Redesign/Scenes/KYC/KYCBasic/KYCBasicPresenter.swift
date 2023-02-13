//
//  KYCBasicPresenter.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

final class KYCBasicPresenter: NSObject, Presenter, KYCBasicActionResponses {
    typealias Models = KYCBasicModels

    weak var viewController: KYCBasicViewController?

    // MARK: - KYCBasicActionResponses

    // MARK: - Additional Helpers
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? Models.Item else { return }
        let sections: [Models.Section] = [
            .name,
            .birthdate,
            .confirm
        ]
        
        let dateViewModel: DateViewModel
        let title: LabelViewModel? = .text(L10n.Account.dateOfBirth)
        
        if let date = item.birthdate {
            let components = Calendar.current.dateComponents([.day, .year, .month], from: date)
            let dateFormat = "%02d"
            guard let month = components.month,
                  let day = components.day,
                  let year = components.year else { return }
            
            dateViewModel = DateViewModel(date: date,
                                          title: title,
                                          month: .init(value: String(format: dateFormat, month), isUserInteractionEnabled: false),
                                          day: .init(value: String(format: dateFormat, day), isUserInteractionEnabled: false),
                                          year: .init(value: "\(year)", isUserInteractionEnabled: false))
        } else {
            dateViewModel = DateViewModel(date: nil,
                                          title: title,
                                          month: .init(title: "MM", isUserInteractionEnabled: false),
                                          day: .init(title: "DD", isUserInteractionEnabled: false),
                                          year: .init(title: "YYYY", isUserInteractionEnabled: false))
        }
        
        let sectionRows: [Models.Section: [Any]] = [
            .name: [
                DoubleHorizontalTextboxViewModel(primaryTitle: .text(L10n.Account.writeYourName),
                                                 primary: .init(title: L10n.Buy.firstName, value: item.firstName),
                                                 secondary: .init(title: L10n.Buy.lastName, value: item.lastName))
            ],
            .birthdate: [ dateViewModel ],
            .confirm: [ ButtonViewModel(title: L10n.Button.confirm) ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentValidate(actionResponse: KYCBasicModels.Validate.ActionResponse) {
        viewController?.displayValidate(responseDisplay: .init(isValid: actionResponse.isValid))
    }
    
    func presentSubmit(actionResponse: KYCBasicModels.Submit.ActionResponse) {
        viewController?.displaySubmit(responseDisplay: .init())
    }
}
