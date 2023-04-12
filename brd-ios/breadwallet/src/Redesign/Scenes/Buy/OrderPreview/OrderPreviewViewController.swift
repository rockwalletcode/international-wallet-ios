//
//  OrderPreviewViewController.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.8.22.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class OrderPreviewViewController: BaseTableViewController<ExchangeCoordinator,
                                  OrderPreviewInteractor,
                                  OrderPreviewPresenter,
                                  OrderPreviewStore>,
                                  OrderPreviewResponseDisplays {
    typealias Models = OrderPreviewModels
    
    override var sceneTitle: String? {
        return dataStore?.type?.title
    }
    
    private var veriffKYCManager: VeriffKYCManager?
    
    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<BuyOrderView>.self)
        tableView.register(WrapperTableViewCell<PaymentMethodView>.self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .achNotification:
            cell = self.tableView(tableView, infoViewCellForRowAt: indexPath)
            
        case .orderInfoCard:
            cell = self.tableView(tableView, orderCellForRowAt: indexPath)
            
        case .payment:
            cell = self.tableView(tableView, paymentMethodCellForRowAt: indexPath)
            
        case .termsAndConditions:
            guard let isAchAccount = dataStore?.isAchAccount else { return UITableViewCell() }
            
            if isAchAccount {
                cell = self.tableView(tableView, infoViewCellForRowAt: indexPath)
            } else {
                cell = self.tableView(tableView, labelCellForRowAt: indexPath)
                
                let wrappedCell = cell as? WrapperTableViewCell<FELabel>
                wrappedCell?.isUserInteractionEnabled = true
                wrappedCell?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsAndConditionsTapped(_:))))
            }
            
        case .submit:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(all: .large)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, labelCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? LabelViewModel,
              let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(font: Fonts.Body.three, textColor: LightColors.Text.one))
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, paymentMethodCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<PaymentMethodView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? PaymentMethodViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(shadow: Presets.Shadow.light,
                                       background: .init(backgroundColor: LightColors.Background.one,
                                                         tintColor: LightColors.Text.one,
                                                         border: Presets.Border.commonPlain)))
            view.setup(with: model)
            
            view.didTypeCVV = { [weak self] cvv in
                self?.interactor?.updateCvv(viewAction: .init(cvv: cvv.text))
            }
            
            view.didTapCvvInfo = { [weak self] in
                self?.interactor?.showCvvInfoPopup(viewAction: .init())
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, orderCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<BuyOrderView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? BuyOrderViewModel
        else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            view.cardFeeInfoTapped = { [weak self] in
                self?.interactor?.showInfoPopup(viewAction: .init(isCardFee: true))
            }
            view.networkFeeInfoTapped = { [weak self] in
                self?.interactor?.showInfoPopup(viewAction: .init(isCardFee: false))
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, infoViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? InfoViewModel,
              let cell: WrapperTableViewCell<WrapperView<FEInfoView>> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.setup { view in
                view.setup(with: model)
                view.configure(with: Presets.InfoView.tickbox)
                view.setupCustomMargins(all: .large)
                
                view.trailingButtonCallback = { [weak self] in
                    self?.interactor?.showTermsAndConditions(viewAction: .init())
                }
                
                view.toggleTickboxCallback = { [weak self] value in
                    self?.interactor?.toggleTickbox(viewAction: .init(value: value))
                }
            }
        }
        
        return cell
    }

    // MARK: - User Interaction
    
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        coordinator?.showPinInput(keyStore: dataStore?.keyStore) { [weak self] success in
            if success {
                self?.interactor?.checkTimeOut(viewAction: .init())
            } else {
                self?.coordinator?.dismissFlow()
            }
        }
    }
    
    @objc private func termsAndConditionsTapped(_ sender: Any) {
        interactor?.showTermsAndConditions(viewAction: .init())
    }
    
    // MARK: - OrderPreviewResponseDisplay
    
    func displayTermsAndConditions(responseDisplay: OrderPreviewModels.TermsAndConditions.ResponseDisplay) {
        coordinator?.showTermsAndConditions(url: responseDisplay.url)
    }
    
    func displayTimeOut(responseDisplay: OrderPreviewModels.ExpirationValidations.ResponseDisplay) {
        if responseDisplay.isTimedOut {
            coordinator?.showTimeout(type: dataStore?.type)
        } else {
            LoadingView.show()
            interactor?.submit(viewAction: .init())
        }
    }
    
    func displayInfoPopup(responseDisplay: OrderPreviewModels.InfoPopup.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model)
    }
    
    func displayCvvInfoPopup(responseDisplay: OrderPreviewModels.CvvInfoPopup.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model, config: Presets.Popup.normal)
    }
    
    func displaySubmit(responseDisplay: OrderPreviewModels.Submit.ResponseDisplay) {
        LoadingView.hideIfNeeded()
        
        let transactionType: TransactionType = dataStore?.isAchAccount ?? false ? .buyAch : .buy
        coordinator?.showSuccess(reason: responseDisplay.reason,
                                 itemId: responseDisplay.paymentReference,
                                 transactionType: transactionType)
    }
    
    func displayFailure(responseDisplay: OrderPreviewModels.Failure.ResponseDisplay) {
        coordinator?.showFailure(reason: responseDisplay.reason, availablePayments: dataStore?.availablePayments ?? [])
    }
    
    func displayVeriffLivenessCheck(responseDisplay: OrderPreviewModels.VeriffLivenessCheck.ResponseDisplay) {
        veriffKYCManager = VeriffKYCManager(navigationController: coordinator?.navigationController)
        veriffKYCManager?.showExternalKYCForLivenessCheck(livenessCheckData: .init(quoteId: responseDisplay.quoteId,
                                                                                   isBiometric: responseDisplay.isBiometric,
                                                                                   biometricType: .buy)) { [weak self] result in
            switch result.status {
            case .done:
                self?.interactor?.checkBiometricStatus(viewAction: .init(resetCounter: true))
                
            default:
                self?.displayBiometricStatusFailed(responseDisplay: .init())
            }
        }
    }
    
    func displayBiometricStatusFailed(responseDisplay: OrderPreviewModels.BiometricStatusFailed.ResponseDisplay) {
        coordinator?.showFailure(reason: .buyCard(nil))
    }
    
    func displayThreeDSecure(responseDisplay: OrderPreviewModels.ThreeDSecure.ResponseDisplay) {
        coordinator?.showThreeDSecure(url: responseDisplay.url)
    }
    
    override func displayMessage(responseDisplay: MessageModels.ResponseDisplays) {
        if responseDisplay.error != nil {
            LoadingView.hideIfNeeded()
        }
        
        guard !isAccessDenied(responseDisplay: responseDisplay) else { return }
        
        coordinator?.showToastMessage(with: responseDisplay.error,
                                      model: responseDisplay.model,
                                      configuration: responseDisplay.config)
    }
    
    func displayContinueEnabled(responseDisplay: OrderPreviewModels.CvvValidation.ResponseDisplay) {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.submit.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<FEButton> else { return }
        
        cell.wrappedView.isEnabled = responseDisplay.continueEnabled
    }
    
    // MARK: - Additional Helpers
}
