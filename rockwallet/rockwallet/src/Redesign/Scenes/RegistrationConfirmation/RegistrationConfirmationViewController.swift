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
    
    var didDismiss: ((Bool) -> Void)?
    
    // MARK: - Overrides
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        didDismiss?(false)
    }
    
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
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? MultipleButtonsViewModel,
              let cell: WrapperTableViewCell<MultipleButtonsView> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(buttons: [Presets.Button.noBorders],
                                       axis: .horizontal))
            view.setup(with: model)
        }
        
        return cell
    }

    // MARK: - User Interaction
    
    override func textFieldDidFinish(for indexPath: IndexPath, with text: String?) {
        interactor?.validate(viewAction: .init(code: text))
        
        super.textFieldDidFinish(for: indexPath, with: text)
    }
    
    func resendCodeTapped() {
        interactor?.resend(viewAction: .init())
    }
    
    func changeEmailTapped() {
        coordinator?.showChangeEmail()
    }
    
    func enterBackupCode() {
        guard let confirmationType = dataStore?.confirmationType else { return }
        
        dataStore?.confirmationType = .twoStepAppBackupCode(confirmationType)
        
        prepareData()
    }
    
    // MARK: - RegistrationConfirmationResponseDisplay
    
    func displayConfirm(responseDisplay: RegistrationConfirmationModels.Confirm.ResponseDisplay) {
        view.endEditing(true)
        
        let isGeneralSuccessAlert = dataStore?.confirmationType != .forgotPassword
        
        coordinator?.showBottomSheetAlert(type: isGeneralSuccessAlert ? .generalSuccess : .emailSent, completion: { [weak self] in
            guard let self = self else { return }
            
            switch self.dataStore?.confirmationType {
            case .twoStepEmailLogin, .twoStepAppLogin, .twoStepAppBackupCode, .twoStepEmailResetPassword,
                    .twoStepAppResetPassword, .twoStepAppSendFunds, .twoStepEmailSendFunds,
                    .twoStepEmailBuy, .twoStepAppBuy, .twoStepAppRequired, .twoStepEmailRequired, .forgotPassword:
                self.didDismiss?(true)
                
                self.coordinator?.dismissFlow()
                
            case .account:
                self.coordinator?.showVerifyPhoneNumber()
                
            case .twoStepAccountEmailSettings, .twoStepEmail:
                self.coordinator?.popToRoot(completion: { [weak self] in
                    self?.coordinator?.showToastMessage(model: InfoViewModel(description: .text(L10n.TwoStep.Success.message),
                                                                             dismissType: .auto),
                                                        configuration: Presets.InfoView.warning)
                })
                
            case .twoStepAccountAppSettings:
                self.coordinator?.showAuthenticatorApp(setTwoStepAppModel: self.dataStore?.setTwoStepAppModel)
                
            case .twoStepApp:
                self.coordinator?.showBackupCodes()
            
            case .twoStepDisable:
                self.coordinator?.popToRoot()
                
            default:
                break
            }
        })
    }
    
    // MARK: - Additional Helpers
}
