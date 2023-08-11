//
//  BaseInfoPresenter.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 13.7.22.
//
//

import UIKit

final class BaseInfoPresenter: NSObject, Presenter, BaseInfoActionResponses {
    
    typealias Models = BaseInfoModels

    weak var viewController: BaseInfoViewController?
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        var sections: [Models.Section] = []
        
        if viewController?.imageName != nil {
            sections.append(.image)
        }
        
        if viewController?.titleText != nil {
            sections.append(.title)
        }
        
        if viewController?.descriptionText != nil {
            sections.append(.description)
        }
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .image: [
                ImageViewModel.imageName(viewController?.imageName)
            ],
            .title: [
                LabelViewModel.text(viewController?.titleText)
            ],
            .description: [
                LabelViewModel.text(viewController?.descriptionText)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }

    // MARK: - BaseInfoActionResponses
    
    func presentAssetSelectionData(actionResponse: BaseInfoModels.Assets.ActionResponse) {
        viewController?.displayAssetSelectionData(responseDisplay: .init(title: L10n.Swap.selectAssets,
                                                                         currencies: Store.state.currencies,
                                                                         supportedCurrencies: actionResponse.supportedCurrencies))
    }

    // MARK: - Additional Helpers

}
