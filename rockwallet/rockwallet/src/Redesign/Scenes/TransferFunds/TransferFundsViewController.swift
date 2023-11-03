//
//  TransferFundsViewController.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 21.9.23.
//
//

import UIKit

class TransferFundsViewController: BaseExchangeTableViewController<ExchangeCoordinator,
                                   TransferFundsInteractor,
                                   TransferFundsPresenter,
                                   TransferFundsStore>,
                                   TransferFundsResponseDisplays {
    typealias Models = AssetModels

    // MARK: - Overrides
    override var sceneLeftAlignedTitle: String? {
        return L10n.Button.transferFunds
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .transferFunds:
            cell = self.tableView(tableView, transferFundsCellForRowAt: indexPath)
            cell.contentView.setupCustomMargins(vertical: .large, horizontal: .large)
            
        case .swapCard:
            cell = self.tableView(tableView, cryptoSelectionCellForRowAt: indexPath)
            cell.contentView.setupCustomMargins(vertical: .zero, horizontal: .large)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(all: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, transferFundsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? SwitchFromToHorizontalViewModel,
              let cell: WrapperTableViewCell<SwitchFromToHorizontalView> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
            view.didTapSwitchPlacesButton = { [weak self] in
                self?.interactor?.switchPlaces(viewAction: .init(isDeposit: self?.dataStore?.isDeposit))
            }
        }
        cell.setupCustomMargins(vertical: .small, horizontal: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cryptoSelectionCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<SwapCurrencyView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? SwapCurrencyViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(shadow: Presets.ExchangeView.shadow,
                                       background: Presets.ExchangeView.background))
            view.setup(with: model)
            
            view.didChangeFiatAmount = { [weak self] value in
                self?.interactor?.setAmount(viewAction: .init(fromFiatValue: value))
            }
            
            view.didChangeCryptoAmount = { [weak self] value in
                self?.interactor?.setAmount(viewAction: .init(fromTokenValue: value))
            }
            
            view.didFinish = { [weak self] _ in
                self?.interactor?.setAmount(viewAction: .init(didFinish: true))
            }
            
            view.didTapSelectAsset = { [weak self] in
                self?.interactor?.navigateAssetSelector(viewAction: .init())
            }
        }
        
        cell.setupCustomMargins(vertical: .small, horizontal: .large)
        
        return cell
    }

    // MARK: - User Interaction
    
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.showConfirmation(viewAction: .init())
    }

    // MARK: - TransferFundsResponseDisplay
    
    func displayNavigateAssetSelector(responseDisplay: TransferFundsModels.AssetSelector.ResponseDisplay) {
           coordinator?.showAssetSelector(title: responseDisplay.title,
                                          currencies: dataStore?.currencies,
                                          supportedCurrencies: dataStore?.supportedCurrencies) { [weak self] model in
               guard let model = model as? AssetViewModel else { return }
               
               guard !model.isDisabled else {
                   self?.interactor?.showAssetSelectionMessage(viewAction: .init())
                   
                   return
               }
                 
               self?.coordinator?.dismissFlow()
               self?.interactor?.setAssetSelectionData(viewAction: .init(currency: model.subtitle, balanceValue: model.topRightText, didFinish: true))
           }
       }
    
    override func displayAmount(responseDisplay: AssetModels.Asset.ResponseDisplay) {
        super.displayAmount(responseDisplay: responseDisplay)
        
        guard let section = sections.firstIndex(where: { $0.hashValue == AssetModels.Section.swapCard.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<SwapCurrencyView> else { return }
        
        cell.wrappedView.setup(with: responseDisplay.swapCurrencyViewModel)
        
        tableView.invalidateTableViewIntrinsicContentSize()
        
        continueButton.viewModel?.enabled = true // responseDisplay.continueEnabled
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
    
    func displaySwitchPlaces(responseDisplay: TransferFundsModels.SwitchPlaces.ResponseDisplay) {
        guard let section = sections.firstIndex(where: { $0.hashValue == AssetModels.Section.transferFunds.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<SwitchFromToHorizontalView> else { return }
        
        cell.wrappedView.setup(with: responseDisplay.mainHorizontalViewModel)
        tableView.invalidateTableViewIntrinsicContentSize()
    }
    
    func displayAssetSelectionMessage(responseDisplay: TransferFundsModels.AssetSelectionMessage.ResponseDisplay) {
        coordinator?.showToastMessage(model: responseDisplay.model, configuration: responseDisplay.config)
    }
    
    func displayConfirmTransfer(responseDisplay: TransferFundsModels.ConfirmTransfer.ResponseDisplay) {
        guard let navigationController = coordinator?.navigationController else { return }
        
        coordinator?.showPopup(on: navigationController,
                               blurred: false,
                               with: responseDisplay.popupViewModel,
                               config: responseDisplay.popupConfig,
                               closeButtonCallback: { [weak self] in
            self?.coordinator?.dismissFlow()
        }, callbacks: [ { [weak self] in
            self?.coordinator?.dismissFlow()
        } ])
    }
    
    func displayConfirmation(responseDisplay: TransferFundsModels.ShowConfirmDialog.ResponseDisplay) {
        let _: WrapperPopupView<SwapConfirmationView>? = coordinator?.showPopup(with: responseDisplay.config,
                                                                                viewModel: responseDisplay.viewModel,
                                                                                confirmedCallback: { [weak self] in
            self?.coordinator?.showPinInput(keyStore: self?.dataStore?.keyStore) { success in
                if success {
                    LoadingView.show()
                    self?.interactor?.confirm(viewAction: .init())
                    
                } else {
                    self?.coordinator?.dismissFlow()
                }
            }
        })
    }
    
    func displayConfirm(responseDisplay: TransferFundsModels.Confirm.ResponseDisplay) {
        LoadingView.hideIfNeeded()
        
        coordinator?.dismissFlow()
    }
    
    // MARK: - Additional Helpers
}
