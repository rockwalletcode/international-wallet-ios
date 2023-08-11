//
//  SwapViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class SwapViewController: BaseExchangeTableViewController<ExchangeCoordinator,
                          SwapInteractor,
                          SwapPresenter,
                          SwapStore>,
                          SwapResponseDisplays {
    typealias Models = AssetModels
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.HomeScreen.trade
    }
    
    // MARK: - Overrides
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .rateAndTimer:
            cell = self.tableView(tableView, timerCellForRowAt: indexPath)
            cell.contentView.setupCustomMargins(top: .large, leading: .large, bottom: .extraSmall, trailing: .large)
            
        case .swapCard:
            cell = self.tableView(tableView, swapMainCellForRowAt: indexPath)
            cell.contentView.setupCustomMargins(vertical: .zero, horizontal: .large)
            
        case .accountLimits:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            cell.contentView.setupCustomMargins(vertical: .extraSmall, horizontal: .huge)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(all: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, swapMainCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<MainSwapView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? MainSwapViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(shadow: Presets.ExchangeView.shadow,
                                       background: Presets.ExchangeView.background))
            view.setup(with: model)
            
            view.didChangeFromFiatAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(fromFiatValue: amount))
            }
            
            view.didChangeFromCryptoAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(fromTokenValue: amount))
            }
            
            view.didChangeToFiatAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(toFiatValue: amount))
            }
            
            view.didChangeToCryptoAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(toTokenValue: amount))
            }
            
            view.didTapFromAssetsSelection = { [weak self] in
                self?.interactor?.selectAsset(viewAction: .init(from: true))
            }
            
            view.didTapToAssetsSelection = { [weak self] in
                self?.interactor?.selectAsset(viewAction: .init(to: true))
            }
            
            view.didFinish = { [weak self] didSwitchPlaces in
                if didSwitchPlaces, let cell = self?.getRateAndTimerCell() {
                    cell.setup { view in
                        view.invalidate()
                    }
                    
                    self?.interactor?.switchPlaces(viewAction: .init())
                } else {
                    self?.interactor?.prepareFees(viewAction: .init(), completion: {})
                }
            }
            
            view.contentSizeChanged = { [weak self] in
                self?.tableView.invalidateTableViewIntrinsicContentSize()
            }
            
            view.setupCustomMargins(top: .zero, leading: .zero, bottom: .medium, trailing: .zero)
        }
        
        return cell
    }
    
    // MARK: - User Interaction

    @objc override func buttonTapped() {
        super.buttonTapped()
        
        ToastMessageManager.shared.hide()
        
        interactor?.showConfirmation(viewAction: .init())
    }
    
    // MARK: - SwapResponseDisplay
    
    override func displayMessage(responseDisplay: MessageModels.ResponseDisplays) {
        switch responseDisplay.error as? ExchangeErrors {
        case .noQuote:
            displayExchangeRate(responseDisplay: .init(rateAndTimer: .init()), completion: {})
            
        case .failed:
            coordinator?.showFailure(reason: .swap)
            
        default:
            super.displayMessage(responseDisplay: responseDisplay)
        }
    }
    
    func displaySelectAsset(responseDisplay: SwapModels.Assets.ResponseDisplay) {
        view.endEditing(true)
        
        ToastMessageManager.shared.hide()
        
        coordinator?.showAssetSelector(title: responseDisplay.title,
                                       currencies: responseDisplay.to ?? responseDisplay.from,
                                       supportedCurrencies: dataStore?.supportedCurrencies,
                                       selected: { [weak self] model in
            guard let model = model as? AssetViewModel else { return }
            
            guard !model.isDisabled else {
                self?.interactor?.showAssetSelectionMessage(viewAction: .init(selectedDisabledAsset: model))
                
                return
            }
            
            self?.coordinator?.dismissFlow()
            
            guard responseDisplay.from?.isEmpty == false else {
                self?.interactor?.assetSelected(viewAction: .init(to: model.subtitle))
                return
            }
            self?.interactor?.assetSelected(viewAction: .init(from: model.subtitle))
        })
    }
    
    func displayAssetSelectionMessage(responseDisplay: SwapModels.AssetSelectionMessage.ResponseDisplay) {
        coordinator?.showToastMessage(model: responseDisplay.model, configuration: responseDisplay.config)
    }
    
    func displayConfirmation(responseDisplay: SwapModels.ShowConfirmDialog.ResponseDisplay) {
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
    
    func displayConfirm(responseDisplay: SwapModels.Confirm.ResponseDisplay) {
        LoadingView.hideIfNeeded()
        coordinator?.showSwapInfo(from: responseDisplay.from, to: responseDisplay.to, exchangeId: responseDisplay.exchangeId)
    }
    
    func displayError(responseDisplay: SwapModels.ErrorPopup.ResponseDisplay) {
        interactor?.showAssetInfoPopup(viewAction: .init())
    }
    
    func displayAssetInfoPopup(responseDisplay: SwapModels.AssetInfoPopup.ResponseDisplay) {
        coordinator?.showPopup(on: self,
                               blurred: true,
                               with: responseDisplay.popupViewModel,
                               config: responseDisplay.popupConfig,
                               closeButtonCallback: coordinator?.dismissFlow,
                               callbacks: [ { [weak self] in
            self?.coordinator?.dismissFlow()
        }])
    }
    
    func displayAmount(responseDisplay: AssetModels.Asset.ResponseDisplay) {
        LoadingView.hideIfNeeded()
        
        guard let section = sections.firstIndex(where: { $0.hashValue == AssetModels.Section.swapCard.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<MainSwapView> else { return }
        
        cell.wrappedView.setup(with: responseDisplay.mainSwapViewModel)
        
        tableView.invalidateTableViewIntrinsicContentSize()
        
        continueButton.viewModel?.enabled = responseDisplay.continueEnabled
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
    
    // MARK: - Additional Helpers
}
