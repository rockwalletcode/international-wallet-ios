//
//  BuyViewController.swift
//  breadwallet
//
//  Created by Rok on 01/08/2022.
//
//

import UIKit
import LinkKit

typealias PlaidLinkKitHandler = Handler

protocol LinkOAuthHandling {
    var plaidHandler: PlaidLinkKitHandler? { get }
}

class BuyViewController: BaseExchangeTableViewController<ExchangeCoordinator,
                         BuyInteractor,
                         BuyPresenter,
                         BuyStore>,
                         BuyResponseDisplays,
                         Subscriber {
    typealias Models = AssetModels
    
    override var sceneLeftAlignedTitle: String? {
        return dataStore?.canUseAch == true ? nil : L10n.Button.buy
    }
    
    var plaidHandler: LinkKit.Handler?
    
    // MARK: - Overrides
    
    override func prepareData() {
        super.prepareData()
        
        GoogleAnalytics.logEvent(GoogleAnalytics.Buy(type: dataStore?.paymentMethod?.rawValue ?? ""))
        
        Store.subscribe(self, name: .reloadBuy) { [weak self] _ in
            self?.interactor?.getData(viewAction: .init())
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .segment:
            cell = self.tableView(tableView, segmentControlCellForRowAt: indexPath)
            
        case .rateAndTimer:
            cell = self.tableView(tableView, timerCellForRowAt: indexPath)
            cell.contentView.setupCustomMargins(top: .small, leading: .large, bottom: .extraSmall, trailing: .large)
            
        case .swapCard:
            cell = self.tableView(tableView, cryptoSelectionCellForRowAt: indexPath)
            cell.contentView.setupCustomMargins(vertical: .zero, horizontal: .large)
            
        case .paymentMethod:
            cell = self.tableView(tableView, paymentSelectionCellForRowAt: indexPath)
            cell.contentView.setupCustomMargins(vertical: .small, horizontal: .large)
            
        case .accountLimits:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            cell.contentView.setupCustomMargins(vertical: .extraSmall, horizontal: .huge)
            
        case .limitActions:
            cell = self.tableView(tableView, multipleButtonsCellForRowAt: indexPath)
            cell.contentView.setupCustomMargins(vertical: .extraSmall, horizontal: .huge)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(all: .large)
        
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
            
            view.didTapHeaderInfoButton = { [weak self] in
                self?.interactor?.showInstantAchPopup(viewAction: .init())
            }
        }
        
        cell.setupCustomMargins(vertical: .small, horizontal: .large)
        
        return cell
    }
    
    override func setSegment(_ segment: Int) {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.segment.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<SegmentControl> else { return }
        cell.wrappedView.selectSegment(index: segment)
        
        let paymentTypes = PaymentCard.PaymentType.allCases
        if paymentTypes.count >= segment {
            let paymentType = paymentTypes[segment]
            
            interactor?.selectPaymentMethod(viewAction: .init(method: paymentType))
            GoogleAnalytics.logEvent(GoogleAnalytics.Buy(type: paymentType.rawValue))
        }
    }
    
    // MARK: - User Interaction
    
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.showOrderPreview(viewAction: .init())
    }
    
    override func increaseLimitsTapped() {
        coordinator?.showInWebView(urlString: Constant.limits, title: L10n.Buy.increaseYourLimits)
    }
    
    override func limitsInfoTapped() {
        interactor?.showLimitsInfo(viewAction: .init())
    }
    
    override func onPaymentMethodErrorLinkTapped() {
        coordinator?.showPaymentMethodSupport()
    }
    
    // MARK: - BuyResponseDisplay
    
    func displayNavigateAssetSelector(responseDisplay: BuyModels.AssetSelector.ResponseDisplay) {
        coordinator?.showAssetSelector(title: responseDisplay.title,
                                       currencies: dataStore?.currencies,
                                       supportedCurrencies: dataStore?.supportedCurrencies) { [weak self] model in
            guard let model = model as? AssetViewModel else { return }
            
            guard !model.isDisabled else {
                self?.interactor?.showAssetSelectionMessage(viewAction: .init())
                
                return
            }
            
            self?.coordinator?.dismissFlow()
            self?.interactor?.setAmount(viewAction: .init(currency: model.subtitle, didFinish: true))
        }
    }
    
    func displayAssetSelectionMessage(responseDisplay: BuyModels.AssetSelectionMessage.ResponseDisplay) {
        coordinator?.showToastMessage(model: responseDisplay.model, configuration: responseDisplay.config)
    }
    
    func displayAmount(responseDisplay: AssetModels.Asset.ResponseDisplay) {
        guard let fromSection = sections.firstIndex(where: { $0.hashValue == Models.Section.swapCard.hashValue }),
              let toSection = sections.firstIndex(where: { $0.hashValue == Models.Section.paymentMethod.hashValue }),
              let limitActionsSection = sections.firstIndex(where: { $0.hashValue == Models.Section.limitActions.hashValue }),
              let fromCell = tableView.cellForRow(at: IndexPath(row: 0, section: fromSection)) as? WrapperTableViewCell<SwapCurrencyView>,
              let toCell = tableView.cellForRow(at: IndexPath(row: 0, section: toSection)) as? WrapperTableViewCell<CardSelectionView>,
              let limitActionsCell = tableView.cellForRow(at: IndexPath(row: 0, section: limitActionsSection)) as? WrapperTableViewCell<MultipleButtonsView> else {
            continueButton.viewModel?.enabled = false
            verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
            
            return
        }
        
        sectionRows[fromSection] = [responseDisplay.swapCurrencyViewModel as Any]
        sectionRows[toSection] = [responseDisplay.cardModel as Any]
        sectionRows[limitActionsSection] = [responseDisplay.limitActions as Any]
        
        fromCell.wrappedView.setup(with: responseDisplay.swapCurrencyViewModel)
        toCell.wrappedView.setup(with: responseDisplay.cardModel)
        limitActionsCell.wrappedView.setup(with: responseDisplay.limitActions)
        
        tableView.invalidateTableViewIntrinsicContentSize()
        
        continueButton.viewModel?.enabled = dataStore?.isFormValid ?? false
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
    
    func displayOrderPreview(responseDisplay: BuyModels.OrderPreview.ResponseDisplay) {
        coordinator?.showOrderPreview(type: .buy,
                                      coreSystem: dataStore?.coreSystem,
                                      keyStore: dataStore?.keyStore,
                                      to: dataStore?.toAmount,
                                      from: dataStore?.from,
                                      card: dataStore?.selected,
                                      quote: dataStore?.quote,
                                      availablePayments: responseDisplay.availablePayments)
    }
    
    override func displayMessage(responseDisplay: MessageModels.ResponseDisplays) {
        super.displayMessage(responseDisplay: responseDisplay)
        
        continueButton.viewModel?.enabled = responseDisplay.error == nil && dataStore?.isFormValid == true
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
    
    func displayLimitsInfo(responseDisplay: BuyModels.LimitsInfo.ResponseDisplay) {
        let _: WrapperPopupView<LimitsPopupView>? = coordinator?.showPopup(with: responseDisplay.config,
                                                                           viewModel: responseDisplay.viewModel,
                                                                           confirmedCallback: { [weak self] in
            self?.coordinator?.dismissFlow()
        })
    }
    
    func displayInstantAchPopup(responseDisplay: BuyModels.InstantAchPopup.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model)
    }
    
    // MARK: - Additional Helpers
    
    func updatePaymentMethod(paymentMethod: PaymentCard.PaymentType?) {
        guard let filteredIndex = PaymentCard.PaymentType.allCases.firstIndex(where: { $0 == paymentMethod }) else { return }
        
        let paymentMethod = paymentMethod ?? .card
        
        interactor?.retryPaymentMethod(viewAction: .init(method: paymentMethod))
        
        setSegment(filteredIndex)
    }
}
