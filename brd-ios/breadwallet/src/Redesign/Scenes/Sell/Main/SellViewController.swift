//
//  SellViewController.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit
import LinkKit

class SellViewController: BaseExchangeTableViewController<ExchangeCoordinator,
                          SellInteractor,
                          SellPresenter,
                          SellStore>,
                          SellResponseDisplays {
    typealias Models = AssetModels
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Sell.title
    }
    
    var plaidHandler: PlaidLinkKitHandler?
    
    // MARK: - Overrides
    
    override func prepareData() {
        super.prepareData()
        
        GoogleAnalytics.logEvent(GoogleAnalytics.Sell())
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
            cell = self.tableView(tableView, swapMainCellForRowAt: indexPath)
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
            
            view.didChangeFromCryptoAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(fromTokenValue: amount))
            }
            
            view.didChangeToCryptoAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(toFiatValue: amount))
            }
            
            view.didFinish = { [weak self] _ in
                self?.interactor?.setAmount(viewAction: .init(didFinish: true))
            }
            
            view.didTapFromAssetsSelection = { [weak self] in
                self?.interactor?.navigateAssetSelector(viewAction: .init())
            }
        }
        
        return cell
    }
    
    override func setSegment(_ segment: Int) {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.segment.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<SegmentControl> else { return }
        cell.wrappedView.selectSegment(index: segment)
        
        let paymentTypes = PaymentCard.PaymentType.allCases
        if paymentTypes.count >= segment {
            let paymentType = paymentTypes[segment]
            
            interactor?.selectPaymentMethod(viewAction: .init(method: paymentTypes[segment]))
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
    
    // MARK: - SellResponseDisplay
    
    func displayNavigateAssetSelector(responseDisplay: SellModels.AssetSelector.ResponseDisplay) {
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
    
    func displayAssetSelectionMessage(responseDisplay: SellModels.AssetSelectionMessage.ResponseDisplay) {
        coordinator?.showToastMessage(model: responseDisplay.model, configuration: responseDisplay.config)
    }
    
    func displayAmount(responseDisplay: AssetModels.Asset.ResponseDisplay) {
        guard let fromSection = sections.firstIndex(where: { $0.hashValue == Models.Section.swapCard.hashValue }),
              let toSection = sections.firstIndex(where: { $0.hashValue == Models.Section.paymentMethod.hashValue }),
              let limitActionsSection = sections.firstIndex(where: { $0.hashValue == Models.Section.limitActions.hashValue }),
              let fromCell = tableView.cellForRow(at: IndexPath(row: 0, section: fromSection)) as? WrapperTableViewCell<MainSwapView>,
              let toCell = tableView.cellForRow(at: IndexPath(row: 0, section: toSection)) as? WrapperTableViewCell<CardSelectionView>,
              let limitActionsCell = tableView.cellForRow(at: IndexPath(row: 0, section: limitActionsSection)) as? WrapperTableViewCell<MultipleButtonsView> else {
            continueButton.viewModel?.enabled = false
            verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
            
            return
        }
        
        sectionRows[fromSection] = [responseDisplay.swapCurrencyViewModel as Any]
        sectionRows[toSection] = [responseDisplay.cardModel as Any]
        sectionRows[limitActionsSection] = [responseDisplay.limitActions as Any]
        
        fromCell.wrappedView.setup(with: responseDisplay.mainSwapViewModel)
        toCell.wrappedView.setup(with: responseDisplay.cardModel)
        limitActionsCell.wrappedView.setup(with: responseDisplay.limitActions)
        
        tableView.invalidateTableViewIntrinsicContentSize()
        
        continueButton.viewModel?.enabled = dataStore?.isFormValid ?? false
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
    
    func displayOrderPreview(responseDisplay: SellModels.OrderPreview.ResponseDisplay) {
        dataStore?.createTransactionModel = .init(exchange: dataStore?.exchange,
                                                  currencies: dataStore?.currencies,
                                                  fromFeeAmount: dataStore?.fromFeeAmount,
                                                  fromAmount: dataStore?.fromAmount,
                                                  toAmountCode: Constant.usdCurrencyCode)
        
        coordinator?.showOrderPreview(type: .sell,
                                      coreSystem: dataStore?.coreSystem,
                                      keyStore: dataStore?.keyStore,
                                      to: dataStore?.fromAmount,
                                      from: dataStore?.toAmount,
                                      fromFeeBasis: dataStore?.fromFeeBasis,
                                      card: dataStore?.selected,
                                      quote: dataStore?.quote,
                                      availablePayments: responseDisplay.availablePayments,
                                      createTransactionModel: dataStore?.createTransactionModel)
    }
    
    override func displayMessage(responseDisplay: MessageModels.ResponseDisplays) {
        super.displayMessage(responseDisplay: responseDisplay)
        
        continueButton.viewModel?.enabled = responseDisplay.error == nil && dataStore?.isFormValid == true
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
    }
    
    func displayLimitsInfo(responseDisplay: SellModels.LimitsInfo.ResponseDisplay) {
        let _: WrapperPopupView<LimitsPopupView>? = coordinator?.showPopup(with: responseDisplay.config,
                                                                           viewModel: responseDisplay.viewModel,
                                                                           confirmedCallback: { [weak self] in
            self?.coordinator?.dismissFlow()
        })
    }
    
    func displayInstantAchPopup(responseDisplay: SellModels.InstantAchPopup.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model)
    }
}
