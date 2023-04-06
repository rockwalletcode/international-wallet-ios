//
//  Coordinator.swift
//
//
//  Created by Rok Cresnik on 01/12/2021.
//

import UIKit

protocol BaseControllable: UIViewController {
    associatedtype CoordinatorType: CoordinatableRoutes
    var coordinator: CoordinatorType? { get set }
}

protocol Coordinatable: CoordinatableRoutes {
    var modalPresenter: ModalPresenter? { get set }
    var childCoordinators: [Coordinatable] { get set }
    var navigationController: UINavigationController { get set }
    var parentCoordinator: Coordinatable? { get set }
    
    init(navigationController: UINavigationController)
    
    func childDidFinish(child: Coordinatable)
    func start()
}

class BaseCoordinator: NSObject, Coordinatable {
    weak var modalPresenter: ModalPresenter? {
        get {
            guard let modalPresenter = presenter else { return parentCoordinator?.modalPresenter }
            
            return modalPresenter
        }
        set {
            presenter = newValue
        }
    }
    
    private weak var presenter: ModalPresenter?
    var parentCoordinator: Coordinatable?
    var childCoordinators: [Coordinatable] = []
    var navigationController: UINavigationController
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    init(viewController: UIViewController) {
        viewController.hidesBottomBarWhenPushed = true
        let navigationController = RootNavigationController(rootViewController: viewController)
        self.navigationController = navigationController
    }
    
    func start() {
        let nvc = RootNavigationController()
        let coordinator: Coordinatable
        
        if let profile = UserManager.shared.profile,
           profile.email.isEmpty == false,
           profile.status == .emailPending {
            coordinator = AccountCoordinator(navigationController: nvc)
        } else {
            coordinator = ProfileCoordinator(navigationController: nvc)
        }
        
        coordinator.start()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        navigationController.show(nvc, sender: nil)
    }
    
    func handleUserAccount() {
        let nvc = RootNavigationController()
        let coordinator = AccountCoordinator(navigationController: nvc)
        
        coordinator.start()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        UIApplication.shared.activeWindow?.rootViewController?.present(coordinator.navigationController, animated: true)
    }
    
    func showSwap(currencies: [Currency], coreSystem: CoreSystem, keyStore: KeyStore) {
        ExchangeCurrencyHelper.setUSDifNeeded { [weak self] in
            self?.decideFlow { showPopup in
                guard showPopup, let profile = UserManager.shared.profile else { return }
                
                if profile.kycAccessRights.hasSwapAccess {
                    self?.openModally(coordinator: ExchangeCoordinator.self, scene: Scenes.Swap) { vc in
                        vc?.dataStore?.currencies = currencies
                        vc?.dataStore?.coreSystem = coreSystem
                        vc?.dataStore?.keyStore = keyStore
                    }
                    
                    return
                } else if profile.status.isKYCLocationRestricted {
                    self?.openModally(coordinator: ExchangeCoordinator.self, scene: Scenes.ComingSoon) { [weak self] vc in
                        self?.handleComingSoonNavigation(vc)
                        
                        vc?.reason = .swap
                    }
                    
                    return
                } else if profile.kycAccessRights.restrictionReason == .kyc {
                    self?.showAccountVerification(flow: .swap)
                    
                    return
                } else {
                    self?.openModally(coordinator: ExchangeCoordinator.self, scene: Scenes.ComingSoon) { [weak self] vc in
                        self?.handleComingSoonNavigation(vc)
                        
                        vc?.reason = .swap
                    }
                    
                    return
                }
            }
        }
    }
    
    func showBuy(type: PaymentCard.PaymentType = .card, coreSystem: CoreSystem?, keyStore: KeyStore?) {
        ExchangeCurrencyHelper.setUSDifNeeded { [weak self] in
            self?.decideFlow { showPopup in
                guard showPopup, let profile = UserManager.shared.profile else { return }
                
                if profile.kycAccessRights.hasBuyAccess, type == .card {
                    self?.openModally(coordinator: ExchangeCoordinator.self, scene: Scenes.Buy) { vc in
                        vc?.dataStore?.paymentMethod = type
                        vc?.dataStore?.coreSystem = coreSystem
                        vc?.dataStore?.keyStore = keyStore
                        vc?.prepareData()
                    }
                    
                    return
                } else if profile.status.isKYCLocationRestricted, type == .card {
                    self?.openModally(coordinator: ExchangeCoordinator.self, scene: Scenes.ComingSoon) { [weak self] vc in
                        self?.handleComingSoonNavigation(vc)
                        
                        vc?.reason = .buy
                    }
                    
                    return
                } else if profile.kycAccessRights.restrictionReason == .kyc, type == .card {
                    self?.showAccountVerification(flow: .buy)
                    
                    return
                } else if type == .card {
                    self?.openModally(coordinator: ExchangeCoordinator.self, scene: Scenes.ComingSoon) { [weak self] vc in
                        self?.handleComingSoonNavigation(vc)
                        
                        vc?.reason = .buy
                    }
                    
                    return
                }
                
                if profile.kycAccessRights.hasAchAccess == true, type == .ach {
                    self?.openModally(coordinator: ExchangeCoordinator.self, scene: Scenes.Buy) { vc in
                        vc?.dataStore?.paymentMethod = type
                        vc?.dataStore?.coreSystem = coreSystem
                        vc?.dataStore?.keyStore = keyStore
                        vc?.prepareData()
                    }
                    
                    return
                } else if profile.status.isKYCLocationRestricted == true, type == .ach {
                    self?.openModally(coordinator: ExchangeCoordinator.self, scene: Scenes.ComingSoon) { [weak self] vc in
                        self?.handleComingSoonNavigation(vc)
                        
                        vc?.reason = .buyAch
                        vc?.dataStore?.coreSystem = coreSystem
                        vc?.dataStore?.keyStore = keyStore
                    }
                    
                    return
                } else if profile.kycAccessRights.restrictionReason == .kyc, type == .ach {
                    self?.showAccountVerification(flow: .buy)
                    
                    return
                } else if type == .ach {
                    self?.openModally(coordinator: ExchangeCoordinator.self, scene: Scenes.ComingSoon) { [weak self] vc in
                        self?.handleComingSoonNavigation(vc)
                        
                        vc?.reason = .buyAch
                        vc?.dataStore?.coreSystem = coreSystem
                        vc?.dataStore?.keyStore = keyStore
                    }
                    
                    return
                }
            }
        }
    }
    
    func showSell(for currency: Currency, coreSystem: CoreSystem?, keyStore: KeyStore?) {
        ExchangeCurrencyHelper.setUSDifNeeded { [weak self] in
            self?.decideFlow { showPopup in
                guard showPopup else { return }
                
                // TODO: Handle when Sell is ready.
//                if UserManager.shared.profile?.kycAccessRights.hasBuyAccess == false {
//                    self?.openModally(coordinator: SellCoordinator.self, scene: Scenes.ComingSoon) { vc in
//                        vc?.reason = .sell
//                    }
//                    return
//                }
                
                self?.openModally(coordinator: ExchangeCoordinator.self, scene: Scenes.Sell) { vc in
                    vc?.dataStore?.currency = currency
                    vc?.dataStore?.coreSystem = coreSystem
                    vc?.dataStore?.keyStore = keyStore
                    vc?.prepareData()
                }
            }
        }
    }
    
    func showProfile() {
        decideFlow { [weak self] showPopup in
            guard showPopup else { return }
            
            self?.openModally(coordinator: ProfileCoordinator.self, scene: Scenes.Profile)
        }
    }
    
    func showAccountVerification(flow: ProfileModels.ExchangeFlow? = nil) {
        let nvc = RootNavigationController()
        let coordinator = KYCCoordinator(navigationController: nvc)
        coordinator.start(flow: flow)
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        navigationController.present(nvc, animated: true)
    }
    
    func showDeleteProfileInfo(keyMaster: KeyStore) {
        let nvc = RootNavigationController()
        let coordinator = AccountCoordinator(navigationController: nvc)
        coordinator.showDeleteProfile(with: keyMaster)
        coordinator.parentCoordinator = self
        
        childCoordinators.append(coordinator)
        UIApplication.shared.activeWindow?.rootViewController?.presentedViewController?.present(coordinator.navigationController, animated: true)
    }
    
    func showExchangeDetails(with exchangeId: String?, type: TransactionType) {
        open(scene: Scenes.ExchangeDetails) { vc in
            vc.navigationItem.hidesBackButton = true
            vc.dataStore?.itemId = exchangeId
            vc.dataStore?.transactionType = type
            vc.prepareData()
        }
    }
    
    func showInWebView(urlString: String, title: String) {
        guard let url = URL(string: urlString) else { return }
        let webViewController = SimpleWebViewController(url: url)
        webViewController.setup(with: .init(title: title))
        let navController = RootNavigationController(rootViewController: webViewController)
        webViewController.setAsNonDismissableModal()
        
        navigationController.present(navController, animated: true)
    }
    
    func showSupport() {
        showInWebView(urlString: Constant.supportLink, title: L10n.MenuButton.support)
    }
    
    /// Determines whether the viewcontroller or navigation stack are being dismissed
    /// SHOULD NEVER BE CALLED MANUALLY
    func goBack() {
        guard parentCoordinator != nil,
              parentCoordinator?.navigationController != navigationController,
              navigationController.viewControllers.count < 1 else {
            return
        }
        navigationController.dismiss(animated: true)
        parentCoordinator?.childDidFinish(child: self)
    }
    
    func popToRoot(completion: (() -> Void)? = nil) {
        navigationController.popToRootViewController(animated: true, completion: completion)
    }
    
    /// Remove the child coordinator from the stack after iit finnished its flow
    func childDidFinish(child: Coordinatable) {
        childCoordinators.removeAll(where: { $0 === child })
    }
    
    func dismissFlow() {
        navigationController.dismiss(animated: true)
        parentCoordinator?.childDidFinish(child: self)
    }
    
    /// Only call from coordinator subclasses
    func open<T: BaseControllable>(scene: T.Type,
                                   presentationStyle: UIModalPresentationStyle = .fullScreen,
                                   configure: ((T) -> Void)? = nil) {
        let controller = T()
        controller.coordinator = (self as? T.CoordinatorType)
        configure?(controller)
        navigationController.modalPresentationStyle = presentationStyle
        navigationController.show(controller, sender: nil)
    }
    
    /// Only call from coordinator subclasses
    func set<C: BaseCoordinator,
             VC: BaseControllable>(coordinator: C.Type,
                                   scene: VC.Type,
                                   configure: ((VC?) -> Void)? = nil) {
        let controller = VC()
        let coordinator = C(navigationController: navigationController)
        controller.coordinator = coordinator as? VC.CoordinatorType
        configure?(controller)
        
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        
        navigationController.setViewControllers([controller], animated: true)
    }
    
    /// Only call from coordinator subclasses
    func openModally<C: BaseCoordinator,
                     VC: BaseControllable>(coordinator: C.Type,
                                           scene: VC.Type,
                                           presentationStyle: UIModalPresentationStyle = .fullScreen,
                                           configure: ((VC?) -> Void)? = nil) {
        let controller = VC()
        let nvc = RootNavigationController(rootViewController: controller)
        nvc.modalPresentationStyle = presentationStyle
        nvc.modalPresentationCapturesStatusBarAppearance = true
        
        let coordinator = C(navigationController: nvc)
        controller.coordinator = coordinator as? VC.CoordinatorType
        configure?(controller)
        
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        
        navigationController.show(nvc, sender: nil)
    }
    
    // It prepares the next KYC coordinator OR returns true.
    func decideFlow(completion: ((Bool) -> Void)?) {
        guard !DynamicLinksManager.shared.shouldHandleDynamicLink else {
            completion?(false)
            return
        }
        
        let nvc = RootNavigationController()
        var coordinator: Coordinatable?
        
        switch UserManager.shared.profileResult {
        case .success(let profile):
            let status = profile?.status
            
            // TODO: ENABLE 2FA
            if status == VerificationStatus.emailPending
                || status == VerificationStatus.none
//              || !UserManager.shared.hasTwoStepAuth
                || profile?.isMigrated == false {
                coordinator = AccountCoordinator(navigationController: nvc)
                
            } else {
                completion?(true)
                return
            }
            
        case .failure(let error):
            guard error as? NetworkingError == .sessionExpired || error as? NetworkingError == .parameterMissing else {
                completion?(false)
                return
            }
            
            coordinator = AccountCoordinator(navigationController: RootNavigationController())
            
        default:
            completion?(false)
            return
        }
        
        guard let coordinator = coordinator else {
            completion?(false)
            return
        }
        
        coordinator.start()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        navigationController.show(coordinator.navigationController, sender: nil)
        
        completion?(false)
    }
    
    func showBottomSheetAlert(type: AlertType, completion: (() -> Void)? = nil) {
        guard let activeWindow = UIApplication.shared.activeWindow else { return }
        
        AlertPresenter(window: activeWindow).presentAlert(type, completion: {
            completion?()
        })
    }
    
    func showToastMessage(with error: Error? = nil,
                          model: InfoViewModel? = nil,
                          configuration: InfoViewConfiguration? = nil,
                          onTapCallback: (() -> Void)? = nil) {
        hideOverlay()
        LoadingView.hideIfNeeded()
        
        let error = error as? NetworkingError
        
        switch error {
        case .accessDenied:
            UserManager.shared.refresh()
            
        case .sessionExpired:
            openModally(coordinator: AccountCoordinator.self, scene: Scenes.SignIn) { vc in
                vc?.navigationItem.hidesBackButton = true
            }
            
            return
            
        default:
            break
        }
        
        guard let model = model,
              let configuration = configuration else { return }
        
        navigationController.showToastMessage(model: model,
                                              configuration: configuration,
                                              onTapCallback: onTapCallback)
    }
    
    func showOverlay(with viewModel: TransparentViewModel, completion: (() -> Void)? = nil) {
        guard let parent = navigationController.view else { return }
        
        let view = TransparentView()
        view.configure(with: .init())
        view.setup(with: viewModel)
        view.didHide = completion
        
        parent.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.layoutIfNeeded()
        view.show()
        parent.bringSubviewToFront(view)
    }
    
    func hideOverlay() {
        guard let view = navigationController.view.subviews.first(where: { $0 is TransparentView }) as? TransparentView else { return }
        view.hide()
    }
    
    func showPopup<V: ViewProtocol & UIView>(with config: WrapperPopupConfiguration<V.C>?,
                                             viewModel: WrapperPopupViewModel<V.VM>,
                                             confirmedCallback: @escaping (() -> Void),
                                             cancelCallback: (() -> Void)? = nil) -> WrapperPopupView<V>? {
        guard let superview = navigationController.view else { return nil }
        
        let view = WrapperPopupView<V>()
        view.configure(with: config)
        view.setup(with: viewModel)
        view.confirmCallback = confirmedCallback
        view.cancelCallback = cancelCallback
        
        superview.addSubview(view)
        superview.bringSubviewToFront(view)
        
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.layoutIfNeeded()
        view.alpha = 0
        
        UIView.animate(withDuration: Presets.Animation.short.rawValue) {
            view.alpha = 1
        }
        
        return view
    }
    
    func handleUnverifiedOrRestrictedUser(flow: ProfileModels.ExchangeFlow?, reason: BaseInfoModels.ComingSoonReason?) {
        guard UserManager.shared.profile != nil else {
            handleUserAccount()
            return
        }
        
        guard let restrictionReason = UserManager.shared.profile?.status.tradeStatus.restrictionReason else { return }
        switch restrictionReason {
        case .verification:
            handleUnverifiedUser(flow: flow)
            
        case .location:
            showComingSoon(reason: reason)
        }
    }
    
    func handleUnverifiedUser(flow: ProfileModels.ExchangeFlow?) {
        open(scene: Scenes.VerifyAccount) { [weak self] vc in
            vc.flow = flow
            
            vc.didTapMainButton = {
                switch flow {
                case .buy, .swap:
                    vc.navigationController?.popViewController(animated: true)
                    
                default:
                    self?.showAccountVerification()
                }
            }
            
            vc.didTapSecondayButton = {
                switch flow {
                case .buy, .swap:
                    self?.showSupport()
                    
                default:
                    vc.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func showComingSoon(reason: BaseInfoModels.ComingSoonReason?) {
        open(scene: Scenes.ComingSoon) { [weak self] vc in
            self?.handleComingSoonNavigation(vc)
            
            vc.reason = reason
        }
    }
    
    func showFailure(reason: BaseInfoModels.FailureReason?,
                     isModalDismissable: Bool = false,
                     hidesBackButton: Bool = true,
                     availablePayments: [PaymentCard.PaymentType]? = [],
                     containsDebit: Bool = false,
                     containsBankAccount: Bool = false) {
        open(scene: Scenes.Failure) { [weak self] vc in
            self?.handleFailureNavigation(vc, containsDebit: containsDebit, containsBankAccount: containsBankAccount)
            
            vc.reason = reason
            vc.isModalDismissable = isModalDismissable
            vc.navigationItem.hidesBackButton = hidesBackButton
            vc.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func showSuccess(reason: BaseInfoModels.SuccessReason?,
                     isModalDismissable: Bool = false,
                     hidesBackButton: Bool = true,
                     itemId: String? = nil,
                     transactionType: TransactionType? = nil) {
        open(scene: Scenes.Success) { [weak self] vc in
            self?.handleSuccessNavigation(vc)
            
            vc.reason = reason
            vc.isModalDismissable = isModalDismissable
            vc.navigationItem.hidesBackButton = hidesBackButton
            vc.navigationItem.rightBarButtonItem = nil
            vc.dataStore?.itemId = itemId
            vc.transactionType = transactionType ?? .base
        }
    }
    
    private func handleComingSoonNavigation(_ vc: ComingSoonViewController?) {
        guard let vc else { return }
        
        vc.didTapMainButton = {
            if vc.reason == .swap || vc.reason == .buy || vc.reason == .sell {
                vc.navigationController?.popViewController(animated: true)
            } else if vc.reason == .buyAch {
                vc.coordinator?.showBuy(coreSystem: vc.dataStore?.coreSystem, keyStore: vc.dataStore?.keyStore)
            }
        }
        
        vc.didTapSecondayButton = {
            if vc.reason == .swap || vc.reason == .buy {
                vc.coordinator?.showSupport()
            } else if vc.reason == .buyAch {
                vc.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func handleSuccessNavigation(_ vc: SuccessViewController?) {
        guard let vc else { return }
        
        vc.didTapMainButton = {
            switch vc.reason {
            case .documentVerification, .limitsAuthentication:
                vc.coordinator?.showBuy(coreSystem: vc.dataStore?.coreSystem,
                                        keyStore: vc.dataStore?.keyStore)
            default:
                vc.coordinator?.dismissFlow()
            }
        }
        
        vc.didTapSecondayButton = {
            switch vc.reason {
            case .documentVerification:
                LoadingView.show()
                vc.interactor?.getAssetSelectionData(viewModel: .init())
                
            case .limitsAuthentication:
                vc.coordinator?.popToRoot()
                
            default:
                vc.coordinator?.showExchangeDetails(with: vc.dataStore?.itemId,
                                                    type: vc.transactionType)
            }
        }
        
        vc.didTapThirdButton = {
            switch vc.reason {
            case .documentVerification:
                vc.coordinator?.showBuy(type: .ach,
                                        coreSystem: vc.dataStore?.coreSystem,
                                        keyStore: vc.dataStore?.keyStore)
            default:
                vc.coordinator?.showExchangeDetails(with: vc.dataStore?.itemId,
                                                    type: vc.transactionType)
            }
        }
    }
    
    private func handleFailureNavigation(_ vc: FailureViewController?, containsDebit: Bool, containsBankAccount: Bool) {
        guard let vc else { return }
        
        vc.didTapMainButton = {
            switch vc.reason {
            case .swap:
                vc.coordinator?.popToRoot()
                
            case .documentVerification:
                vc.coordinator?.showSupport()
                
            case .documentVerificationRetry:
                vc.veriffKYCManager = VeriffKYCManager(navigationController: vc.coordinator?.navigationController)
                vc.veriffKYCManager?.showExternalKYC { result in
                    vc.coordinator?.handleVeriffKYC(result: result, for: .kyc)
                }
                
            case .limitsAuthentication:
                LoadingView.show()
                vc.veriffKYCManager = VeriffKYCManager(navigationController: vc.coordinator?.navigationController)
                let requestData = VeriffSessionRequestData(quoteId: nil, isBiometric: true, biometricType: .pendingLimits)
                vc.veriffKYCManager?.showExternalKYCForLivenessCheck(livenessCheckData: requestData) { result in
                    switch result.status {
                    case .done:
                        BiometricStatusHelper.shared.checkBiometricStatus(resetCounter: true) { error in
                            vc.handleBiometricStatus(approved: error == nil)
                        }
                        
                    default:
                        vc.handleBiometricStatus(approved: false)
                    }
                }
                
            default:
                if containsDebit || containsBankAccount {
                    guard let vc = self.navigationController.viewControllers.first as? BuyViewController else {
                        return
                    }
                    
                    vc.updatePaymentMethod(paymentMethod: containsDebit ? .card : .ach)
                }
                
                vc.coordinator?.popToRoot()
            }
        }
        
        vc.didTapSecondayButton = {
            switch vc.reason {
            case .swap:
                vc.coordinator?.dismissFlow()

            case .buyCard, .buyAch, .plaidConnection, .sell:
                vc.coordinator?.showSupport()
                
            case .limitsAuthentication, .documentVerification, .documentVerificationRetry:
                vc.coordinator?.popToRoot()
                
            default:
                break
            }
        }
    }
    
    func prepareForDeeplinkHandling(coreSystem: CoreSystem, keyStore: KeyStore) {
        guard !childCoordinators.isEmpty else {
            handleDeeplink(coreSystem: coreSystem, keyStore: keyStore)
            return
        }
        
        childCoordinators.forEach { child in
            child.navigationController.dismiss(animated: false) { [weak self] in
                self?.childDidFinish(child: child)
                guard self?.childCoordinators.isEmpty == true else { return }
                self?.handleDeeplink(coreSystem: coreSystem, keyStore: keyStore)
            }
        }
    }
    
    private func handleDeeplink(coreSystem: CoreSystem, keyStore: KeyStore) {
        popToRoot()
        
        guard let deeplink = DynamicLinksManager.shared.dynamicLinkType else { return }
        DynamicLinksManager.shared.dynamicLinkType = nil
        
        switch deeplink {
        case .home:
            return
            
        case .profile:
            showProfile()
            
        case .swap:
            guard UserManager.shared.profile?.status.hasKYCLevelTwo == true else {
                self.handleUnverifiedUser(flow: .swap)
                return
            }
            
            showSwap(currencies: Store.state.currencies, coreSystem: coreSystem, keyStore: keyStore)
            
        case .setPassword:
            handleUserAccount()
        }
    }
}
