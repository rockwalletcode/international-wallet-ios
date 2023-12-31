//
//  HomeScreenViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-11-27.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import Combine
import UIKit
import SnapKit
import Lottie
import WebKit

class HomeScreenViewController: UIViewController, UITabBarDelegate, Subscriber, WKNavigationDelegate {
    
    enum SegmentControlCases: String, CaseIterable {
        case rockWallet
        case rockWalletPro
        
        var title: String {
            switch self {
            case .rockWallet:
                return L10n.About.AppName.android.uppercased()
                
            case .rockWalletPro:
                return L10n.Segment.rockWalletPro.uppercased()
            }
        }
    }
    
    private let walletAuthenticator: WalletAuthenticator
    private let notificationHandler = NotificationHandler()
    private let coreSystem: CoreSystem
    
    private var observers: [AnyCancellable] = []
    private var isRedirectedUrl: Bool = false
    private var isPortalLink: Bool = false
    private var isUserLoggedInWebPro: Bool = false
    private var selectedSegment: HomeScreenViewController.SegmentControlCases = .rockWallet
    private var proBalancesData: ProBalancesModel?
    
    private lazy var assetListTableView: AssetListTableView = {
        let view = AssetListTableView()
        return view
    }()
    
    private lazy var tabBarContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = CornerRadius.large.rawValue
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.backgroundColor = Colors.Background.two
        return view
    }()
    
    private lazy var exchangeButtonsView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Background.one
        view.layer.cornerRadius = CornerRadius.large.rawValue
        view.isHidden = true
        return view
    }()
    
    private lazy var exchangeButtonsStackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = Margins.extraSmall.rawValue
        return view
    }()
    
    private lazy var tabBar: UITabBar = {
        let view = UITabBar()
        view.delegate = self
        view.isTranslucent = false
        let appearance = view.standardAppearance
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        appearance.backgroundColor = Colors.Background.two
        view.standardAppearance = appearance
        view.unselectedItemTintColor = Colors.Text.two
        return view
    }()
    
    private lazy var subHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = false
        return view
    }()
    
    private lazy var totalAssetsTitleLabel: UILabel = {
        let view = UILabel(font: Fonts.Body.two, color: Colors.Text.three)
        view.text = L10n.HomeScreen.wallet
        return view
    }()
    
    private lazy var totalAssetsAmountLabel: UILabel = {
        let view = UILabel(font: Fonts.Title.three, color: Colors.Text.three)
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
        view.textAlignment = .right
        return view
    }()
    
    private lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = Asset.logoIcon.image
        return view
    }()
    
    private lazy var segmentControlStackView: UIStackView = {
        let view = UIStackView()
        return view
    }()
    
    private lazy var segmentControl: SegmentControl = {
        let view = SegmentControl()
        return view
    }()
    
    private lazy var transferFunds: FEButton = {
        let view = FEButton()
        view.titleLabel?.numberOfLines = 1
        view.titleLabel?.adjustsFontSizeToFitWidth = true
        return view
    }()
    
    private lazy var launchExchange: FEButton = {
        let view = FEButton()
        view.titleLabel?.numberOfLines = 1
        view.titleLabel?.adjustsFontSizeToFitWidth = true
        return view
    }()
    
    private lazy var launchPortalLogin: FEButton = {
        let view = FEButton()
        return view
    }()
    
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        return view
    }()
    
    var didSelectCurrency: ((Currency) -> Void)?
    var didTapManageWallets: (() -> Void)?
    var didTapBuy: ((PaymentCard.PaymentType) -> Void)?
    var didTapSell: (() -> Void)?
    var didTapTrade: (() -> Void)?
    var didTapProfile: (() -> Void)?
    var didTapProfileFromPrompt: (() -> Void)?
    var didTapTwoStepFromPrompt: (() -> Void)?
    var didTapCreateAccountFromPrompt: (() -> Void)?
    var didTapLimitsAuthenticationFromPrompt: (() -> Void)?
    var didTapMenu: (() -> Void)?
    var didTapProSegment: ((Bool?) -> Void)?
    var didTapTransferFunds: ((ProBalancesModel?) -> Void)?
    
    private lazy var pullToRefreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.attributedTitle = NSAttributedString(string: L10n.HomeScreen.pullToRefresh)
        view.addTarget(self, action: #selector(reload), for: .valueChanged)
        return view
    }()
    
    // We are not using pullToRefreshControl.isRefreshing because when you trigger reload() it is already refreshing. We need a variable that tracks the real refreshing of the resources.
    private var isRefreshing = false
    
    private let tabBarButtons = [
        (L10n.Button.home, Asset.home.image as UIImage, #selector(home)),
        (L10n.Button.profile, Asset.user.image as UIImage, #selector(profile)),
        (L10n.HomeScreen.menu, Asset.more.image as UIImage, #selector(menu))
    ]
    
    // MARK: - Lifecycle
    
    init(walletAuthenticator: WalletAuthenticator, coreSystem: CoreSystem) {
        self.walletAuthenticator = walletAuthenticator
        self.coreSystem = coreSystem
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Store.unsubscribe(self)
    }
    
    @objc func reload() {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        guard selectedSegment == .rockWallet else {
            getProBalance()
            return
        }
        
        Currencies.shared.reloadCurrencies()
       
        coreSystem.refreshWallet { [weak self] in
            self?.assetListTableView.reload()
        }
        
        showGeneralPrompt()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pullToRefreshControl.endRefreshing()
        
        GoogleAnalytics.logEvent(GoogleAnalytics.Home())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserManager.shared.profile == nil {
            isUserLoggedInWebPro = false
        }
        
        if selectedSegment == .rockWallet {
            showGeneralPrompt()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assetListTableView.didSelectCurrency = didSelectCurrency
        assetListTableView.didTapAddWallet = didTapManageWallets
        assetListTableView.didReload = { [weak self] in
            self?.pullToRefreshControl.endRefreshing()
            
            self?.isRefreshing = false
        }
        
        assetListTableView.didTapFaqButton = { [weak self] in
            self?.showInWebView(urlString: Constant.supportLink, title: "")
        }
        
        setupSubviews()
        setInitialData()
        setupSubscriptions()
        updateTotalAssets()
        
        if !Store.state.isLoginRequired {
            NotificationAuthorizer().showNotificationsOptInAlert(from: self, callback: { _ in
                self.notificationHandler.checkForInAppNotifications()
            })
        }
    }
    
    // MARK: Setup
    
    private func setupSubviews() {
        view.addSubview(subHeaderView)
        subHeaderView.addSubview(logoImageView)
        subHeaderView.addSubview(totalAssetsTitleLabel)
        subHeaderView.addSubview(totalAssetsAmountLabel)
        
        let promptContainerScrollView = PromptPresenter.shared.promptContainerScrollView
        let promptContainerStack = PromptPresenter.shared.promptContainerStack
        
        view.addSubview(promptContainerScrollView)
        promptContainerScrollView.addSubview(promptContainerStack)
        
        assetListTableView.refreshControl = pullToRefreshControl
        pullToRefreshControl.layer.zPosition = assetListTableView.view.layer.zPosition - 1
        
        subHeaderView.constrain([
            subHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: -(navigationController?.navigationBar.frame.height ?? 0) + Margins.extraHuge.rawValue),
            subHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subHeaderView.heightAnchor.constraint(equalToConstant: ViewSizes.Common.hugeCommon.rawValue) ])
        
        totalAssetsTitleLabel.constrain([
            totalAssetsTitleLabel.topAnchor.constraint(equalTo: subHeaderView.topAnchor),
            totalAssetsTitleLabel.trailingAnchor.constraint(equalTo: subHeaderView.trailingAnchor, constant: -Margins.large.rawValue)])
        
        totalAssetsAmountLabel.constrain([
            totalAssetsAmountLabel.trailingAnchor.constraint(equalTo: totalAssetsTitleLabel.trailingAnchor),
            totalAssetsAmountLabel.topAnchor.constraint(equalTo: totalAssetsTitleLabel.bottomAnchor, constant: Margins.extraSmall.rawValue),
            totalAssetsAmountLabel.bottomAnchor.constraint(equalTo: subHeaderView.bottomAnchor)])
        
        logoImageView.constrain([
            logoImageView.leadingAnchor.constraint(equalTo: subHeaderView.leadingAnchor, constant: Margins.large.rawValue),
            logoImageView.centerYAnchor.constraint(equalTo: subHeaderView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 40),
            logoImageView.heightAnchor.constraint(equalToConstant: 48)])
        
        view.addSubview(segmentControlStackView)
        segmentControlStackView.snp.makeConstraints { make in
            make.top.equalTo(subHeaderView.snp.bottom).offset(Margins.medium.rawValue)
            make.leading.trailing.equalToSuperview().inset(Margins.large.rawValue)
        }
        segmentControlStackView.addArrangedSubview(segmentControl)
        
        promptContainerScrollView.constrain([
            promptContainerScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Margins.large.rawValue),
            promptContainerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Margins.large.rawValue),
            promptContainerScrollView.topAnchor.constraint(equalTo: segmentControlStackView.bottomAnchor, constant: Margins.medium.rawValue),
            promptContainerScrollView.heightAnchor.constraint(equalToConstant: ViewSizes.minimum.rawValue).priority(.defaultLow)])
        
        promptContainerStack.constrain([
            promptContainerStack.leadingAnchor.constraint(equalTo: promptContainerScrollView.leadingAnchor),
            promptContainerStack.trailingAnchor.constraint(equalTo: promptContainerScrollView.trailingAnchor),
            promptContainerStack.topAnchor.constraint(equalTo: promptContainerScrollView.topAnchor),
            promptContainerStack.bottomAnchor.constraint(equalTo: promptContainerScrollView.bottomAnchor),
            promptContainerStack.heightAnchor.constraint(equalTo: promptContainerScrollView.heightAnchor),
            promptContainerStack.widthAnchor.constraint(equalTo: promptContainerScrollView.widthAnchor)])
        
        addChildViewController(assetListTableView, layout: {
            assetListTableView.view.constrain([
                assetListTableView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                assetListTableView.view.topAnchor.constraint(equalTo: promptContainerScrollView.bottomAnchor, constant: Margins.medium.rawValue),
                assetListTableView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                assetListTableView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        })
        view.addSubview(exchangeButtonsView)
        exchangeButtonsView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(ViewSizes.extraExtraHuge.rawValue)
        }
        
        exchangeButtonsView.addSubview(exchangeButtonsStackView)
        exchangeButtonsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(Margins.small.rawValue)
            make.leading.trailing.equalToSuperview().inset(Margins.medium.rawValue)
            make.height.equalTo(ViewSizes.Common.defaultCommon.rawValue)
        }
        
        exchangeButtonsStackView.addArrangedSubview(transferFunds)
        exchangeButtonsStackView.addArrangedSubview(launchExchange)
        if E.isDevelopment {
            exchangeButtonsStackView.addArrangedSubview(launchPortalLogin)
        }
        
        view.addSubview(tabBarContainerView)
        tabBarContainerView.addSubview(tabBar)
        
        tabBarContainerView.constrain([
            tabBarContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarContainerView.heightAnchor.constraint(equalToConstant: BottomDrawer.bottomToolbarHeight)])
        
        tabBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Margins.large.rawValue)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setInitialData() {
        title = ""
        view.backgroundColor = Colors.Background.two
        navigationItem.titleView = UIView()
        
        setupToolbar()
        updateTotalAssets()
        setupSegmentControl()
        setupProButtons()
    }
    
    private func setupToolbar() {
        var buttons = [UITabBarItem]()
        
        tabBarButtons.forEach { title, image, _ in
            let button = UITabBarItem(title: title, image: image, selectedImage: image)
            button.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.button], for: .normal)
            var insets = button.imageInsets
            insets.bottom = Margins.extraSmall.rawValue
            insets.top = -Margins.extraSmall.rawValue
            button.imageInsets = insets
            buttons.append(button)
        }
        
        tabBar.items = buttons
    }
    
    private func setupSegmentControl() {
        let segmentControlModel = SegmentControlViewModel(selectedIndex: 0,
                                                          segments: [.init(image: nil, title: SegmentControlCases.rockWallet.title),
                                                                     .init(image: nil, title: SegmentControlCases.rockWalletPro.title)])
        segmentControl.configure(with: .init())
        segmentControl.setup(with: segmentControlModel)
        segmentControl.didChangeValue = { [weak self] segment in
            self?.setSegment(segment)
        }
    }
    
    private func setSegment(_ segment: Int) {
        segmentControl.selectSegment(index: segment)
        selectedSegment = SegmentControlCases.allCases[segment]
        
        if selectedSegment == .rockWalletPro {
            guard let profile = UserManager.shared.profile else {
                tapSegment(isUserLogged: false)
                segmentControl.selectSegment(index: 0)
                selectedSegment = .rockWallet
                return
            }
            
            guard profile.kycAccessRights.hasExchangeAccess else {
                tapSegment(isUserLogged: true)
                segmentControl.selectSegment(index: 0)
                selectedSegment = .rockWallet
                return
            }
            
            getProBalance()
        } else {
            updateTotalAssets()
        }
        
        updateViews(selectedSegment: selectedSegment)
    }
    
    func getProBalance() {
        ProBalancesWorker().execute(requestData: ProBalancesRequestData()) { result in
            switch result {
            case .success(let data):
                guard let data else { return }
                self.updateProBalance(data: data)
                self.assetListTableView.proBalancesData = data
                self.proBalancesData = data
                
            case .failure(let error):
                self.showErrorMessage(error.localizedDescription)
            }
        }
    }
    
    private func updateViews(selectedSegment: SegmentControlCases) {
        tabBarContainerView.isHidden = selectedSegment == .rockWalletPro
        exchangeButtonsView.isHidden = selectedSegment == .rockWallet
        
        logoImageView.image = selectedSegment == .rockWallet ? Asset.logoIcon.image : Asset.logoPro.image
        totalAssetsTitleLabel.text = selectedSegment == .rockWallet ? "\(L10n.HomeScreen.wallet) \(L10n.HomeScreen.totalAssets.lowercased())" : L10n.Segment.rockWalletPro
        
        assetListTableView.showAddWalletsButton(selectedSegment == .rockWallet)
        UserDefaults.isDarkMode = selectedSegment == .rockWalletPro
        
        updateTheme()
        
        if UserDefaults.shouldDisplayProPopup {
            showPopupProDescription()
        }
        
        guard selectedSegment == .rockWalletPro else {
            showGeneralPrompt()
            return
        }
        
        PromptFactory.shared.presentedPopups.removeAll()
        for type in PromptType.defaultTypes {
            PromptPresenter.shared.hidePrompt(type)
        }
    }
    
    func showGeneralPrompt() {
        PromptPresenter.shared.attemptShowGeneralPrompt(walletAuthenticator: walletAuthenticator, on: self)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(where: { $0 == item }) else { return }
        perform(tabBarButtons[index].2)
        tabBar.selectedItem = nil
    }
    
    private func setupProButtons() {
        transferFunds.configure(with: Presets.Button.secondary)
        transferFunds.setup(with: .init(title: L10n.Button.transferFunds.uppercased(),
                                        callback: { [weak self] in
            self?.transferFundsTapped()
        }))
        
        launchExchange.configure(with: Presets.Button.primary)
        launchExchange.setup(with: .init(title: L10n.Button.launchExchange,
                                         callback: { [weak self] in
            self?.launchExchangeTapped()
        }))
        
        launchPortalLogin.configure(with: Presets.Button.secondary)
        launchPortalLogin.setup(with: .init(title: L10n.Buttons.portalLogin,
                                            callback: { [weak self] in
            self?.portalLoginTapped()
        }))
    }
    
    private func setupSubscriptions() {
        Store.unsubscribe(self)
        
        Store.subscribe(self, selector: {
            var result = false
            let oldState = $0
            let newState = $1
            $0.wallets.values.map { $0.currency }.forEach { currency in
                result = result || oldState[currency]?.balance != newState[currency]?.balance
                result = result || oldState[currency]?.currentRate?.rate != newState[currency]?.currentRate?.rate
            }
            return result
        }, callback: { _ in
            self.updateTotalAssets()
            self.updateAmountsForWidgets()
        })
        
        // Prompts
        Store.subscribe(self, name: .didUpgradePin, callback: { _ in
            PromptPresenter.shared.hidePrompt(.upgradePin)
        })
        
        Store.subscribe(self, name: .didWritePaperKey, callback: { _ in
            PromptPresenter.shared.hidePrompt(.paperKey)
        })
        
        Store.subscribe(self, name: .didApplyKyc, callback: { _ in
            PromptPresenter.shared.hidePrompt(.kyc)
        })
        
        Store.subscribe(self, name: .didCreateAccount, callback: { _ in
            PromptPresenter.shared.hidePrompt(.noAccount)
        })
        
        Store.subscribe(self, name: .didSetTwoStep, callback: { _ in
            PromptPresenter.shared.hidePrompt(.twoStep)
        })
        
        Store.subscribe(self, name: .promptKyc, callback: { _ in
            self.didTapProfileFromPrompt?()
        })
        
        Store.subscribe(self, name: .promptNoAccount, callback: { _ in
            self.didTapCreateAccountFromPrompt?()
        })
        
        Store.subscribe(self, name: .promptTwoStep, callback: { _ in
            self.didTapTwoStepFromPrompt?()
        })
        
        Store.subscribe(self, name: .promptLimitsAuthentication, callback: { _ in
            self.didTapLimitsAuthenticationFromPrompt?()
        })
        
        Store.subscribe(self, name: .showSell) { _ in
            self.didTapSell?()
        }
        
        Store.subscribe(self, name: .showBuy) { _ in
            self.didTapBuy?(.card)
        }
        
        Reachability.addDidChangeCallback({ [weak self] isReachable in
            PromptPresenter.shared.hidePrompt(.noInternet)
            
            if !isReachable {
                self?.showGeneralPrompt()
            }
        })
        
        Store.subscribe(self, selector: {
            $0.wallets.count != $1.wallets.count
        }, callback: { _ in
            self.updateTotalAssets()
            self.updateAmountsForWidgets()
        })
        
        PromptPresenter.shared.trailingButtonCallback = { [weak self] promptType in
            switch promptType {
            case .kyc:
                self?.didTapProfileFromPrompt?()
                
            case .noAccount:
                self?.didTapCreateAccountFromPrompt?()
                
            case .twoStep:
                self?.didTapTwoStepFromPrompt?()
                
            default:
                break
            }
        }
    }
    
    private func updateTotalAssets() {
        guard selectedSegment == .rockWallet else { return }
        let fiatTotal: Decimal = Store.state.wallets.values.map {
            guard let balance = $0.balance,
                  let rate = $0.currentRate else { return 0.0 }
            let amount = Amount(amount: balance,
                                rate: rate)
            return amount.fiatValue
        }.reduce(0.0, +)
        
        guard let formattedBalance = ExchangeFormatter.fiat.string(for: fiatTotal),
              let fiatCurrency = Store.state.orderedWallets.first?.currentRate?.code else { return }
        totalAssetsAmountLabel.text = String(format: Constant.currencyFormat, formattedBalance, fiatCurrency)
    }
    
    private func updateProBalance(data: ProBalancesModel) {
        guard selectedSegment == .rockWalletPro else { return }
        let fiatTotal: Decimal = Store.state.wallets.values.map {
            let proBalance = data.getProBalance(code: $0.currency.code)
            let balance = Amount(decimalAmount: proBalance, isFiat: true, currency: $0.currency)
            let amount = Amount(amount: balance,
                                rate: $0.currentRate)
            return amount.fiatValue
        }.reduce(0.0, +)
        
        guard let formattedBalance = ExchangeFormatter.fiat.string(for: fiatTotal),
              let fiatCurrency = Store.state.orderedWallets.first?.currentRate?.code else { return }
        totalAssetsAmountLabel.text = String(format: Constant.currencyFormat, formattedBalance, fiatCurrency)
    }
    
    private func updateAmountsForWidgets() {
        let info: [CurrencyId: Double] = Store.state.wallets
            .map { ($0, $1) }
            .reduce(into: [CurrencyId: Double]()) {
                if let balance = $1.1.balance {
                    let unit = $1.1.currency.defaultUnit
                    $0[$1.0] = balance.cryptoAmount.double(as: unit) ?? 0
                }
            }
        
        coreSystem.widgetDataShareService.updatePortfolio(info: info)
        coreSystem.widgetDataShareService.quoteCurrencyCode = Store.state.defaultCurrencyCode
    }
    
    private func updateTheme() {
        ThemeManager.shared = ThemeManager.init()
        
        let colors = Colors()
        colors.updateColors()
        
        updateThemeColors()
    }
    
    private func updateThemeColors() {
        view.backgroundColor = Colors.Background.two
        tabBarContainerView.backgroundColor = Colors.Background.two
        exchangeButtonsView.backgroundColor = Colors.Background.one
        tabBar.unselectedItemTintColor = Colors.Text.two
        totalAssetsTitleLabel.textColor = Colors.Text.three
        totalAssetsAmountLabel.textColor = Colors.Text.three
        assetListTableView.tableView.backgroundColor = Colors.Background.two
        segmentControl.configure(with: .init())
        
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: Colors.Text.three]
        pullToRefreshControl.attributedTitle = NSAttributedString(string: L10n.HomeScreen.pullToRefresh, attributes: attributes)
        pullToRefreshControl.tintColor = Colors.Text.three
    }
    
    // MARK: Actions
    
    @objc private func home() {}
    
    @objc private func profile() {
        didTapProfile?()
    }
    
    @objc private func menu() {
        didTapMenu?()
    }
    
    private func tapSegment(isUserLogged: Bool?) {
        didTapProSegment?(isUserLogged)
    }
    
    private func transferFundsTapped() {
        didTapTransferFunds?(proBalancesData)
    }
    
    private func launchExchangeTapped() {
        guard isUserLoggedInWebPro else {
            showPopup(isPortal: false)
            return
        }
        
        setupWebView(completion: { [weak self] in
            self?.webView.navigationDelegate = self
            guard let url = URL(string: Constant.tradeSignInLink) else { return }
            
            self?.webView.load(URLRequest(url: url))
        })
    }
    
    private func showPopupProDescription() {
        let model = PopupViewModel(title: .text(L10n.Popup.proTitle),
                                   body: L10n.Popup.proDescription,
                                   buttons: [.init(title: L10n.Button.gotIt,
                                                   callback: { [weak self] in
            self?.hidePopup()
        })],
                                   urlLink: .attributedText(prepareTermsTickboxText(attributedText: L10n.Popup.visitFaqText)),
                                   url: Constant.supportLink)
        
        showInfoPopup(with: model)
        UserDefaults.shouldDisplayProPopup = false
    }
    
    private func prepareTermsTickboxText(attributedText: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: Colors.Text.two,
            NSAttributedString.Key.backgroundColor: UIColor.clear,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.font: Fonts.Body.two]
        
        let iconAttachment = NSTextAttachment()
        iconAttachment.image = UIImage(named: Asset.faqIcon.name)
        iconAttachment.bounds = CGRect(x: Margins.large.rawValue, y: -Margins.small.rawValue, width: Margins.huge.rawValue, height: Margins.huge.rawValue)
        let attachmentString = NSAttributedString(attachment: iconAttachment)
        
        let attributedString = NSMutableAttributedString(string: attributedText, attributes: attributes)
        attributedString.append(attachmentString)
        
        return attributedString
    }
    
    private func portalLoginTapped() {
        showPopup(isPortal: true)
    }
    
    private func showPopup(isPortal: Bool) {
        let model = PopupViewModel(body: L10n.Exchange.popupText,
                                   buttons: [.init(title: L10n.Button.gotIt,
                                                   callback: { [weak self] in
            self?.handleWebViewRedirects(isPortal: isPortal)
            self?.hidePopup()
        })],
                                   urlLink: .attributedText(prepareTermsTickboxText(attributedText: L10n.Popup.visitFaqText)),
                                   url: Constant.supportLink)
        
        showInfoPopup(with: model, config: Presets.Popup.whiteCentered)
    }
    
    func getRedirectUri() {
        guard let urlParameters = DynamicLinksManager.shared.urlParameters else { return }
        
        let sortedParameters = urlParameters.sorted(by: <).map { "\($0)=\($1)" }.joined()
        let data = Oauth2LoginRequestData(parameters: urlParameters,
                                          sortedParameters: sortedParameters)
        
        Oauth2LoginWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let response):
                guard let url = URL(string: response?.redirectUri ?? "") else { return }
                self?.handleRedirectedUrl(url: url)
                
            case .failure(let error):
                self?.showErrorMessage(error.localizedDescription)
            }
        }
    }
    func handleWebViewRedirects(isPortal: Bool) {
        webView.navigationDelegate = self
        isPortalLink = isPortal
        let urlString = isPortalLink ? Constant.portalSignInLink : Constant.tradeSignInLink
        guard let url = URL(string: urlString) else { return }
        
        webView.load(URLRequest(url: url))
        LoadingView.show(descriptionText: L10n.Exchange.loadProDescription)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        let url = isPortalLink ? Constant.portalSignInLink : Constant.tradeSignInLink
        guard webView.url?.absoluteString == url else {
            guard !isRedirectedUrl else {
                setupWebView()
                return
            }
            
            DynamicLinksManager.handleDynamicLink(dynamicLink: webView.url)
            getRedirectUri()
            LoadingView.hideIfNeeded()
            return
        }
        // auto tap on login button in web view
        let buttonTag = isPortalLink ? "1" : "0"
        let scriptSource = "document.getElementsByTagName('button')[\(buttonTag)].click()"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0, execute: {
            self.isUserLoggedInWebPro = true
            webView.evaluateJavaScript(scriptSource, completionHandler: nil)
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let urlString = navigationAction.request.url?.absoluteString {
            if urlString.contains("session-expired") {
                isUserLoggedInWebPro = false
                backButtonPressed()
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
    func setupWebView(completion: (() -> Void)? = nil) {
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview().inset(Margins.small.rawValue)
        }
        
        let back = UIBarButtonItem(image: Asset.back.image.withRenderingMode(.alwaysOriginal),
                                   style: .plain,
                                   target: self,
                                   action: #selector(backButtonPressed))
        navigationItem.leftBarButtonItem = back
    }
    
    func handleRedirectedUrl(url: URL) {
        webView.load(URLRequest(url: url))
        isRedirectedUrl = true
    }
    
    @objc func backButtonPressed() {
        navigationItem.leftBarButtonItem = nil
        isRedirectedUrl = false
        webView.removeFromSuperview()
        view.layoutIfNeeded()
    }
}
