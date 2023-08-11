//
//  SetPasswordViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 11/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SetPasswordViewController: BaseTableViewController<AccountCoordinator,
                                 SetPasswordInteractor,
                                 SetPasswordPresenter,
                                 SetPasswordStore>,
                                 SetPasswordResponseDisplays {
    typealias Models = SetPasswordModels
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Account.createNewPasswordTitle
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
        case .password:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
            let castedCell = cell as? WrapperTableViewCell<FETextField>
            castedCell?.setup { view in
                var config = Presets.TextField.primary
                config.autocapitalizationType = UITextAutocapitalizationType.none
                config.autocorrectionType = .no
                config.isSecureTextEntry = true
                
                view.configure(with: config)
            }
            
        case .confirmPassword:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
            let castedCell = cell as? WrapperTableViewCell<FETextField>
            castedCell?.setup { view in
                var config = Presets.TextField.primary
                config.autocapitalizationType = UITextAutocapitalizationType.none
                config.autocorrectionType = .no
                config.isSecureTextEntry = true
                
                view.configure(with: config)
            }
            
        case .notice:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }
    
    // MARK: - User Interaction
    
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.next(viewAction: .init())
    }
    
    override func textFieldDidFinish(for indexPath: IndexPath, with text: String?) {
        let section = dataSource?.sectionIdentifier(for: indexPath.section)
        
        switch section as? Models.Section {
        case .password:
            interactor?.validate(viewAction: .init(password: text))
            
        case .confirmPassword:
            interactor?.validate(viewAction: .init(passwordAgain: text))
            
        default:
            break
        }
        
        super.textFieldDidFinish(for: indexPath, with: text)
    }
    
    // MARK: - SetPasswordResponseDisplay
    
    func displayValidate(responseDisplay: SetPasswordModels.Validate.ResponseDisplay) {
        let isValid = responseDisplay.isValid
        
        continueButton.viewModel?.enabled = isValid
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
        
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.notice.hashValue }),
              let noticeCell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<FELabel> else { return }
        noticeCell.setup { view in
            view.configure(with: responseDisplay.noticeConfiguration)
        }
        
        _ = getFieldCell(for: .password)?.setup { view in
            view.setup(with: responseDisplay.passwordModel)
        }
        _ = getFieldCell(for: .confirmPassword)?.setup { view in
            view.setup(with: responseDisplay.passwordAgainModel)
        }
    }
    
    func displayNext(responseDisplay: SetPasswordModels.Next.ResponseDisplay) {
        coordinator?.showBottomSheetAlert(type: .passwordUpdated) { [weak self] in
            self?.coordinator?.showSignIn()
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
