//
//  RootNavigationController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 07/11/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class RootNavigationController: UINavigationController, UINavigationControllerDelegate {
    private var backgroundColor = UIColor.clear
    private var tintColor = UIColor.clear
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let vc = topViewController else { return .default }
        return vc.preferredStatusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        decideInterface(for: children.last)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        decideInterface(for: viewController)
    }
    
    func decideInterface(for viewController: UIViewController?) {
        guard let viewController = viewController else {
            backgroundColor = Colors.Contrast.one
            tintColor = Colors.Contrast.one
            
            setNormalNavigationBar()
            return
        }
        
        switch viewController {
        case is AssetDetailsViewController,
            is HomeScreenViewController,
            is SimpleWebViewController:
            backgroundColor = .clear
            tintColor = Colors.Text.three
            
        case is OnboardingViewController:
            backgroundColor = .clear
            tintColor = Colors.Background.two
            
        case is ImportKeyViewController:
            backgroundColor = Colors.primary
            tintColor = Colors.Contrast.two
            
        case is BuyViewController,
            is SwapViewController,
            is SellViewController,
            is ExchangeDetailsViewController,
            is OrderPreviewViewController,
            is SsnAdditionalInfoViewController:
            backgroundColor = Colors.Background.two
            tintColor = Colors.Text.three
            
        default:
            backgroundColor = Colors.Background.one
            tintColor = Colors.Text.three
        }
        
        let item = SimpleBackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
        
        setNormalNavigationBar()
    }
    
    func setNormalNavigationBar() {
        let backImage = Asset.back.image
        
        let normalAppearance = UINavigationBarAppearance()
        normalAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        normalAppearance.titleTextAttributes = navigationBar.titleTextAttributes ?? [:]
        normalAppearance.configureWithOpaqueBackground()
        normalAppearance.backgroundColor = backgroundColor
        normalAppearance.shadowColor = nil
        
        let scrollAppearance = UINavigationBarAppearance()
        scrollAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        scrollAppearance.titleTextAttributes = navigationBar.titleTextAttributes ?? [:]
        scrollAppearance.configureWithTransparentBackground()
        scrollAppearance.backgroundColor = backgroundColor
        scrollAppearance.shadowColor = nil
        
        navigationBar.scrollEdgeAppearance = normalAppearance
        navigationBar.standardAppearance = scrollAppearance
        navigationBar.compactAppearance = scrollAppearance
        
        let tint = tintColor
        UIView.animate(withDuration: Presets.Animation.short.rawValue) { [weak self] in
            self?.navigationBar.tintColor = tint
            self?.navigationItem.titleView?.tintColor = tint
            self?.navigationItem.leftBarButtonItems?.forEach { $0.tintColor = tint }
            self?.navigationItem.rightBarButtonItems?.forEach { $0.tintColor = tint }
            self?.navigationItem.leftBarButtonItem?.tintColor = tint
            self?.navigationItem.rightBarButtonItem?.tintColor = tint
            self?.navigationBar.layoutIfNeeded()
        }
        
        navigationBar.prefersLargeTitles = false
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: Fonts.Title.six,
            NSAttributedString.Key.foregroundColor: tint
        ]
        
        view.backgroundColor = backgroundColor
    }
}
