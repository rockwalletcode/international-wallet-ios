//
//  RegistrationConfirmationViewController.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

class RegistrationConfirmationViewController: BaseTableViewController<AccountCoordinator,
                                              RegistrationConfirmationInteractor,
                                              RegistrationConfirmationPresenter,
                                              RegistrationConfirmationStore>,
                                              RegistrationConfirmationResponseDisplays {
    typealias Models = RegistrationConfirmationModels
    
    override var isModalDismissableEnabled: Bool { return isModalDismissable }
    var isModalDismissable = true
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GoogleAnalytics.logEvent(GoogleAnalytics.VerifyProfile(type: String(describing: dataStore?.confirmationType)))
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<CodeInputView>.self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .image:
            cell = self.tableView(tableView, coverCellForRowAt: indexPath)
            (cell as? WrapperTableViewCell<FEImageView>)?.wrappedView.setupCustomMargins(vertical: .extraExtraHuge, horizontal: .large)
            
        case .title:
            cell = self.tableView(tableView, titleLabelCellForRowAt: indexPath)
            
        case .instructions:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
            
        case .input:
            cell = self.tableView(tableView, codeInputCellForRowAt: indexPath)
            
        case .help:
            cell = self.tableView(tableView, multipleButtonsCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, codeInputCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<CodeInputView> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: .init())
            
            view.valueChanged = { [weak self] text in
                self?.textFieldDidFinish(for: indexPath, with: text)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, multipleButtonsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, multipleButtonsCellForRowAt: indexPath)
        
        guard let cell = cell as? WrapperTableViewCell<MultipleButtonsView> else {
            return cell
        }
        
        cell.setup { view in
            view.configure(with: .init(buttons: [Presets.Button.noBorders]))
            
            view.callbacks = [
                resendCodeTapped,
                changeEmailTapped
            ]
        }
        
        return cell
    }

    // MARK: - User Interaction
    override func textFieldDidFinish(for indexPath: IndexPath, with text: String?) {
        interactor?.validate(viewAction: .init(code: text))
        
        super.textFieldDidFinish(for: indexPath, with: text)
    }
    
    private func resendCodeTapped() {
        interactor?.resend(viewAction: .init())
    }
    
    private func changeEmailTapped() {
        coordinator?.showChangeEmail()
    }

    // MARK: - RegistrationConfirmationResponseDisplay
    
    func displayConfirm(responseDisplay: RegistrationConfirmationModels.Confirm.ResponseDisplay) {
        view.endEditing(true)
        
        coordinator?.showBottomSheetAlert(type: .generalSuccess, completion: { [weak self] in
            guard let self = self else { return }
            switch self.dataStore?.confirmationType {
            case .twoStepEmailLogin:
                self.coordinator?.dismissFlow()
                
            case .account:
                self.coordinator?.showVerifyPhoneNumber()
                
            case .acountTwoStepEmailSettings, .twoStepEmail:
                self.coordinator?.popToRoot(completion: { [weak self] in
                    self?.coordinator?.showToastMessage(model: InfoViewModel(description: .text(L10n.TwoStep.Success.message),
                                                                             dismissType: .auto),
                                                        configuration: Presets.InfoView.warning)
                })
                
            case .acountTwoStepAppSettings:
                self.coordinator?.showAuthenticatorApp()
                
            case .twoStepApp:
                self.coordinator?.showBackupCodes()
                
            case .disable:
                self.coordinator?.popToRoot()
                
            default:
                break
            }
        })
    }
    
    func displayError(responseDisplay: RegistrationConfirmationModels.Error.ResponseDisplay) {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.input.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<CodeInputView>
        else { return }
        
        cell.wrappedView.showErrorMessage()
    }
    
    // MARK: - Additional Helpers
}
