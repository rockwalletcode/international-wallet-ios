//
//  ForgotPasswordViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class ForgotPasswordViewController: BaseTableViewController<AccountCoordinator,
                                    ForgotPasswordInteractor,
                                    ForgotPasswordPresenter,
                                    ForgotPasswordStore>,
                                    ForgotPasswordResponseDisplays {
    typealias Models = ForgotPasswordModels
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Account.resetPasswordTitle
    }
    
    // MARK: - Overrides
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        continueButton.configure(with: Presets.Button.primary)
        continueButton.setup(with: .init(title: L10n.Button.continueAction,
                                         enabled: false,
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
        case .notice:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .email:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
            let castedCell = cell as? WrapperTableViewCell<FETextField>
            castedCell?.setup { view in
                var config = Presets.TextField.primary
                config.autocapitalizationType = UITextAutocapitalizationType.none
                config.autocorrectionType = .no
                config.keyboardType = .emailAddress
                
                view.configure(with: config)
            }
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }
    
    // MARK: - User Interaction
    
    override func textFieldDidFinish(for indexPath: IndexPath, with text: String?) {
        let section = dataSource?.sectionIdentifier(for: indexPath.section)
        
        switch section as? Models.Section {
        case .email:
            interactor?.validate(viewAction: .init(email: text))
            
        default:
            break
        }
        
        super.textFieldDidFinish(for: indexPath, with: text)
    }
    
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.next(viewAction: .init())
    }
    
    // MARK: - ForgotPasswordResponseDisplay
    
    func displayValidate(responseDisplay: ForgotPasswordModels.Validate.ResponseDisplay) {
        let isValid = responseDisplay.isValid
        
        continueButton.viewModel?.enabled = isValid
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
        
        _ = getFieldCell(for: .email)?.setup { view in
            view.setup(with: responseDisplay.emailModel)
        }
    }
    
    func displayNext(responseDisplay: ForgotPasswordModels.Next.ResponseDisplay) {
        coordinator?.showBottomSheetAlert(type: .emailSent) { [weak self] in
            let registrationRequestData = RegistrationRequestData(email: self?.dataStore?.email, password: nil, token: nil, subscribe: false, accountHandling: .register)
            self?.coordinator?.showRegistrationConfirmation(isModalDismissable: true, confirmationType: .forgotPassword, registrationRequestData: registrationRequestData)
        }
    }
    
    // MARK: - Additional Helpers
    
    private func getFieldCell(for section: Models.Section) -> WrapperTableViewCell<FETextField>? {
        guard let section = sections.firstIndex(where: { $0.hashValue == section.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<FETextField> else {
            return nil
        }
        
        return cell
    }
}
