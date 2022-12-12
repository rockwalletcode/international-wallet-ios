//
//  SellViewController.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import UIKit

class SellViewController: BaseTableViewController<SellCoordinator,
                          SellInteractor,
                          SellPresenter,
                          SellStore>,
                          SellResponseDisplays {
    
    typealias Models = SellModels
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Sell.title
    }
    
    var didTriggerGetExchangeRate: (() -> Void)?
    
    lazy var continueButton: FEButton = {
        let view = FEButton()
        return view
    }()
    
    // MARK: - Overrides
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        interactor?.getExchangeRate(viewAction: .init())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        getRateAndTimerCell()?.wrappedView.invalidate()
    }
    
    override func prepareData() {
        super.prepareData()
        
        guard let token = dataStore?.currency else { return }
        
        sections = [
            Models.Sections.rateAndTimer,
            Models.Sections.swapCard,
            Models.Sections.payoutMethod,
            Models.Sections.accountLimits
        ]
        
        sectionRows = [
            Models.Sections.rateAndTimer: [
                ExchangeRateViewModel(exchangeRate: "1USDC = 0.9 USD",
                                      timer: .init(till: 56, repeats: false),
                                      showTimer: true)
            ],
            Models.Sections.swapCard: [
                MainSwapViewModel(from: .init(amount: .zero(token),
                                              formattedTokenString: .init(string: ""),
                                              title: .text("I have 10.12000473 USDC")),
                                  
                                  to: .init(currencyCode: C.usdCurrencyCode,
                                            currencyImage: Asset.us.image,
                                            formattedTokenString: .init(string: ""),
                                            title: .text("I receive")),
                                 hideSwapButton: true)
            ],
            Models.Sections.payoutMethod: [
                CardSelectionViewModel(title: .text("Withdraw to"),
                                  subtitle: nil,
                                  logo: .image(Asset.bank.image),
                                  cardNumber: .text("John Jeffery account - **241"),
                                  userInteractionEnabled: false)
            ],
            Models.Sections.accountLimits: [
                LabelViewModel.text("")
            ]
        ]
        
        tableView.reloadData()
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<MainSwapView>.self)
        tableView.register(WrapperTableViewCell<CardSelectionView>.self)
            
        tableView.delaysContentTouches = false
        
    }
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        continueButton.configure(with: Presets.Button.primary)
        continueButton.setup(with: .init(title: L10n.Button.confirm,
                                         enabled: true,
                                         callback: { [weak self] in
            self?.buttonTapped()
        }))
        
        guard let config = continueButton.config, let model = continueButton.viewModel else { return }
        verticalButtons.wrappedView.configure(with: .init(buttons: [config]))
        verticalButtons.wrappedView.setup(with: .init(buttons: [model]))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch sections[indexPath.section] as? Models.Sections {
        case .accountLimits:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .rateAndTimer:
            cell = self.tableView(tableView, timerCellForRowAt: indexPath)
            
        case .swapCard:
            cell = self.tableView(tableView, swapMainCellForRowAt: indexPath)
            
        case .payoutMethod:
            cell = self.tableView(tableView, paymentSelectionCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .zero, horizontal: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, swapMainCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        guard let cell: WrapperTableViewCell<MainSwapView> = tableView.dequeueReusableCell(for: indexPath),
              let model = sectionRows[section]?[indexPath.row] as? MainSwapViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(shadow: Presets.ExchangeView.shadow,
                                       background: Presets.ExchangeView.background))
            view.setup(with: model)
            
            view.didChangeFromCryptoAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(from: amount))
            }
            
            view.didChangeToCryptoAmount = { [weak self] amount in
                self?.interactor?.setAmount(viewAction: .init(to: amount))
            }
            
            view.contentSizeChanged = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
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
            
            //            view.didTapSelectCard = { [weak self] in
            //                switch self?.dataStore?.paymentMethod {
            //                case .buyAch:
            //                    self?.interactor?.getLinkToken(viewAction: .init())
            //                default:
            //                    self?.interactor?.getPaymentCards(viewAction: .init(getCards: true))
            //                }
            //            }
            
            view.setupCustomMargins(top: .zero, leading: .zero, bottom: .medium, trailing: .zero)
        }
        return cell
    }
    
    func getRateAndTimerCell() -> WrapperTableViewCell<ExchangeRateView>? {
        guard let section = sections.firstIndex(of: Models.Sections.rateAndTimer),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<ExchangeRateView> else {
            return nil
        }
        
        return cell
    }
    
    func getAccountLimitsCell() -> WrapperTableViewCell<FELabel>? {
        guard let section = sections.firstIndex(of: Models.Sections.accountLimits),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<FELabel> else {
            return nil
        }
        return cell
    }
    
    // MARK: - User Interaction
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        coordinator?.showOrderPreview(crypto: dataStore?.fromAmount, quote: dataStore?.quote)
    }
    
    // MARK: - SellResponseDisplay
    
    func displayAmount(responseDisplay: Models.Amounts.ResponseDisplay) {
        // TODO: Extract to VIPBaseViewController
        LoadingView.hide()
        
        continueButton.viewModel?.enabled = responseDisplay.continueEnabled
        verticalButtons.wrappedView.getButton(continueButton)?.setup(with: continueButton.viewModel)
        
        tableView.beginUpdates()
        
        guard let section = sections.firstIndex(of: Models.Sections.swapCard),
              let cell = tableView.cellForRow(at: .init(row: 0, section: section)) as? WrapperTableViewCell<MainSwapView> else { return }
        
        cell.wrappedView.setup(with: responseDisplay.amounts)
        
        tableView.endUpdates()
    }
}
