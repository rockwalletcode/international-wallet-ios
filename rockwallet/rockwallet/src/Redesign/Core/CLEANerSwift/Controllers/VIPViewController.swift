//
//  VIPViewController.swift
//  
//
//  Created by Rok Cresnik on 01/12/2021.
//

import UIKit

protocol DataPresentable {
    func prepareData()
}

class VIPViewController<C: CoordinatableRoutes,
                        I: Interactor,
                        P: Presenter,
                        DS: BaseDataStore & NSObject>: UIViewController,
                                                       UIAdaptivePresentationControllerDelegate,
                                                       Controller,
                                                       BaseDataPassing,
                                                       BaseResponseDisplays,
                                                       ModalDismissable,
                                                       Blurrable,
                                                       DataPresentable {
    
    // MARK: Title and tab bar appearance
    
    var sceneTitle: String? { return nil }
    var sceneLeftAlignedTitle: String? { return nil }
    
    lazy var leftAlignedTitleLabel: UILabel = {
        let view = UILabel()
        view.font = Fonts.Title.five
        view.textAlignment = .left
        view.numberOfLines = 0
        view.textColor = Colors.Text.three
        return view
    }()
    
    lazy var verticalButtons: WrapperView<VerticalButtonsView> = {
        let view = WrapperView<VerticalButtonsView>()
        view.setupCustomMargins(top: .zero, leading: .large, bottom: .zero, trailing: .large)
        return view
    }()
    
    // MARK: Modal dimissable
    
    var isRoundedBackgroundEnabled: Bool { return false }
    var isModalDismissableEnabled: Bool { return false }
    var dismissText: String { return "" }
    var closeImage: UIImage? { return nil }

    var isRootInNavigationController: Bool {
        guard let navigationController = navigationController else { return true }
        return navigationController.viewControllers.first === self
    }

    // MARK: VIP
    
    weak var coordinator: C?
    var interactor: I?
    var dataStore: DS? {
        return interactor?.dataStore as? DS
    }
    
    lazy var blurView: UIVisualEffectView? = {
        let blur = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blur)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return view
    }()

    // MARK: Initialization
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        
        setupVIP()
    }

    func setupVIP() {
        interactor = I()
        let presenter = P()
        let dataStore = DS()
        presenter.viewController = self as? P.ResponseDisplays
        interactor?.presenter = presenter as? I.ActionResponses
        interactor?.dataStore = dataStore as? I.DataStore
    }

    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.Background.one
        
        setupSubviews()
        localize()
        prepareData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isModalDismissableEnabled {
            setupCloseButton(closeAction: #selector(dismissModal))
        } else if navigationItem.leftBarButtonItem?.image == closeImage
                    || navigationItem.leftBarButtonItem?.title == dismissText {
            navigationItem.leftBarButtonItem = nil
        } else if navigationItem.rightBarButtonItem?.image == closeImage
                    || navigationItem.rightBarButtonItem?.title == dismissText {
            navigationItem.rightBarButtonItem = nil
        }
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        parent?.presentationController?.delegate = self
        
        guard parent == nil else { return }

        coordinator?.goBack()
    }

    func setupCloseButton(closeAction: Selector) {}
    
    @objc func dismissModal() {
        navigationController?.dismiss(animated: true, completion: { [weak self] in
            self?.coordinator?.goBack()
        })
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        coordinator?.goBack()
    }

    func setupSubviews() {}

    func localize() {
        tabBarItem.title = sceneTitle
        title = sceneTitle
        leftAlignedTitleLabel.text = sceneLeftAlignedTitle
    }
    
    func prepareData() {}

    // MARK: BaseResponseDisplay
    
    func displayMessage(responseDisplay: MessageModels.ResponseDisplays) {
        LoadingView.hideIfNeeded()
        
        guard !isAccessDenied(responseDisplay: responseDisplay) else { return }
        
        if let coordinator {
            coordinator.showToastMessage(with: responseDisplay.error,
                                         model: responseDisplay.model,
                                         configuration: responseDisplay.config)
            
        } else {
            ToastMessageManager.shared.show(model: responseDisplay.model,
                                            configuration: responseDisplay.config)
        }
    }
    
    func isAccessDenied(responseDisplay: MessageModels.ResponseDisplays) -> Bool {
        guard let error = responseDisplay.error as? NetworkingError, case .accessDenied = error else { return false }
        
        coordinator?.showToastMessage(with: responseDisplay.error,
                                      model: responseDisplay.model,
                                      configuration: responseDisplay.config)
        
        return true
    }
    
    // MARK: - Blurrable
    
    func toggleBlur(animated: Bool) {
        guard let blurView = blurView else { return }
        guard blurView.superview == nil else {
            UIView.animate(withDuration: animated ? Presets.Animation.short.rawValue: 0) {
                blurView.alpha = 0
            } completion: { _ in
                blurView.removeFromSuperview()
            }
            return
        }
        
        blurView.alpha = 0
        blurView.frame = view.bounds
        view.addSubview(blurView)
        UIView.animate(withDuration: animated ? Presets.Animation.short.rawValue: 0) {
            blurView.alpha = 1
        }
    }
}

protocol ModalDismissable {
    var dismissText: String { get }

    func setupCloseButton(closeAction: Selector)
}

protocol Blurrable: UIViewController {
    var blurView: UIVisualEffectView? { get }
    
    func toggleBlur(animated: Bool)
}
