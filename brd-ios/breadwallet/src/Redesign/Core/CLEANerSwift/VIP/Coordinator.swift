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

class BaseCoordinator: NSObject,
                       Coordinatable {

    // TODO: should eventually die
    weak var modalPresenter: ModalPresenter? {
        get {
            guard let modalPresenter = presenter else {
                return parentCoordinator?.modalPresenter
            }

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
    var isKYCLevelTwo: Bool?

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
           profile.email?.isEmpty == false,
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
        if DynamicLinksManager.shared.code != nil {
            dismissFlow()
        }
        
        let nvc = RootNavigationController()
        let coordinator = AccountCoordinator(navigationController: nvc)
        coordinator.start()
        coordinator.parentCoordinator = self
        
        childCoordinators.append(coordinator)
        
        if DynamicLinksManager.shared.code != nil {
            UIApplication.shared.activeWindow?.rootViewController?.present(coordinator.navigationController, animated: true)
            
            DynamicLinksManager.shared.code = nil
        } else {
            navigationController.show(coordinator.navigationController, sender: nil)
        }
    }
    
    func showSwap(currencies: [Currency], coreSystem: CoreSystem, keyStore: KeyStore) {
        ExchangeCurrencyHelper.setUSDifNeeded { [weak self] in
            upgradeAccountOrShowPopup(flow: .swap, role: .kyc1) { showPopup in
                guard showPopup else { return }
                
                if UserManager.shared.profile?.canSwap == false {
                    self?.openModally(coordinator: SwapCoordinator.self, scene: Scenes.ComingSoon) { vc in
                        vc?.reason = .swapAndBuyCard
                    }
                    return
                }

                self?.openModally(coordinator: SwapCoordinator.self, scene: Scenes.Swap) { vc in
                    vc?.dataStore?.currencies = currencies
                    vc?.dataStore?.coreSystem = coreSystem
                    vc?.dataStore?.keyStore = keyStore
                    vc?.dataStore?.isKYCLevelTwo = self?.isKYCLevelTwo
                }
            }
        }
    }
    
    func showBuy(type: PaymentCard.PaymentType = .card, coreSystem: CoreSystem?, keyStore: KeyStore?) {
        ExchangeCurrencyHelper.setUSDifNeeded { [weak self] in
            upgradeAccountOrShowPopup(flow: .buy, role: .kyc2) { showPopup in
                guard showPopup else { return }
                
                if UserManager.shared.profile?.canBuy == false, type == .card {
                    self?.openModally(coordinator: BuyCoordinator.self, scene: Scenes.ComingSoon) { vc in
                        vc?.reason = .swapAndBuyCard
                    }
                    return
                }
                
                if UserManager.shared.profile?.canUseAch == false, type == .ach {
                    self?.openModally(coordinator: BuyCoordinator.self, scene: Scenes.ComingSoon) { vc in
                        vc?.reason = .buyAch
                        vc?.dataStore?.coreSystem = coreSystem
                        vc?.dataStore?.keyStore = keyStore
                    }
                    return
                }
                
                self?.openModally(coordinator: BuyCoordinator.self, scene: Scenes.Buy) { vc in
                    vc?.dataStore?.paymentMethod = type
                    vc?.dataStore?.coreSystem = coreSystem
                    vc?.dataStore?.keyStore = keyStore
                    vc?.prepareData()
                }
            }
        }
    }
    
    func showSell(for currency: Currency, coreSystem: CoreSystem?, keyStore: KeyStore?) {
        ExchangeCurrencyHelper.setUSDifNeeded { [weak self] in
            upgradeAccountOrShowPopup(flow: .buy, role: .kyc2) { showPopup in
                guard showPopup else { return }
                
                if UserManager.shared.profile?.canUseAch == false {
                    self?.openModally(coordinator: SellCoordinator.self, scene: Scenes.ComingSoon) { vc in
                        vc?.reason = .sell
                    }
                    return
                }
                
                self?.openModally(coordinator: SellCoordinator.self, scene: Scenes.Sell) { vc in
                    vc?.dataStore?.currency = currency
                    vc?.dataStore?.coreSystem = coreSystem
                    vc?.dataStore?.keyStore = keyStore
                    vc?.prepareData()
                }
            }
        }
    }
    
    func showProfile() {
        upgradeAccountOrShowPopup { [weak self] _ in
            self?.openModally(coordinator: ProfileCoordinator.self, scene: Scenes.Profile)
        }
    }
    
    func showAccountVerification() {
        let nvc = RootNavigationController()
        let coordinator = KYCCoordinator(navigationController: nvc)
        coordinator.start()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        navigationController.present(nvc, animated: true)
    }
    
    func showDeleteProfileInfo(keyMaster: KeyStore) {
        let nvc = RootNavigationController()
        let coordinator = DeleteProfileInfoCoordinator(navigationController: nvc)
        coordinator.start(with: keyMaster)
        coordinator.parentCoordinator = self
        
        childCoordinators.append(coordinator)
        UIApplication.shared.activeWindow?.rootViewController?.presentedViewController?.present(coordinator.navigationController, animated: true)
    }
    
    func showExchangeDetails(with exchangeId: String?, type: TransactionType) {
        open(scene: ExchangeDetailsViewController.self) { vc in
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
        showInWebView(urlString: C.supportLink, title: L10n.MenuButton.support)
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
    
    func showBuy() {
        guard let vc = navigationController.viewControllers.first as? BuyViewController else {
            return
        }
        navigationController.popToViewController(vc, animated: true)
    }
    
    func showBuyWithDifferentPayment(paymentMethod: PaymentCard.PaymentType?) {
        guard let vc = navigationController.viewControllers.first as? BuyViewController else {
            return
        }
        vc.updatePaymentMethod()
        
        navigationController.popToViewController(vc, animated: true)
    }
    
    func showSwap() {
        guard let vc = navigationController.viewControllers.first as? SwapViewController else {
            return
        }
        vc.didTriggerGetExchangeRate?()
        navigationController.popToViewController(vc, animated: true)
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
                                   presentationStyle: UIModalPresentationStyle = .fullScreen,
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
    // In which case we show 3rd party popup or continue to Buy/Swap.
    // TODO: refactor this once the "coming soon" screen is added
    func upgradeAccountOrShowPopup(flow: ExchangeFlow? = nil, role: CustomerRole? = nil, completion: ((Bool) -> Void)?) {
        let nvc = RootNavigationController()
        var coordinator: Coordinatable?
        
        switch UserManager.shared.profileResult {
        case .success(let profile):
            let roles = profile?.roles
            let status = profile?.status
            isKYCLevelTwo = status == .levelTwo(.levelTwo)
            
            if roles?.contains(.unverified) == true
                || roles?.isEmpty == true
                || status == VerificationStatus.emailPending
                || status == VerificationStatus.none {
                coordinator = AccountCoordinator(navigationController: nvc)
                
            } else if let kycLevel = role,
                      roles?.contains(kycLevel) == true {
                completion?(true)
            } else if role == nil {
                completion?(true)
            } else if let role = role {
                if profile?.status.isVerified(for: role) == true {
                    // new verirication (if user upgraded was used in sprint_5, this verification is needed
                    completion?(true)
                    return
                    
                } else if profile?.roles.contains(role) == true {
                    // normal sprint_4 users (till they create profile in sprint_5)
                    completion?(true)
                    return
                    
                } else {
                    let coordinator = KYCCoordinator(navigationController: nvc)
                    coordinator.role = role
                    coordinator.flow = flow
                    coordinator.start()
                    coordinator.parentCoordinator = self
                    childCoordinators.append(coordinator)
                    navigationController.show(coordinator.navigationController, sender: nil)
                    
                    completion?(false)
                    
                }
            }
            
        case .failure(let error):
            guard error as? NetworkingError == .sessionExpired
                    || error as? NetworkingError == .parameterMissing else {
                completion?(false)
                return
            }
            
            coordinator = AccountCoordinator(navigationController: RootNavigationController())
            
        default:
            completion?(true)
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
    
    private func checkProfileforRole(role: CustomerRole = .kyc1, completion: ((Bool) -> Void)?) {
        UserManager.shared.refresh { result in
            guard case let .success(profile) = result,
                  profile?.roles.contains(role) == true
            else {
                completion?(false)
                return
            }
            completion?(true)
        }
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
        LoadingView.hide()
        
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
    
    func hideMessage() {
        guard let superview = UIApplication.shared.activeWindow,
              let view = superview.subviews.first(where: { $0 is FEInfoView }) else { return }
        
        UIView.animate(withDuration: Presets.Animation.short.rawValue) {
            view.alpha = 0
        } completion: { _ in
            view.removeFromSuperview()
        }
    }
    
    func showUnderConstruction(_ feat: String) {
        showPopup(on: navigationController.topViewController,
                  with: .init(title: .text("Under construction"),
                              body: "The \(feat.uppercased()) functionality is being developed for You by the awesome RockWallet team. Stay tuned!"))
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
                                             confirmedCallback: @escaping (() -> Void)) -> WrapperPopupView<V>? {
        guard let superview = navigationController.view else { return nil }
        
        let view = WrapperPopupView<V>()
        view.configure(with: config)
        view.setup(with: viewModel)
        view.confirmCallback = confirmedCallback
        
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
}
