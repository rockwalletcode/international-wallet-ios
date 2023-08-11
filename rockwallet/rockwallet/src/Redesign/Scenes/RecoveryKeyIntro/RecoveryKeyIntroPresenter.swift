//
//  RecoveryKeyIntroPresenter.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 04/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class RecoveryKeyIntroPresenter: NSObject, Presenter, RecoveryKeyIntroActionResponses {
    
    typealias Models = RecoveryKeyIntroModels
    
    weak var viewController: RecoveryKeyIntroViewController?
    
    // MARK: - ProfileActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        let sections: [Models.Section] =  [
            .title,
            .image,
            .writePhrase,
            .keepPhrasePrivate,
            .storePhraseSecurely,
            .tickbox
        ]
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .title: [LabelViewModel.text(L10n.RecoveryKeyFlow.title)],
            .image: [ImageViewModel.photo(Asset.recoveryPhrase1st.image)],
            .writePhrase: [TitleValueViewModel(title: .text(L10n.RecoveryKeyFlow.WritePhrase.title),
                                               value: .text(L10n.RecoveryKeyFlow.WritePhrase.subtitle))],
            .keepPhrasePrivate: [TitleValueViewModel(title: .text(L10n.RecoveryKeyFlow.KeepPhrasePrivate.title),
                                                     value: .text(L10n.RecoveryKeyFlow.KeepPhrasePrivate.subtitle))],
            .storePhraseSecurely: [TitleValueViewModel(title: .text(L10n.RecoveryKeyFlow.StorePhraseSecurely.title),
                                                       value: .text(L10n.RecoveryKeyFlow.StorePhraseSecurely.subtitle))],
            .tickbox: [TickboxItemViewModel(title: .text(L10n.RecoveryKeyFlow.Tickbox.value))]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentToggleTickbox(actionResponse: RecoveryKeyIntroModels.Tickbox.ActionResponse) {
        viewController?.displayToggleTickbox(responseDisplay: .init(model: .init(title: L10n.Button.continueAction, enabled: actionResponse.value)))
    }
    
    // MARK: - Additional Helpers
    
}
