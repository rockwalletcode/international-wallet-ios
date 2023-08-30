//
//  PaymailAddressViewController.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.4.23.
//
//

import UIKit

class PaymailAddressViewController: BaseTableViewController<AccountCoordinator,
                                    PaymailAddressInteractor,
                                    PaymailAddressPresenter,
                                    PaymailAddressStore>,
                                    PaymailAddressResponseDisplays {
    typealias Models = PaymailAddressModels

    // MARK: - Overrides
    
    override var sceneLeftAlignedTitle: String? {
        let isPaymailFromAssets = dataStore?.isPaymailFromAssets ?? false
        return isPaymailFromAssets ? L10n.PaymailAddress.transferBsvTitle : L10n.PaymailAddress.title
    }
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        continueButton.configure(with: Presets.Button.primary)
        continueButton.setup(with: .init(title: dataStore?.screenType?.buttonTitle,
                                         enabled: dataStore?.screenType == .paymailSetup,
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
        case .description, .emailViewTitle:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
            
        case .emailView:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
            let castedCell = cell as? WrapperTableViewCell<FETextField>
            castedCell?.setup { view in
                var config = Presets.TextField.primary
                config.autocapitalizationType = UITextAutocapitalizationType.none
                config.autocorrectionType = .no
                config.keyboardType = .emailAddress
                
                view.configure(with: config)
                view.didTapTrailingView = { [weak self] in
                    self?.interactor?.validate(viewAction: .init(email: E.paymailDomain))
                }
            }
            
        case .emailViewSetup:
            cell = self.tableView(tableView, emailViewCellForRowAt: indexPath)
        
        case .paymail:
            cell = self.tableView(tableView, multipleButtonsCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .large, horizontal: .large)
        
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
                                       axis: .horizontal))
            view.setup(with: model)
            
            view.callbacks = [
                showPaymailPopup
            ]
        }
        
        return cell
    }

    // MARK: - User Interaction
    
    func tableView(_ tableView: UITableView, emailViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<CardSelectionView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? CardSelectionViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            let config = CardSelectionConfiguration(subtitle: .init(font: Fonts.Title.six,
                                                                    textColor: Colors.Text.three,
                                                                    textAlignment: .center,
                                                                    numberOfLines: 1),
                                                    arrow: .init(tintColor: Colors.primary))
            view.configure(with: config)
            view.setup(with: model)
            
            view.didTapSelectCard = { [weak self] in
                let paymailAddress = self?.dataStore?.paymailAddress
                self?.interactor?.copyValue(viewAction: .init(value: paymailAddress,
                                                              message: L10n.PaymailAddress.copyMessage(paymailAddress ?? "")))
            }
        }
        
        return cell
    }
    
    override func textFieldDidFinish(for indexPath: IndexPath, with text: String?) {
        let section = dataSource?.sectionIdentifier(for: indexPath.section)
        
        switch section as? Models.Section {
        case .emailView:
            interactor?.validate(viewAction: .init(email: text))
            
        default:
            break
        }
        
        super.textFieldDidFinish(for: indexPath, with: text)
    }
    
    override func buttonTapped() {
        super.buttonTapped()
        
        guard dataStore?.screenType == .paymailNotSetup else {
            coordinator?.dismissFlow()
            return
        }
        
        interactor?.createPaymailAddress(viewAction: .init())
    }
    
    private func showPaymailPopup() {
        interactor?.showPaymailPopup(viewAction: .init())
    }

    // MARK: - PaymailAddressResponseDisplay
    
    func displayPaymailSuccess(responseDisplay: PaymailAddressModels.CreatePaymail.ResponseDisplay) {
        interactor?.showSuccessBottomAlert(viewAction: .init())
    }
    
    func displayPaymailPopup(responseDisplay: PaymailAddressModels.InfoPopup.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model)
    }
    
    func displaySuccessBottomAlert(responseDisplay: PaymailAddressModels.BottomAlert.ResponseDisplay) {
        coordinator?.showBottomSheetAlert(type: .generalSuccess, completion: { [weak self] in
            self?.setupVerticalButtons()
            self?.interactor?.getData(viewAction: .init())
        })
    }
    
    func displayValidate(responseDisplay: PaymailAddressModels.Validate.ResponseDisplay) {
        let isValid = responseDisplay.isValid
        
        _ = getFieldCell(for: .emailView)?.setup { view in
            view.setup(with: responseDisplay.emailModel)
        }
        
        tableView.invalidateTableViewIntrinsicContentSize()
        
        continueButton.viewModel?.enabled = isValid
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
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
