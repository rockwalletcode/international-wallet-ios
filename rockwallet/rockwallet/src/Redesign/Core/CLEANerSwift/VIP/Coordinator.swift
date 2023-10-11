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
        navigationController.show(nvc, sender: nil)
    }
    
    func showSwap(selectedCurrency: Currency? = nil, coreSystem: CoreSystem, keyStore: KeyStore) {
        decideFlow { [weak self] showScene in
            guard showScene,
                  let profile = UserManager.shared.profile,
                  profile.kycAccessRights.hasSwapAccess == true else {
                self?.handleUnverifiedOrRestrictedUser(flow: .swap, reason: .swap)
                
                return
            }
            
            self?.openModally(coordinator: ExchangeCoordinator.self, scene: Scenes.Swap) { vc in
                vc?.dataStore?.coreSystem = coreSystem
                vc?.dataStore?.keyStore = keyStore
                
                guard let selectedCurrency else { return }
                vc?.dataStore?.fromAmount = .zero(selectedCurrency)
            }
        }
    }
    
    func handleOauthLogin() {
        decideFlow { [weak self] showScene in
            guard showScene,
                  let profile = UserManager.shared.profile,
                  profile.kycAccessRights.hasSwapAccess == true else {
                self?.handleUnverifiedOrRestrictedUser(flow: .swap, reason: .swap)
                
                return
            }
            
            let redirectUri = DynamicLinksManager.shared.redirectUri ?? ""
            let scope = DynamicLinksManager.shared.urlScope ?? ""
            
            // TODO: Localize strings
            let model: PopupViewModel = .init(body: "Do you permit login to \(redirectUri) using scopes \(scope)",
                                              buttons: [.init(title: L10n.Button.ok)])
            
            self?.showPopup(on: self?.navigationController,
                            blurred: false,
                            with: model,
                            callbacks: [ { [weak self] in
                self?.getRedirectUri()
                self?.hidePopup()
            }]
            )}
    }
    
    func showBuy(selectedCurrency: Currency? = nil, type: PaymentCard.PaymentType, coreSystem: CoreSystem?, keyStore: KeyStore?) {
        decideFlow { [weak self] showScene in
            guard showScene,
                  let profile = UserManager.shared.profile,
                  ((type == .card && profile.kycAccessRights.hasBuyAccess) || (type == .ach && profile.kycAccessRights.hasAchAccess)) else {
                self?.handleUnverifiedOrRestrictedUser(flow: .buy, reason: type == .card ? .buy : .buyAch)
                
                return
            }
            
            self?.openModally(coordinator: ExchangeCoordinator.self, scene: Scenes.Buy) { vc in
                vc?.dataStore?.paymentMethod = type
                vc?.dataStore?.coreSystem = coreSystem
                vc?.dataStore?.keyStore = keyStore
                
                guard let selectedCurrency else { return }
                vc?.dataStore?.toAmount = .zero(selectedCurrency)
            }
        }
    }
    
    func showSell(selectedCurrency: Currency? = nil, coreSystem: CoreSystem?, keyStore: KeyStore?) {
        decideFlow { [weak self] showScene in
            let profile = UserManager.shared.profile
            let hasCardSellAccess = profile?.kycAccessRights.hasCardSellAccess
            let hasAchSellAccess = profile?.kycAccessRights.hasAchSellAccess
            
            guard showScene, hasAchSellAccess == true || hasCardSellAccess == true else {
                self?.handleUnverifiedOrRestrictedUser(flow: .sell, reason: .sell)
                return
            }
            
            guard profile?.status == .levelTwo(.kycWithSsn) else {
                self?.openModally(coordinator: ExchangeCoordinator.self, scene: Scenes.SsnAdditionalInfo)
                return
            }
            
            var paymentMethod: PaymentCard.PaymentType? {
                switch (hasAchSellAccess, hasCardSellAccess) {
                case (true, _): return .ach
                case (false, true): return .card
                default: return nil
                }
            }
            
            self?.openModally(coordinator: ExchangeCoordinator.self, scene: Scenes.Sell) { vc in
                vc?.dataStore?.coreSystem = coreSystem
                vc?.dataStore?.keyStore = keyStore
                vc?.dataStore?.paymentMethod = paymentMethod
                
                guard let selectedCurrency else { return }
                vc?.dataStore?.fromAmount = .zero(selectedCurrency)
            }
        }
    }
    
    func showProfile() {
        decideFlow { [weak self] showScene in
            guard showScene else { return }
            
            self?.openModally(coordinator: ProfileCoordinator.self, scene: Scenes.Profile)
        }
    }
    
    // TODO: showDeleteProfileInfo and showTwoStepAuthentication should be refactored when everything used coordinators.
    
    func showDeleteProfileInfo(from viewController: UIViewController?,
                               coordinator: BaseCoordinator?,
                               keyStore: KeyStore) {
        coordinator?.open(coordinator: AccountCoordinator.self,
                          scene: Scenes.DeleteProfileInfo,
                          on: viewController as? UINavigationController) { vc in
            vc?.dataStore?.keyStore = keyStore
        }
    }
    
    func showTwoStepAuthentication(from viewController: UIViewController? = nil,
                                   isModal: Bool = false,
                                   coordinator: BaseCoordinator?,
                                   keyStore: KeyStore?) {
        if isModal {
            coordinator?.openModally(coordinator: AccountCoordinator.self,
                                     scene: Scenes.TwoStepAuthentication) { vc in
                vc?.dataStore?.keyStore = keyStore
            }
        } else {
            coordinator?.open(coordinator: AccountCoordinator.self,
                              scene: Scenes.TwoStepAuthentication,
                              on: viewController as? UINavigationController) { vc in
                vc?.dataStore?.keyStore = keyStore
            }
        }
    }
    
    func showPaymailAddress(isPaymailFromAssets: Bool) {
        decideFlow { [weak self] showScene in
            guard showScene else { return }
            
            self?.openModally(coordinator: AccountCoordinator.self, scene: Scenes.PaymailAddress) { vc in
                let paymail = UserManager.shared.profile?.paymail
                vc?.dataStore?.screenType = paymail == nil ? .paymailNotSetup : .paymailSetup
                vc?.dataStore?.paymailAddress = "\(paymail ?? "")\(E.paymailDomain)"
                vc?.dataStore?.isPaymailFromAssets = isPaymailFromAssets
            }
        }
    }
    
    func showExchangeDetails(with exchangeId: String?, type: ExchangeType) {
        open(scene: Scenes.ExchangeDetails) { vc in
            vc.navigationItem.hidesBackButton = true
            vc.dataStore?.exchangeId = exchangeId
            vc.dataStore?.exchangeType = type
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
    
    func showPaymentMethodSupport() {
        showInWebView(urlString: Constant.paymentMethodSupport, title: L10n.MenuButton.support)
    }
    
    func showKYCLevelOne(isModal: Bool) {
        if isModal {
            openModally(coordinator: KYCCoordinator.self, scene: Scenes.KYCBasic)
        } else {
            open(coordinator: KYCCoordinator.self, scene: Scenes.KYCBasic)
        }
    }
    
    /// Determines whether the viewcontroller or navigation stack are being dismissed
    /// SHOULD NEVER BE CALLED MANUALLY
    func goBack() {
        guard parentCoordinator != nil,
              parentCoordinator?.navigationController != navigationController,
              navigationController.viewControllers.count < 1 else {
            return
        }
        
        dismissFlow()
    }
    
    func popToRoot(completion: (() -> Void)? = nil) {
        navigationController.popToRootViewController(animated: true, completion: completion)
    }
    
    func popViewController(completion: (() -> Void)? = nil) {
        navigationController.popViewController(animated: true, completion: completion)
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
    func open<VC: BaseControllable>(scene: VC.Type,
                                    presentationStyle: UIModalPresentationStyle = .fullScreen,
                                    configure: ((VC) -> Void)? = nil) {
        let controller = VC()
        controller.coordinator = (self as? VC.CoordinatorType)
        configure?(controller)
        navigationController.modalPresentationStyle = presentationStyle
        navigationController.show(controller, sender: nil)
    }
    
    /// Only call from coordinator subclasses
    func open<C: BaseCoordinator,
              VC: BaseControllable>(coordinator: C.Type,
                                    scene: VC.Type,
                                    on presentedNavigationController: UINavigationController? = nil,
                                    configure: ((VC?) -> Void)? = nil) {
        let navigationController = presentedNavigationController ?? navigationController
        
        let controller = VC()
        let coordinator = C(navigationController: navigationController)
        controller.coordinator = coordinator as? VC.CoordinatorType
        configure?(controller)
        
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        
        navigationController.show(controller, sender: nil)
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
    
    private func decideFlow(completion: ((Bool) -> Void)?) {
        guard !DynamicLinksManager.shared.shouldHandleDynamicLink else {
            
            DynamicLinksManager.shared.dynamicLinkType = nil
            
            completion?(false)
            return
        }
        
        let nvc = RootNavigationController()
        var coordinator: Coordinatable?
        
        switch UserManager.shared.profileResult {
        case .success(let profile):
            let status = profile?.status
            
            if status == VerificationStatus.emailPending
                || status == VerificationStatus.none
                || profile?.isMigrated == false {
                coordinator = AccountCoordinator(navigationController: nvc)
            } else {
                completion?(true)
                return
            }
            
        case .failure(let error):
            let error = error as? NetworkingError
            
            switch error {
            case .sessionExpired, .parameterMissing:
                coordinator = AccountCoordinator(navigationController: nvc)
                
            default:
                if error?.errorType == .twoStepRequired {
                    coordinator = AccountCoordinator(navigationController: nvc)
                } else {
                    completion?(false)
                    return
                }
            }
            
        default:
            completion?(false)
            return
        }
        
        guard let coordinator else {
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
                          configuration: InfoViewConfiguration? = nil) {
        hideOverlay()
        LoadingView.hideIfNeeded()
        
        let error = error as? NetworkingError
        
        switch error {
        case .accessDenied:
            UserManager.shared.refresh()
            
        default:
            break
        }
        
        guard let model = model,
              let configuration = configuration else {
            ToastMessageManager.shared.hide()
            return
        }
        
        ToastMessageManager.shared.show(model: model,
                                        configuration: configuration)
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
        let accessRights = UserManager.shared.profile?.kycAccessRights
        let restrictionReason = accessRights?.restrictionReason
        
        switch restrictionReason {
        case .kyc:
            showVerifyAccount(flow: flow)
            
        case .country, .state, .manuallyConfigured:
            let isRestrictedUSState = restrictionReason == .state && (!(accessRights?.hasSwapAccess ?? false)
                                                                      && !(accessRights?.hasBuyAccess ?? false)
                                                                      && !(accessRights?.hasAchAccess ?? false))
            
            let isGreyListedCountry = restrictionReason == .state && ((accessRights?.hasSwapAccess ?? false)
                                                                      && !(accessRights?.hasBuyAccess ?? false)
                                                                      && !(accessRights?.hasAchAccess ?? false))
            
            showComingSoon(reason: reason, restrictionReason: restrictionReason, isRestrictedUSState: isRestrictedUSState, isGreyListedCountry: isGreyListedCountry)
            
        default:
            break
        }
    }
    
    func showVerifyAccount(flow: ProfileModels.ExchangeFlow?,
                           isModalDismissable: Bool = false,
                           hidesBackButton: Bool = true) {
        open(scene: Scenes.VerifyAccount) { [weak self] vc in
            self?.handleVerifyAccountNavigation(vc, flow: flow)
            
            vc.flow = flow
            vc.isModalDismissable = isModalDismissable
            vc.navigationItem.hidesBackButton = hidesBackButton
            vc.navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func handleVerifyAccountNavigation(_ vc: VerifyAccountViewController?, flow: ProfileModels.ExchangeFlow?) {
        guard let vc else { return }
        
        vc.didTapMainButton = { [weak self] in
            switch flow {
            case .buy, .swap:
                vc.coordinator?.popViewController()
                
            default:
                self?.showKYCLevelOne(isModal: false)
            }
        }
        
        vc.didTapSecondaryButton = { [weak self] in
            switch flow {
            case .buy, .swap:
                self?.showSupport()
                
            default:
                vc.coordinator?.popViewController()
            }
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
                     exchangeType: ExchangeType? = nil) {
        open(scene: Scenes.Success) { [weak self] vc in
            self?.handleSuccessNavigation(vc)
            
            vc.reason = reason
            vc.isModalDismissable = isModalDismissable
            vc.navigationItem.hidesBackButton = hidesBackButton
            vc.navigationItem.rightBarButtonItem = nil
            vc.dataStore?.id = itemId
            vc.exchangeType = exchangeType ?? .unknown
        }
    }
    
    func showComingSoon(reason: BaseInfoModels.ComingSoonReason?,
                        isModalDismissable: Bool = false,
                        hidesBackButton: Bool = true,
                        coreSystem: CoreSystem? = nil,
                        keyStore: KeyStore? = nil,
                        restrictionReason: Profile.AccessRights.RestrictionReason?,
                        isRestrictedUSState: Bool = false,
                        isGreyListedCountry: Bool = false) {
        open(scene: Scenes.ComingSoon) { vc in
            var restrictedReason: BaseInfoModels.ComingSoonReason?
            if isRestrictedUSState {
                restrictedReason = .restrictedUSState
            } else if isGreyListedCountry {
                restrictedReason = .greyListedCountry
            } else {
                restrictedReason = reason
            }
            vc.reason = restrictedReason
            vc.isModalDismissable = isModalDismissable
            vc.navigationItem.hidesBackButton = hidesBackButton
            vc.navigationItem.rightBarButtonItem = nil
            vc.dataStore?.coreSystem = coreSystem
            vc.dataStore?.keyStore = keyStore
            vc.dataStore?.restrictionReason = restrictionReason
            vc.didTapMainButton = {
                vc.coordinator?.popViewController()
            }
        }
    }
    
    private func handleSuccessNavigation(_ vc: SuccessViewController?) {
        guard let vc else { return }
        
        vc.didTapMainButton = {
            switch vc.reason {
            case .documentVerification, .limitsAuthentication:
                LoadingView.show()
                vc.interactor?.getAssetSelectionData(viewModel: .init(type: .card))
                
            default:
                vc.coordinator?.dismissFlow()
            }
        }
        
        vc.didTapSecondaryButton = {
            switch vc.reason {
            case .documentVerification:
                LoadingView.show()
                vc.interactor?.getAssetSelectionData(viewModel: .init(type: .card))
                
            case .limitsAuthentication:
                vc.coordinator?.popToRoot()
                
            default:
                vc.coordinator?.showExchangeDetails(with: vc.dataStore?.id,
                                                    type: vc.exchangeType)
            }
        }
        
        vc.didTapThirdButton = {
            switch vc.reason {
            case .documentVerification:
                vc.coordinator?.showBuy(type: .ach,
                                        coreSystem: vc.dataStore?.coreSystem,
                                        keyStore: vc.dataStore?.keyStore)
                
            default:
                vc.coordinator?.showExchangeDetails(with: vc.dataStore?.id,
                                                    type: vc.exchangeType)
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
                
            case .veriffDeclined, .livenessCheckLimit:
                vc.coordinator?.dismissFlow()
                
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
        
        vc.didTapSecondaryButton = {
            switch vc.reason {
            case .swap:
                vc.coordinator?.dismissFlow()

            case .buyCard, .buyAch, .plaidConnection, .sell, .livenessCheckLimit, .veriffDeclined:
                vc.coordinator?.showSupport()
                
            case .limitsAuthentication, .documentVerification, .documentVerificationRetry:
                vc.coordinator?.popToRoot()
                
            default:
                break
            }
        }
    }
    
    func openUrl(url: URL) {
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:])
    }
    
    func showPinInput(keyStore: KeyStore?, callback: ((_ success: Bool) -> Void)?) {
        ExchangeAuthHelper.showPinInput(on: navigationController,
                                        keyStore: keyStore,
                                        callback: callback)
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
            
        case .setPassword:
            openModally(coordinator: AccountCoordinator.self, scene: Scenes.SetPassword) { vc in
                vc?.navigationItem.hidesBackButton = true
                vc?.dataStore?.code = DynamicLinksManager.shared.code
                DynamicLinksManager.shared.code = nil
            }
            
        case .oauth2:
            // TODO: remove the flow if we won't use deep linking oauth login
            // handleOauthLogin()
            return
        }
    }
    
    func getRedirectUri() {
        guard let urlParameters = DynamicLinksManager.shared.urlParameters else { return }
        
        let sortedParameters = urlParameters.sorted(by: <).map { "\($0)=\($1)" }.joined()
        let data = Oauth2LoginRequestData(parameters: urlParameters,
                                          sortedParameters: sortedParameters)
        
        Oauth2LoginWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let response):
                self?.showInWebView(urlString: response?.redirectUri ?? "", title: "OAuth 2.0 login")
            case .failure(let error):
                // TODO: Handle error
                print(error)
            }
        }
    }
}
