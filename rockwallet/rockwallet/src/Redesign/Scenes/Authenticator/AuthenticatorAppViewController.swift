//
//  AuthenticatorAppViewController.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 29.3.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class AuthenticatorAppViewController: BaseTableViewController<AccountCoordinator,
                                      AuthenticatorAppInteractor,
                                      AuthenticatorAppPresenter,
                                      AuthenticatorAppStore>,
                                      AuthenticatorAppResponseDisplays {
    typealias Models = AuthenticatorAppModels
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Authentication.title
    }
    
    // MARK: - Overrides
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        continueButton.configure(with: Presets.Button.primary)
        continueButton.setup(with: .init(title: L10n.Button.continueAction,
                                         enabled: true,
                                         callback: { [weak self] in
            self?.buttonTapped()
        }))
        
        guard let config = continueButton.config, let model = continueButton.viewModel else { return }
        verticalButtons.wrappedView.configure(with: .init(buttons: [config]))
        verticalButtons.wrappedView.setup(with: .init(buttons: [model]))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .importWithLink:
            cell = self.tableView(tableView, titleButtonViewCellForRowAt: indexPath)
            
            (cell as? WrapperTableViewCell<TitleButtonView>)?.wrappedView.didTapButton = { [weak self] in
                self?.interactor?.openTotpUrl(viewAction: .init())
            }
            
        case .divider:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
            (cell as? WrapperTableViewCell<FELabel>)?.wrappedView.configure(with: .init(font: Fonts.Subtitle.two,
                                                                                        textColor: LightColors.Text.three,
                                                                                        textAlignment: .center))
            
        case .instructions:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
            
            (cell as? WrapperTableViewCell<FELabel>)?.wrappedView.configure(with: .init(font: Fonts.Body.two,
                                                                                        textColor: LightColors.Text.three))
            
        case .qrCode:
            cell = self.tableView(tableView, paddedImageViewCellForRowAt: indexPath)
            
        case .enterCodeManually:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .copyCode:
            cell = self.tableView(tableView, orderViewCellForRowAt: indexPath)
            
            (cell as? WrapperTableViewCell<OrderView>)?.setup({ view in
                view.configure(with: Presets.Order.auth)
            })
            
            (cell as? WrapperTableViewCell<OrderView>)?.wrappedView.didCopyValue = { [weak self] value in
                self?.interactor?.copyValue(viewAction: .init(value: value))
            }
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .large, horizontal: .large)
        
        return cell
    }
    
    // MARK: - User Interaction
    
    override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.next(viewAction: .init())
    }
    
    // MARK: - AuthenticatorAppResponseDisplay
    
    func displayNext(responseDisplay: AuthenticatorAppModels.Next.ResponseDisplay) {
        coordinator?.showRegistrationConfirmation(isModalDismissable: true, confirmationType: .twoStepApp)
    }
    
    func displayOpenTotpUrl(responseDisplay: AuthenticatorAppModels.OpenTotpUrl.ResponseDisplay) {
        coordinator?.openUrl(url: responseDisplay.url)
    }
    
    // MARK: - Additional Helpers
}
