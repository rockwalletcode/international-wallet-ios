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
        let sections: [Models.Section] = [
            .image,
            .title,
            .description
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: [:]))   
    }

    // MARK: - BaseInfoActionResponses
    
    func presentAssetSelectionData(actionResponse: BaseInfoModels.Assets.ActionResponse) {
        viewController?.displayAssetSelectionData(responseDisplay: .init(title: L10n.Swap.selectAssets,
                                                                         currencies: Store.state.currencies,
                                                                         supportedCurrencies: actionResponse.supportedCurrencies))
    }

    // MARK: - Additional Helpers

}
