//
//  BuyViewController.swift
//  breadwallet
//
//  Created by Rok on 01/08/2022.
//
//

import UIKit
import LinkKit

protocol LinkOAuthHandling {
    var linkHandler: Handler? { get }
}

class BuyViewController: BaseTableViewController<BuyCoordinator, BuyInteractor, BuyPresenter, BuyStore>, BuyResponseDisplays {
    
    typealias Models = BuyModels
    
    lazy var continueButton: WrapperView<FEButton> = {
        let button = WrapperView<FEButton>()
        return button
    }()
    
    var linkHandler: Handler?
    var didTriggerGetData: (() -> Void)?
    private var supportedCurrencies: [SupportedCurrency]?
    
    // MARK: - Overrides
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        getRateAndTimerCell()?.wrappedView.invalidate()
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<FESegmentControl>.self)
        tableView.register(WrapperTableViewCell<SwapCurrencyView>.self)
        tableView.register(WrapperTableViewCell<CardSelectionView>.self)
        tableView.delaysContentTouches = false
        
        // TODO: Same code as CheckListViewController. Refactor
        view.addSubview(continueButton)
        continueButton.snp.makeConstraints { make in
            make.centerX.leading.equalToSuperview()
            make.bottom.equalTo(view.snp.bottomMargin)
        }
        
        continueButton.wrappedView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.Common.largeCommon.rawValue)
            make.edges.equalTo(continueButton.snp.margins)
        }
        
        continueButton.setupCustomMargins(top: .small, leading: .large, bottom: .large, trailing: .large)
        
        tableView.snp.remakeConstraints { make in
            make.leading.centerX.top.equalToSuperview()
            make.bottom.equalTo(continueButton.snp.top)
        }
        
        continueButton.wrappedView.configure(with: Presets.Button.primary)
        continueButton.wrappedView.setup(with: .init(title: L10n.Button.continueAction, enabled: false))
        continueButton.wrappedView.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        didTriggerGetData = { [weak self] in
            self?.interactor?.getData(viewAction: .init())
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Sections {
        case .segment:
            cell = self.tableView(tableView, segmentControlCellForRowAt: indexPath)
            
        case .accountLimits:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .rateAndTimer:
            cell = self.tableView(tableView, timerCellForRowAt: indexPath)

        case .from:
            cell = self.tableView(tableView, cryptoSelectionCellForRowAt: indexPath)

        case .paymentMethod:
            cell = self.tableView(tableView, paymentSelectionCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(all: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cryptoSelectionCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<SwapCurrencyView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? SwapCurrencyViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(shadow: Presets.ExchangeView.shadow,
                                       background: Presets.ExchangeView.background))
            view.setup(with: model)
            
            view.didChangeFiatAmount = { [weak self] value in
                self?.interactor?.setAmount(viewAction: .init(fiatValue: value))
            }
            
            view.didChangeCryptoAmount = { [weak self] value in
                self?.interactor?.setAmount(viewAction: .init(tokenValue: value))
            }
            
            view.didFinish = { [weak self] _ in
                self?.interactor?.setAmount(viewAction: .init())
            }
            
            view.didTapSelectAsset = { [weak self] in
                self?.interactor?.navigateAssetSelector(viewAction: .init())
            }
            
            view.setupCustomMargins(top: .zero, leading: .zero, bottom: .medium, trailing: .zero)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, paymentSelectionCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<CardSelectionView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? CardSelectionViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
            view.didTapSelectCard = { [weak self] in
                switch self?.dataStore?.paymentSegmentValue {
                case .ach:
                    self?.interactor?.getLinkToken(viewAction: .init())
                default:
                    self?.interactor?.getPaymentCards(viewAction: .init())
                }
            }
            
            view.setupCustomMargins(top: .zero, leading: .zero, bottom: .medium, trailing: .zero)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, segmentControlCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<FESegmentControl> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? SegmentControlViewModel
        else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
            view.didChangeValue = { [weak self] segment in
                self?.view.endEditing(true)
                self?.interactor?.setAmount(viewAction: .init(paymentSegmentValue: segment))
            }
        }
        
        return cell
    }
    
    private func getRateAndTimerCell() -> WrapperTableViewCell<ExchangeRateView>? {
        guard let section = sections.firstIndex(of: Models.Sections.rateAndTimer),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<ExchangeRateView> else {
            continueButton.wrappedView.isEnabled = false
            
            return nil
        }
        
        return cell
    }
    
    // MARK: - User Interaction

    @objc override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.showOrderPreview(viewAction: .init())
    }
    
    // MARK: - BuyResponseDisplay
    
    func displayNavigateAssetSelector(responseDisplay: BuyModels.AssetSelector.ResponseDisplay) {
        switch dataStore?.paymentSegmentValue {
        case .ach:
            if let usdCurrency = dataStore?.supportedCurrencies?.first(where: {$0.name == "USDC" }) {
                supportedCurrencies = [usdCurrency]
            }
        default:
            supportedCurrencies = dataStore?.supportedCurrencies
        }
        
        coordinator?.showAssetSelector(title: responseDisplay.title,
                                       currencies: dataStore?.currencies,
                                       supportedCurrencies: supportedCurrencies) { [weak self] item in
            guard let item = item as? AssetViewModel else { return }
            self?.interactor?.setAssets(viewAction: .init(currency: item.subtitle))
        }
    }
    
    func displayPaymentCards(responseDisplay: BuyModels.PaymentCards.ResponseDisplay) {
        view.endEditing(true)
        
        coordinator?.showCardSelector(cards: responseDisplay.allPaymentCards, selected: { [weak self] selectedCard in
            self?.interactor?.setAssets(viewAction: .init(card: selectedCard))
        })
    }
    
    func displayAssets(responseDisplay actionResponse: BuyModels.Assets.ResponseDisplay) {
        guard let fromSection = sections.firstIndex(of: Models.Sections.from),
              let toSection = sections.firstIndex(of: Models.Sections.paymentMethod),
              let fromCell = tableView.cellForRow(at: .init(row: 0, section: fromSection)) as? WrapperTableViewCell<SwapCurrencyView>,
              let toCell = tableView.cellForRow(at: .init(row: 0, section: toSection)) as? WrapperTableViewCell<CardSelectionView>
        else { return continueButton.wrappedView.isEnabled = false }
        
        fromCell.wrappedView.setup(with: actionResponse.cryptoModel)
        toCell.wrappedView.setup(with: actionResponse.cardModel)
        
        continueButton.wrappedView.isEnabled = dataStore?.isFormValid ?? false
    }
    
    func displayExchangeRate(responseDisplay: BuyModels.Rate.ResponseDisplay) {
        tableView.beginUpdates()
        
        if let cell = getRateAndTimerCell() {
            cell.setup { view in
                view.setup(with: responseDisplay.rate)
                
                view.completion = { [weak self] in
                    self?.interactor?.getExchangeRate(viewAction: .init())
                }
            }
        } else {
            continueButton.wrappedView.isEnabled = false
        }
        
        if let section = sections.firstIndex(of: Models.Sections.accountLimits),
           let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<FELabel> {
            cell.setup { view in
                view.setup(with: responseDisplay.limits)
            }
        }
        
        tableView.endUpdates()
    }
    
    func displayOrderPreview(responseDisplay: BuyModels.OrderPreview.ResponseDisplay) {
        coordinator?.showOrderPreview(coreSystem: dataStore?.coreSystem,
                                      keyStore: dataStore?.keyStore,
                                      to: dataStore?.toAmount,
                                      from: dataStore?.from,
                                      card: dataStore?.paymentCard,
                                      quote: dataStore?.quote)
    }
    
    func displayLinkToken(responseDisplay: BuyModels.PlaidLinkToken.ResponseDisplay) {
        presentPlaidLinkUsingLinkToken(linkToken: responseDisplay.linkToken)
    }
    
    override func displayMessage(responseDisplay: MessageModels.ResponseDisplays) {
        if responseDisplay.error != nil {
            LoadingView.hide()
        }
        
        guard !isAccessDenied(responseDisplay: responseDisplay) else { return }
        
        guard responseDisplay.error != nil else {
            coordinator?.hideMessage()
            return
        }
        
        continueButton.wrappedView.isEnabled = false
        coordinator?.showMessage(with: responseDisplay.error,
                                 model: responseDisplay.model,
                                 configuration: responseDisplay.config)
    }
    
    // MARK: - Additional Helpers
    
    // MARK: Start Plaid Link using a Link token
    func createLinkTokenConfiguration(linkToken: String) -> LinkTokenConfiguration {
        var linkConfiguration = LinkTokenConfiguration(token: linkToken) { success in
            print("public-token: \(success.publicToken) metadata: \(success.metadata)")
        }
        
        linkConfiguration.onExit = { exit in
            if let error = exit.error {
                print("exit with \(error)\n\(exit.metadata)")
            } else {
                print("exit with \(exit.metadata)")
            }
        }
        
        linkConfiguration.onEvent = { event in
            print("Link Event: \(event)")
        }
        
        return linkConfiguration
    }
    
    func presentPlaidLinkUsingLinkToken(linkToken: String) {
        let linkConfiguration = createLinkTokenConfiguration(linkToken: linkToken)
        let result = Plaid.create(linkConfiguration)
        switch result {
        case .failure(let error):
            print("Unable to create Plaid handler due to: \(error)")
        case .success(let handler):
            handler.open(presentUsing: .viewController(self))
            linkHandler = handler
        }
    }
}
