//
//  VerifyPhoneNumberViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import PhoneNumberKit

class VerifyPhoneNumberViewController: BaseTableViewController<AccountCoordinator,
                                       VerifyPhoneNumberInteractor,
                                       VerifyPhoneNumberPresenter,
                                       VerifyPhoneNumberStore>,
                                       VerifyPhoneNumberResponseDisplays {
    typealias Models = VerifyPhoneNumberModels
    
    override var isModalDismissableEnabled: Bool { return false }
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.VerifyPhoneNumber.title
    }
    
    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<PhoneNumberView>.self)
    }
    
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
        case .instructions:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
        
        case .phoneNumber:
            cell = self.tableView(tableView, phoneNumberCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .large, horizontal: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, phoneNumberCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<PhoneNumberView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? PhoneNumberViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
            view.didPresentPicker = { [weak self] in
                self?.interactor?.pickCountry(viewAction: .init())
            }
            
            view.didChangePhoneNumber = { [weak self] phoneNumber in
                self?.interactor?.setPhoneNumber(viewAction: .init(phoneNumber: phoneNumber))
            }
        }
        
        return cell
    }
    
    // MARK: - User Interaction
    
    override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.confirm(viewAction: .init())
    }
    
    // MARK: - VerifyPhoneNumberResponseDisplay
    
    func displaySetAreaCode(responseDisplay: VerifyPhoneNumberModels.SetAreaCode.ResponseDisplay) {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.phoneNumber.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<PhoneNumberView>
        else { return }
        
        cell.setup { view in
            view.setup(with: responseDisplay.model)
            
            self.interactor?.validate(viewAction: .init())
        }
    }
    
    func displayValidate(responseDisplay: VerifyPhoneNumberModels.Validate.ResponseDisplay) {
        let isValid = responseDisplay.isValid
        
        continueButton.viewModel?.enabled = isValid
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
    
    func displayConfirm(responseDisplay: VerifyPhoneNumberModels.Confirm.ResponseDisplay) {
        coordinator?.showKYCLevelOne(isModal: false)
    }
    
    // MARK: - Additional Helpers
}
