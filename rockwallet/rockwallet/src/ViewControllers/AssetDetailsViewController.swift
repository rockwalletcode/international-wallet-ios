//
//  AssetDetailsViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-16.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import Combine
import UIKit

class AssetDetailsViewController: UIViewController, Subscriber {
    
    // MARK: - Public
    
    var currency: Currency
    var coreSystem: CoreSystem?
    var keyStore: KeyStore?
    
    var paymailCallback: ((Bool) -> Void)?
    
    weak var coordinator: BaseCoordinator?
    
    private var drawerManager: BottomDrawerManager?
    
    init(currency: Currency, wallet: Wallet?) {
        self.wallet = wallet
        self.currency = currency
        self.headerView = AssetDetailsHeaderView(currency: currency)
        self.footerView = AssetDetailsFooterView(currency: currency)
        self.searchHeaderview = SearchHeaderView()
        
        super.init(nibName: nil, bundle: nil)
        
        transactionsTableView = TransactionsTableViewController(currency: currency,
                                                                wallet: wallet,
                                                                didSelectTransaction: { [unowned self] (transactions, index) in
            self.didSelectTransaction(transactions: transactions, selectedIndex: index)
        })
        
        // TODO: Lots of duplicated logic here. Check ApplicationController.
        footerView.actionPublisher.sink { [unowned self] action in
            if action != .buySell { drawerManager?.hideDrawer() }
            
            guard let coreSystem, let keyStore else { return }
            
            switch action {
            case .send:
                Store.perform(action: RootModalActions.Present(modal: .send(currency: self.currency, coordinator: self.coordinator)))
                
            case .receive:
                Store.perform(action: RootModalActions.Present(modal: .receive(currency: self.currency)))
                
            case .buySell:
                self.drawerManager?.toggleDrawer()
                
            case .swap:
                self.coordinator?.showSwap(selectedCurrency: currency,
                                           coreSystem: coreSystem,
                                           keyStore: keyStore)
                
            }
        }.store(in: &observers)
    }
    
    deinit {
        Store.unsubscribe(self)
    }
    
    // MARK: - Private
    
    private let headerView: AssetDetailsHeaderView
    private let footerView: AssetDetailsFooterView
    private var footerHeightConstraint: NSLayoutConstraint?
    private let transitionDelegate = ModalTransitionDelegate(type: .transactionDetail)
    private var transactionsTableView: TransactionsTableViewController?
    private let searchHeaderview: SearchHeaderView
    private let headerContainer = UIView()
    private var loadingTimer: Timer?
    private var isSearching = false
    private var shouldShowStatusBar = true {
        didSet {
            if oldValue != shouldShowStatusBar {
                UIView.animate(withDuration: Presets.Animation.short.rawValue) {
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            }
        }
    }
    
    private var observers: [AnyCancellable] = []
    
    private var wallet: Wallet? {
        didSet {
            if wallet != nil {
                transactionsTableView?.wallet = wallet
            }
        }
    }
    
    private var createTimeoutTimer: Timer? {
        willSet {
            createTimeoutTimer?.invalidate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        addSubviews()
        addConstraints()
        addTransactionsView()
        addSubscriptions()
        setInitialData()
        
        let drawerConfig = DrawerConfiguration(buttons: [Presets.Button.primary,
                                                         Presets.Button.primary,
                                                         Presets.Button.whiteBorderless])
        let drawerViewModel = DrawerViewModel(title: .text(L10n.Drawer.title),
                                              buttons: [.init(title: L10n.Buy.buyWithCard, image: Asset.card.image),
                                                        .init(title: L10n.Buy.buyWithAch, image: Asset.bank.image),
                                                        .init(title: L10n.Button.sell, image: Asset.remove.image)],
                                              onView: view,
                                              bottomInset: BottomDrawer.bottomToolbarHeight)
        let drawerCallbacks: [(() -> Void)] = [ { [weak self] in
            self?.didTapDrawerButton(.card)
        }, { [weak self] in
            self?.didTapDrawerButton(.ach)
        }, { [weak self]
            in self?.didTapDrawerButton()
        }]
        
        drawerManager = BottomDrawerManager()
        drawerManager?.setupDrawer(on: self, config: drawerConfig, viewModel: drawerViewModel, callbacks: drawerCallbacks) { [unowned self] drawer in
            drawer.dismissActionPublisher.sink {
            }.store(in: &self.observers)
        }
        view.bringSubviewToFront(footerView) // Put bottom toolbar in front of drawer
        
        transactionsTableView?.didScrollToYOffset = { [weak self] offset in
            self?.headerView.setOffset(offset)
        }
        transactionsTableView?.didStopScrolling = { [weak self] in
            self?.headerView.didStopScrolling()
        }
        transactionsTableView?.view.layer.cornerRadius = CornerRadius.large.rawValue
        transactionsTableView?.view.layer.masksToBounds = true
        transactionsTableView?.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        if currency == Currencies.shared.bsv && UserManager.shared.profile != nil {
            paymailCallback?(true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(headerView.isSearching, animated: true)
        
        shouldShowStatusBar = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        wallet?.startGiftingMonitor()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        footerHeightConstraint?.constant = AssetDetailsFooterView.height + view.safeAreaInsets.bottom
    }
    
    // MARK: -
    
    private func setupNavigationBar() {
        let searchButton = UIButton(type: .system)
        searchButton.setImage(Asset.search.image, for: .normal)
        searchButton.widthAnchor.constraint(equalToConstant: 22.0).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
        searchButton.tap = { [unowned self] in
            self.showSearchHeaderView()
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
    }
    
    private func addSubviews() {
        view.addSubview(headerContainer)
        headerContainer.addSubview(headerView)
        headerContainer.addSubview(searchHeaderview)
        view.addSubview(footerView)
    }
    
    private func addConstraints() {
        let topConstraint = headerContainer.topAnchor.constraint(equalTo: view.topAnchor)
        topConstraint.priority = .required
        headerContainer.constrain([
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topConstraint,
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        headerView.constrain(toSuperviewEdges: nil)
        searchHeaderview.constrain(toSuperviewEdges: nil)
        
        footerView.constrain([
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
    }
    
    private func addSubscriptions() {
        Store.subscribe(self, name: .showStatusBar, callback: { [weak self] _ in
            self?.shouldShowStatusBar = true
        })
        Store.subscribe(self, name: .hideStatusBar, callback: { [weak self] _ in
            self?.shouldShowStatusBar = false
        })
    }
    
    private func setInitialData() {
        view.clipsToBounds = true
        searchHeaderview.isHidden = true
        searchHeaderview.didCancel = { [weak self] in
            self?.hideSearchHeaderView()
            self?.isSearching = false
        }
        searchHeaderview.didChangeFilters = { [weak self] filters in
            self?.transactionsTableView?.filters = filters
        }
        headerView.setHostContentOffset = { [weak self] offset in
            self?.transactionsTableView?.tableView.contentOffset.y = offset
        }
    }
    
    private func didTapDrawerButton(_ type: PaymentCard.PaymentType? = nil) {
        if let type {
            coordinator?.showBuy(selectedCurrency: currency,
                                 type: type,
                                 coreSystem: coreSystem,
                                 keyStore: keyStore)
        } else {
            coordinator?.showSell(selectedCurrency: currency,
                                  coreSystem: coreSystem,
                                  keyStore: keyStore)
        }
    }
    
    private func createAccount() {
        let activity = BRActivityViewController(message: L10n.AccountCreation.creating)
        present(activity, animated: true, completion: nil)
        
        let completion: (Wallet?) -> Void = { [weak self] wallet in
            DispatchQueue.main.async {
                self?.createTimeoutTimer?.invalidate()
                self?.createTimeoutTimer = nil
                activity.dismiss(animated: true, completion: {
                    if wallet == nil {
                        self?.showErrorMessage(L10n.AccountCreation.error)
                    } else {
                        Store.perform(action: Alert.Show(.accountCreation))
                        self?.wallet = wallet
                    }
                })
            }
        }
        
        let handleTimeout: (Timer) -> Void = { [weak self] _ in
            activity.dismiss(animated: true, completion: {
                self?.showErrorMessage(L10n.AccountCreation.timeout)
            })
        }
        
        // This could take a while because we're waiting for a transaction to confirm, so we need a decent timeout of 45 seconds.
        createTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 45, repeats: false, block: handleTimeout)
        
        Store.trigger(name: .createAccount(currency, completion))
    }
    
    private func addTransactionsView() {
        if let transactionsTableView = transactionsTableView {
            transactionsTableView.tableView.contentInset.bottom = AssetDetailsFooterView.height
            transactionsTableView.view.backgroundColor = Colors.Background.two
            view.backgroundColor = Colors.Background.one
            
            addChildViewController(transactionsTableView, layout: {
                transactionsTableView.view.constrain([
                    transactionsTableView.view.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Margins.extraLarge.rawValue),
                    transactionsTableView.view.bottomAnchor.constraint(equalTo: footerView.bottomAnchor),
                    transactionsTableView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    transactionsTableView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
            })
            
            view.sendSubviewToBack(transactionsTableView.view)
            headerView.setExtendedTouchDelegate(transactionsTableView.tableView)
        }
    }
    
    // MARK: keyboard management
    
    private func hideSearchKeyboard() {
        isSearching = searchHeaderview.isFirstResponder
        if isSearching {
            _ = searchHeaderview.resignFirstResponder()
        }
    }
    
    private func showSearchKeyboard() {
        _ = searchHeaderview.becomeFirstResponder()
    }
    
    // MARK: show transaction details
    
    private func didSelectTransaction(transactions: [TxListViewModel], selectedIndex: Int) {
        hideSearchKeyboard()
        
        let transaction = transactions[selectedIndex]
        
        GoogleAnalytics.logEvent(GoogleAnalytics.Wallet(currencyCode: transaction.currency?.code ?? ""))

        switch transaction.exchangeType {
        case .unknown:
            guard let tx = transactions[selectedIndex].tx else { return }
            let transactionDetails = TxDetailViewController(transaction: tx, delegate: self)
            transactionDetails.modalPresentationStyle = .overCurrentContext
            transactionDetails.transitioningDelegate = transitionDelegate
            transactionDetails.modalPresentationCapturesStatusBarAppearance = true
            
            present(transactionDetails, animated: true)
            
        default:
            let vc = ExchangeDetailsViewController()
            vc.isModalDismissable = false
            vc.dataStore?.exchangeId = String(transaction.tx?.exchange?.orderId ?? transaction.exchange?.orderId ?? -1)
            vc.dataStore?.exchangeType = transaction.exchangeType
            vc.dataStore?.transactionPart = transaction.tx?.exchange?.part ?? transaction.exchange?.part ?? .one
            vc.coordinator = coordinator
            
            LoadingView.show()
            navigationController?.pushViewController(viewController: vc, animated: true) {
                LoadingView.hideIfNeeded()
            }
        }
    }
    
    private func showSearchHeaderView() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        headerView.stopHeightConstraint()
        UIView.animate(withDuration: Presets.Animation.short.rawValue, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
        
        UIView.transition(from: headerView,
                          to: searchHeaderview,
                          duration: Presets.Animation.short.rawValue,
                          options: [.transitionFlipFromBottom, .showHideTransitionViews, .curveEaseOut],
                          completion: { [weak self] _ in
            self?.searchHeaderview.triggerUpdate()
            self?.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    private func hideSearchHeaderView() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        headerView.resumeHeightConstraint()
        UIView.animate(withDuration: Presets.Animation.short.rawValue, animations: {
            self.view.layoutIfNeeded()
        })
        
        UIView.transition(from: searchHeaderview,
                          to: headerView,
                          duration: Presets.Animation.short.rawValue,
                          options: [.transitionFlipFromTop, .showHideTransitionViews, .curveEaseOut],
                          completion: { [weak self] _ in
            self?.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var prefersStatusBarHidden: Bool {
        return !shouldShowStatusBar
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: TxDetailDelegate
extension AssetDetailsViewController: TxDetaiViewControllerDelegate {
    func txDetailDidDismiss(detailViewController: TxDetailViewController) {
        if isSearching {
            // Restore the search keyboard that we hid when the transaction details were displayed
            searchHeaderview.becomeFirstResponder()
        }
    }
}
