//
//  UIViewController+Alerts.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-07-04.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

extension UIViewController {
    func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: L10n.Alert.error, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Button.ok, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String? = nil, message: String? = nil, buttonLabel: String = L10n.Button.ok) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonLabel, style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Info Popup
    // TODO: Unify / cleanup the logic with BaseCoordinator
    
    func showInfoPopup(with model: PopupViewModel, config: PopupConfiguration? = Presets.Popup.white, callbacks: [(() -> Void)] = []) {
        let blurView = UIVisualEffectView()
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let popup = FEPopupView()
        view.addSubview(popup)
        popup.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(view.snp.leadingMargin)
            make.trailing.greaterThanOrEqualTo(view.snp.trailingMargin)
        }
        popup.alpha = 1
        popup.layer.shadowColor = UIColor.black.cgColor
        popup.layer.shadowOpacity = 0.15
        popup.layer.shadowRadius = 4.0
        popup.layer.shadowOffset = .zero
        popup.layoutIfNeeded()
        
        popup.configure(with: config ?? Presets.Popup.white)
        popup.setup(with: model)
        
        popup.buttonCallbacks = callbacks
        popup.closeCallback = { [weak self] in
            self?.hidePopup()
        }
        
        UIView.animate(withDuration: Presets.Animation.short.rawValue,
                       delay: 0,
                       options: .transitionFlipFromBottom) {
            blurView.effect = UIBlurEffect(style: .dark)
            popup.alpha = 1
        }
    }
    
    @objc func hidePopup() {
        guard let popup = view.subviews.first(where: { $0 is FEPopupView })
        else { return }
        let blur = view.subviews.first(where: { $0 is UIVisualEffectView })
        
        UIView.animate(withDuration: Presets.Animation.short.rawValue) {
            popup.alpha = 0
            blur?.alpha = 0
        } completion: { _ in
            popup.removeFromSuperview()
            blur?.removeFromSuperview()
        }
    }
    
    func showInWebView(urlString: String, title: String) {
        guard let url = URL(string: urlString) else { return }
        let webViewController = SimpleWebViewController(url: url)
        webViewController.setup(with: .init(title: title))
        let navController = RootNavigationController(rootViewController: webViewController)
        webViewController.setAsNonDismissableModal()
        
        navigationController?.present(navController, animated: true)
    }
}
