//
//  SignInViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 09/01/2022.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SignInViewController: BaseTableViewController<AccountCoordinator,
                            SignInInteractor,
                            SignInPresenter,
                            SignInStore>,
                            SignInResponseDisplays {
    typealias Models = SignInModels
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Account.signIn
    }
    
    lazy var createAccountButton: FEButton = {
        let view = FEButton()
        return view
    }()
    
    // MARK: - Overrides
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        continueButton.configure(with: Presets.Button.primary)
        continueButton.setup(with: .init(title: L10n.Button.continueAction,
                                         enabled: false,
                                         callback: { [weak self] in
            self?.buttonTapped()
        }))
        
        let partOneAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: Colors.Text.two,
            NSAttributedString.Key.backgroundColor: UIColor.clear,
            NSAttributedString.Key.font: Fonts.Body.two]
        let partTwoAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: Colors.secondary,
            NSAttributedString.Key.backgroundColor: UIColor.clear,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.font: Fonts.Subtitle.two]
        
        let partOne = NSMutableAttributedString(string: L10n.Account.newToRockwallet + " ", attributes: partOneAttributes)
        let partTwo = NSMutableAttributedString(string: L10n.Account.createAccountButton, attributes: partTwoAttributes)
        let createAccountButtonTitle = NSMutableAttributedString()
        createAccountButtonTitle.append(partOne)
        createAccountButtonTitle.append(partTwo)
        
        createAccountButton.configure(with: Presets.Button.noBorders)
        createAccountButton.setup(with: .init(attributedTitle: createAccountButtonTitle,
                                              isUnderlined: true,
                                              enabled: true,
                                              callback: { [weak self] in
            self?.coordinator?.showSignUp()
        }))
        
        guard let continueButtonConfig = continueButton.config,
              let continueButtonModel = continueButton.viewModel,
              let createAccountButtonConfig = createAccountButton.config,
              let createAccountButtonModel = createAccountButton.viewModel else { return }
        verticalButtons.wrappedView.configure(with: .init(buttons: [continueButtonConfig, createAccountButtonConfig]))
        verticalButtons.wrappedView.setup(with: .init(buttons: [continueButtonModel, createAccountButtonModel]))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
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
            
        case .forgotPassword:
            cell = self.tableView(tableView, multipleButtonsCellForRowAt: indexPath)
            
        case .termsDescription, .terms, .termsPro:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, descriptionLabelCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? LabelViewModel,
              let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(font: Fonts.Body.two, textColor: Colors.Text.two, textAlignment: .center, isUserInteractionEnabled: true))
            view.setup(with: model)
            
            view.didTapLink = { [weak self] in
                let url = Constant.termsAndConditions
                self?.coordinator?.showInWebView(urlString: url, title: L10n.About.terms)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, multipleButtonsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? MultipleButtonsViewModel,
              let cell: WrapperTableViewCell<MultipleButtonsView> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(buttons: [Presets.Button.noBorders],
                                       isRightAligned: true,
                                       axis: .horizontal))
            view.setup(with: model)
            
            view.callbacks = [
                forgotPasswordTapped
            ]
        }
        
        return cell
    }
    
    // MARK: - User Interaction
    
    override func textFieldDidFinish(for indexPath: IndexPath, with text: String?) {
        let section = dataSource?.sectionIdentifier(for: indexPath.section)
        
        switch section as? Models.Section {
        case .email:
            interactor?.validate(viewAction: .init(email: text))
            
        case .password:
            interactor?.validate(viewAction: .init(password: text))
            
        default:
            break
        }
        
        super.textFieldDidFinish(for: indexPath, with: text)
    }
    
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.next(viewAction: .init())
    }
    
    private func forgotPasswordTapped() {
        coordinator?.showForgotPassword()
    }
    
    // MARK: - SignInResponseDisplay
    
    func displayValidate(responseDisplay: SignInModels.Validate.ResponseDisplay) {
        let isValid = responseDisplay.isValid
        
        continueButton.viewModel?.enabled = isValid
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
        
        _ = getFieldCell(for: .email)?.setup { view in
            view.setup(with: responseDisplay.emailModel)
        }
        _ = getFieldCell(for: .password)?.setup { view in
            view.setup(with: responseDisplay.passwordModel)
        }
    }
    
    func displayNext(responseDisplay: SignInModels.Next.ResponseDisplay) {
        coordinator?.dismissFlow()
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
