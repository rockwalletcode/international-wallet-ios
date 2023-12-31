//
//  AssetListTableView.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-12-04.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

class AssetListTableView: UITableViewController, Subscriber {

    var didSelectCurrency: ((Currency) -> Void)?
    var didTapAddWallet: (() -> Void)?
    var didReload: (() -> Void)?
    var didTapFaqButton: (() -> Void)?
    var isProWallet: Bool = false
    var proBalancesData: ProBalancesModel? {
        didSet {
            reload()
        }
    }
    
    private let loadingSpinner = UIActivityIndicatorView(style: .large)
    private let assetHeight: CGFloat = ViewSizes.extralarge.rawValue
    
    private lazy var manageAssetsButton: ManageAssetsButton = {
        let manageAssetsButton = ManageAssetsButton()
        let manageAssetsButtonTitle = L10n.MenuButton.manageAssets.uppercased()
        manageAssetsButton.set(title: manageAssetsButtonTitle)
        manageAssetsButton.accessibilityLabel = manageAssetsButtonTitle
        
        manageAssetsButton.didTap = { [weak self] in
            self?.addWallet()
        }
        
        return manageAssetsButton
    }()
    
    private lazy var footerView: UIView = {
        let footerView = UIView()
        footerView.backgroundColor = Colors.Background.cards
        
        return footerView
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Margins.large.rawValue
        stack.isHidden = true
        return stack
    }()
    
    private lazy var faqButton: FEButton = {
        let view = FEButton()
        view.configure(with: Presets.Button.blackIcon)
        view.configure(with: ButtonConfiguration(normalConfiguration: .init(tintColor: Colors.Outline.one)))
        view.setup(with: .init(title: L10n.Exchange.faqButton, isUnderlined: true))
        view.addTarget(self, action: #selector(faqButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var swipeLabel: UILabel = {
        let view = UILabel(font: Fonts.Body.two, color: Colors.Outline.one)
        view.text = L10n.Exchange.swipeDown
        view.textAlignment = .center
        return view
    }()
    
    // MARK: - Init
    
    init() {
        super.init(style: .plain)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Store.state.wallets.isEmpty {
            DispatchQueue.main.async { [weak self] in
                self?.showLoadingState(true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupAddWalletButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = Colors.Background.two
        tableView.register(HomeScreenCell.self, forCellReuseIdentifier: HomeScreenCellIds.regularCell.rawValue)
        tableView.separatorStyle = .none
        tableView.rowHeight = assetHeight
        tableView.contentInset.bottom = ViewSizes.Common.largeCommon.rawValue
        
        setupSubscriptions()
        reload()
    }
    
    private func setupAddWalletButton() {
        guard tableView.tableFooterView == nil else { return }
        
        let manageAssetsButtonHeight = ViewSizes.Common.largeCommon.rawValue
        let tableViewWidth = tableView.frame.width - tableView.contentInset.left - tableView.contentInset.right
        
        let footerView = UIView(frame: CGRect(x: 0,
                                              y: 0,
                                              width: tableViewWidth,
                                              height: manageAssetsButtonHeight + (Margins.large.rawValue * 2)))
        
        footerView.addSubview(manageAssetsButton)
        manageAssetsButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().inset(Margins.large.rawValue)
            make.centerY.equalToSuperview().inset(Margins.large.rawValue)
            make.width.equalTo(footerView.snp.width).inset(Margins.extraHuge.rawValue)
            make.height.equalTo(manageAssetsButtonHeight)
        }
        
        footerView.addSubview(buttonsStack)
        buttonsStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview().inset(Margins.large.rawValue)
            make.centerY.equalToSuperview().inset(Margins.large.rawValue)
            make.width.equalTo(footerView.snp.width).inset(Margins.extraHuge.rawValue)
            make.height.equalTo(manageAssetsButtonHeight)
        }
        
        footerView.addSubview(manageAssetsButton)
        footerView.addSubview(buttonsStack)
        buttonsStack.addArrangedSubview(faqButton)
        buttonsStack.addArrangedSubview(swipeLabel)
        
        tableView.tableFooterView = footerView
    }
    
    private func setupSubscriptions() {
        Store.lazySubscribe(self, selector: {
            self.mapWallets(state: $0, newState: $1)
        }, callback: { _ in
            self.reload()
        })
        
        Store.lazySubscribe(self, selector: {
            self.mapCurrencies(lhsCurrencies: $0.currencies, rhsCurrencies: $1.currencies)
        }, callback: { _ in
            self.reload()
        })
    }
    
    private func mapWallets(state: State, newState: State) -> Bool {
        var result = false
        let oldState = state
        let newState = newState
        
        state.wallets.values.map { $0.currency }.forEach { currency in
            if oldState[currency]?.balance != newState[currency]?.balance
                || oldState[currency]?.currentRate?.rate != newState[currency]?.currentRate?.rate {
                result = true
            }
        }
        
        return result
    }
    
    private func mapCurrencies(lhsCurrencies: [Currency], rhsCurrencies: [Currency]) -> Bool {
        return lhsCurrencies.map { $0.code } != rhsCurrencies.map { $0.code }
    }
    
    @objc func addWallet() {
        didTapAddWallet?()
    }
    
    func reload() {
        didReload?()
        showLoadingState(false)
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc func faqButtonTapped() {
        didTapFaqButton?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isProWallet ? Store.state.currenciesProWallet.count : Store.state.currencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currencies: [Currency] = isProWallet ? Store.state.currenciesProWallet : Store.state.currencies
        guard currencies.indices.contains(indexPath.row) else { return UITableViewCell() }
        
        let currency = currencies[indexPath.row]
        let viewModel = HomeScreenAssetViewModel(currency: currency, proBalancesData: proBalancesData)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeScreenCellIds.regularCell.rawValue, for: indexPath)
        
        if let cell = cell as? HomeScreenCell {
            cell.set(viewModel: viewModel, isProWallet: isProWallet)
            cell.removeProLabel(isHidden: !manageAssetsButton.isHidden)
        }
        
        return cell
    }
    
    // MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = Store.state.currencies[indexPath.row]
        // If a currency has a wallet, home screen cells are always tap-able
        // Also, if HBAR account creation is required, it is also tap-able
        guard (currency.wallet != nil) ||
            //Only an HBAR wallet requiring creation can go to the account screen without a wallet
            (currency.isHBAR && Store.state.requiresCreation(currency)) else { return }
        
        if !isProWallet {
            didSelectCurrency?(currency)
        }
        
        GoogleAnalytics.logEvent(GoogleAnalytics.DisplayCurrency())
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return assetHeight
    }
}

extension AssetListTableView {
    // Loading state management
    
    func showLoadingState(_ show: Bool) {
        showLoadingIndicator(show)
    }
    
    func showLoadingIndicator(_ show: Bool) {
        guard show else {
            tableView.isScrollEnabled = true
            loadingSpinner.removeFromSuperview()
            return
        }
        
        view.addSubview(loadingSpinner)
        tableView.isScrollEnabled = false
        
        loadingSpinner.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
        }
        
        loadingSpinner.startAnimating()
    }
    
    func showAddWalletsButton(_ show: Bool) {
        isProWallet = !show
        buttonsStack.isHidden = !isProWallet
        manageAssetsButton.isHidden = isProWallet
        
        reload()
    }
}
