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

class HomeScreenViewController: UIViewController, UITabBarDelegate, Subscriber {
    private let walletAuthenticator: WalletAuthenticator
    private let notificationHandler = NotificationHandler()
    private let coreSystem: CoreSystem
    
    private var observers: [AnyCancellable] = []
    
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
        view.backgroundColor = Colors.Background.cards
        return view
    }()
    
    private lazy var exchangeButtonsView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.backgroundColor = Colors.Background.cards
        view.layer.cornerRadius = CornerRadius.large.rawValue
        view.spacing = Margins.small.rawValue
        view.isHidden = true
        return view
    }()
    
    private lazy var tabBar: UITabBar = {
        let view = UITabBar()
        view.delegate = self
        view.isTranslucent = false
        let appearance = view.standardAppearance
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        appearance.backgroundColor = Colors.Background.cards
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
        view.text = L10n.HomeScreen.totalAssets
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
    
    private lazy var segmentControl: SegmentControl = {
        let view = SegmentControl()
        return view
    }()
    
    private lazy var transferFunds: FEButton = {
        let view = FEButton()
        return view
    }()
    
    private lazy var launchExchange: FEButton = {
        let view = FEButton()
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
    var didTapProSegment: (() -> Void)?
    
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
        
        PromptPresenter.shared.attemptShowGeneralPrompt(walletAuthenticator: walletAuthenticator, on: self)
        
        Currencies.shared.reloadCurrencies()
        
        coreSystem.refreshWallet { [weak self] in
            self?.assetListTableView.reload()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pullToRefreshControl.endRefreshing()
        
        segmentControl.isHidden = UserManager.shared.profile == nil
        
        GoogleAnalytics.logEvent(GoogleAnalytics.Home())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        PromptPresenter.shared.attemptShowGeneralPrompt(walletAuthenticator: walletAuthenticator, on: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assetListTableView.didSelectCurrency = didSelectCurrency
        assetListTableView.didTapAddWallet = didTapManageWallets
        assetListTableView.didReload = { [weak self] in
            self?.pullToRefreshControl.endRefreshing()
            
            self?.isRefreshing = false
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
        
        view.addSubview(segmentControl)
        segmentControl.snp.makeConstraints { make in
            make.top.equalTo(subHeaderView.snp.bottom).offset(Margins.medium.rawValue)
            make.leading.trailing.equalToSuperview().inset(Margins.large.rawValue)
            make.height.equalTo(ViewSizes.minimum.rawValue).priority(.low)
            make.bottom.equalTo(promptContainerScrollView.snp.top).offset(-Margins.small.rawValue)
        }
        
        promptContainerScrollView.constrain([
            promptContainerScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Margins.large.rawValue),
            promptContainerScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Margins.large.rawValue),
            promptContainerScrollView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: Margins.medium.rawValue),
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
        
        exchangeButtonsView.addSubview(transferFunds)
        transferFunds.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(Margins.small.rawValue)
            make.height.equalTo(ViewSizes.Common.defaultCommon.rawValue)
        }
        
        exchangeButtonsView.addSubview(launchExchange)
        launchExchange.snp.makeConstraints { make in
            make.top.equalTo(transferFunds.snp.top)
            make.leading.equalTo(transferFunds.snp.trailing).inset(-Margins.small.rawValue)
            make.height.equalTo(ViewSizes.Common.defaultCommon.rawValue)
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
                                                          segments: [.init(image: nil, title: L10n.About.AppName.android.uppercased()),
                                                                     .init(image: nil, title: L10n.Segment.rockWalletPro)])
        segmentControl.configure(with: .init())
        segmentControl.setup(with: segmentControlModel)
        segmentControl.didChangeValue = { [weak self] segment in
            self?.setSegment(segment)
        }
    }
    
    private func setSegment(_ segment: Int) {
        segmentControl.selectSegment(index: segment)
        
        guard let profile = UserManager.shared.profile else { return }
        
        guard profile.kycAccessRights.hasExchangeAccess else {
            if segment == 1 {
                didTapProSegment?()
                segmentControl.selectSegment(index: 0)
            }
            return
        }
        
        tabBarContainerView.isHidden = segment == 1
        exchangeButtonsView.isHidden = segment == 0
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(where: { $0 == item }) else { return }
        perform(tabBarButtons[index].2)
        tabBar.selectedItem = nil
    }
    
    private func setupProButtons() {
        transferFunds.configure(with: Presets.Button.secondary)
        transferFunds.setup(with: .init(title: L10n.Button.transferFunds,
                                        callback: { [weak self] in
            self?.transferFundsTapped()
        }))
        
        launchExchange.configure(with: Presets.Button.primary)
        launchExchange.setup(with: .init(title: L10n.Button.launchExchange,
                                         callback: { [weak self] in
            self?.launchExchangeTapped()
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
                PromptPresenter.shared.attemptShowGeneralPrompt(walletAuthenticator: self?.walletAuthenticator, on: self)
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
        let fiatTotal: Decimal = Store.state.wallets.values.map {
            guard let balance = $0.balance,
                  let rate = $0.currentRate else { return 0.0 }
            let amount = Amount(amount: balance,
                                rate: rate)
            return amount.fiatValue
        }.reduce(0.0, +)

        guard let formattedBalance = ExchangeFormatter.fiat.string(for: fiatTotal),
              let fiatCurrency = Store.state.orderedWallets.first?.currentRate?.code else { return }
        totalAssetsAmountLabel.text = String(format: "%@ %@", formattedBalance, fiatCurrency)
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
    
    // MARK: Actions
    
    @objc private func home() {}
    
    @objc private func profile() {
        didTapProfile?()
    }
    
    @objc private func menu() {
        didTapMenu?()
    }
    
    private func tapSegment() {
        didTapProSegment?()
    }
    
    private func transferFundsTapped() {
        // TODO: add transfer funds action
    }
    
    private func launchExchangeTapped() {
        let model = PopupViewModel(body: L10n.Exchange.popupText,
                                   buttons: [.init(title: L10n.Button.gotIt,
                                                   callback: { [weak self] in
            DynamicLinksManager.handleDynamicLink(dynamicLink: URL(string: Constant.oauth2DeepLink))
            self?.getRedirectUri()
            self?.hidePopup()
        })])
        
        showInfoPopup(with: model)
    }
    
    func getRedirectUri() {
        guard let urlParameters = DynamicLinksManager.shared.urlParameters else { return }
        
        let sortedParameters = urlParameters.sorted(by: <).map { "\($0)=\($1)" }.joined()
        let data = Oauth2LoginRequestData(parameters: urlParameters,
                                          sortedParameters: sortedParameters)
        
        Oauth2LoginWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let response):
                self?.showInWebView(urlString: response?.redirectUri ?? "", title: "")
            case .failure(let error):
                // TODO: Handle error
                print(error)
            }
        }
    }
}
