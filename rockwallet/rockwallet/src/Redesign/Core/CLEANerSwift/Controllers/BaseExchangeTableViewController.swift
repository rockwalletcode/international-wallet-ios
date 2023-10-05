// 
//  BaseExchangeTableViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 03/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class BaseExchangeTableViewController<C: CoordinatableRoutes,
                                      I: Interactor,
                                      P: Presenter,
                                      DS: BaseDataStore & NSObject>: BaseTableViewController<C, I, P, DS> {
    typealias Models = AssetModels
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ExchangeManager.shared.reload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ExchangeManager.shared.reload()
        
        getRateAndTimerCell()?.wrappedView.invalidate()
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.backgroundColor = Colors.Background.two
        
        tableView.register(WrapperTableViewCell<MainSwapView>.self)
        tableView.register(WrapperTableViewCell<SwapCurrencyView>.self)
        tableView.register(WrapperTableViewCell<SwitchFromToHorizontalView>.self)
        
        tableView.delaysContentTouches = false
        tableView.backgroundColor = Colors.Background.two
        verticalButtons.backgroundColor = Colors.Background.two
        
        tableView.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(Margins.extraHuge.rawValue)
            make.bottom.equalTo(verticalButtons.snp.top).offset(-Margins.large.rawValue)
        }
    }
    
    func tableView(_ tableView: UITableView, timerCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<ExchangeRateView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? ExchangeRateViewModel
        else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, paymentSelectionCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<CardSelectionView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? CardSelectionViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
            view.didTapSelectCard = { [weak self] in
                switch (self?.dataStore as? (any PaymentMethodsDataStore))?.paymentMethod {
                case .ach:
                    (self?.interactor as? (any PaymentMethodsViewActions))?.getPlaidToken(viewAction: .init())
                    
                case .card:
                    (self?.interactor as? (any PaymentMethodsViewActions))?.getPayments(viewAction: .init(openCards: true), completion: {})
                    
                default:
                    break
                }
            }
            
            view.didTapPlaidAccount = { [weak self] in
                self?.showPlaidAccountPopup()
            }
            
            view.errorLinkCallback = { [weak self] in
                self?.onPaymentMethodErrorLinkTapped()
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
                                       axis: .vertical))
            view.setup(with: model)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, labelCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? LabelViewModel,
              let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(font: Fonts.Body.three,
                                       textColor: Colors.Text.two))
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, segmentControlCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<SegmentControl> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? SegmentControlViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
            view.didChangeValue = { [weak self] segment in
                self?.view.endEditing(true)
                self?.setSegment(segment)
            }
        }
        
        return cell
    }
    
    func setSegment(_ segment: Int) {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.segment.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<SegmentControl> else { return }
        cell.wrappedView.selectSegment(index: segment)
        
        let paymentTypes = PaymentCard.PaymentType.allCases
        if paymentTypes.count >= segment {
            let paymentType = paymentTypes[segment]
            
            LoadingView.show()
            (interactor as? (any PaymentMethodsViewActions))?.selectPaymentMethod(viewAction: .init(method: paymentType))
            GoogleAnalytics.logEvent(GoogleAnalytics.Buy(type: paymentType.rawValue))
        }
    }
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        switch self {
        case is SwapViewController,
            is BuyViewController,
            is SellViewController,
            is TransferFundsViewController:
            continueButton.configure(with: Presets.Button.primary)
            continueButton.setup(with: .init(title: L10n.Button.confirm,
                                             enabled: false,
                                             callback: { [weak self] in
                self?.buttonTapped()
            }))
            
            guard let config = continueButton.config, let model = continueButton.viewModel else { return }
            verticalButtons.wrappedView.configure(with: .init(buttons: [config]))
            verticalButtons.wrappedView.setup(with: .init(buttons: [model]))
            
        default:
            return
        }
    }
    
    override func displayMessage(responseDisplay: MessageModels.ResponseDisplays) {
        super.displayMessage(responseDisplay: responseDisplay)
        
        let error = responseDisplay.error as? NetworkingError
        
        switch error?.errorType {
        case .twoStepRequired:
            (coordinator as? BaseCoordinator)?.openModally(coordinator: AccountCoordinator.self, scene: Scenes.RegistrationConfirmation) { vc in
                vc?.dataStore?.confirmationType = error == .twoStepAppRequired ? .twoStepAppRequired : .twoStepEmailRequired
                vc?.isModalDismissable = true
                
                vc?.didDismiss = { didDismissSuccessfully in
                    guard didDismissSuccessfully else { return }
                    
                    switch vc?.dataStore?.confirmationType {
                    case .twoStepAppBackupCode:
                        (self.dataStore as? (any AssetDataStore))?.secondFactorBackup = vc?.dataStore?.code
                        
                    default:
                        (self.dataStore as? (any AssetDataStore))?.secondFactorCode = vc?.dataStore?.code
                    }
                    
                    (self.interactor as? (any AssetViewActions))?.getExchangeRate(viewAction: .init(getFees: true), completion: {})
                }
            }
            
        default:
            break
        }
    }
    
    func getRateAndTimerCell() -> WrapperTableViewCell<ExchangeRateView>? {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.rateAndTimer.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<ExchangeRateView> else {
            continueButton.viewModel?.enabled = false
            verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
            
            return nil
        }
        
        return cell
    }
    
    func getAccountLimitsCell() -> WrapperTableViewCell<FELabel>? {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.accountLimits.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<FELabel> else {
            return nil
        }
        return cell
    }
    
    func displayAmount(responseDisplay: AssetModels.Asset.ResponseDisplay) {
        LoadingView.hideIfNeeded()
    }
    
    func onPaymentMethodErrorLinkTapped() {}
    func limitsInfoTapped() {}
    func increaseLimitsTapped() {}
    func showPlaidAccountPopup() {}
}
