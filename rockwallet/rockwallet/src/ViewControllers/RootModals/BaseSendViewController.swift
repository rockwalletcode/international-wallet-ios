// 
//  BaseSendViewController.swift
//  breadwallet
//
//  Created by Rok on 13/01/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import WalletKit

class BaseSendViewController: UIViewController {
    
    var presentVerifyPin: ((String, @escaping ((String) -> Void)) -> Void)?
    var onPublishSuccess: (() -> Void)?

    let sendingActivity = BRActivityViewController(message: L10n.TransactionDetails.titleSending)
    let sender: Sender
    
    var secondFactorBackup: String?
    var secondFactorCode: String?
    
    weak var coordinator: BaseCoordinator?
    
    init(sender: Sender) {
        self.sender = sender
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func send() {
        if let twoStepSettings = UserManager.shared.twoStepSettings, twoStepSettings.sending {
            coordinator?.openModally(coordinator: AccountCoordinator.self, scene: Scenes.RegistrationConfirmation) { vc in
                vc?.dataStore?.confirmationType = twoStepSettings.type == .authenticator ? .twoStepAppSendFunds : .twoStepEmailSendFunds
                vc?.isModalDismissable = true
                
                vc?.didDismiss = { didDismissSuccessfully in
                    guard didDismissSuccessfully else { return }
                    
                    switch vc?.dataStore?.confirmationType {
                    case .twoStepAppBackupCode:
                        self.secondFactorBackup = vc?.dataStore?.code
                        
                    default:
                        self.secondFactorCode = vc?.dataStore?.code
                    }
                    
                    _ = self.validateSendForm()
                    
                    DispatchQueue.main.async {
                        self.executeSend()
                    }
                }
            }
        } else {
            _ = validateSendForm()
            
            DispatchQueue.main.async {
                self.executeSend()
            }
        }
        
        DispatchQueue.main.async {
            self.present(self.sendingActivity, animated: true)
        }
    }
    
    private func executeSend() {
        let pinVerifier: PinVerifier = { [weak self] pinValidationCallback in
            guard let self = self else { return }
            
            self.sendingActivity.dismiss(animated: false) {
                self.presentVerifyPin?(L10n.VerifyPin.authorize) { pin in
                    self.parent?.view.isFrameChangeBlocked = false
                    pinValidationCallback(pin)
                    self.present(self.sendingActivity, animated: false)
                }
            }
        }
        
        sender.sendTransaction(allowBiometrics: true, pinVerifier: pinVerifier) { [weak self] result in
            guard let self = self else { return }
            self.sendingActivity.dismiss(animated: true) {
                defer {
                    self.sender.reset()
                }
                
                switch result {
                case .success:
                    self.onSuccess()
                case .creationError(let message):
                    self.showAlert(title: L10n.Alerts.sendFailure, message: message)
                case .publishFailure(let code, let message):
                    let codeStr = code == 0 ? "" : " (\(code))"
                    self.showAlert(title: L10n.Send.sendError, message: message + codeStr)
                case .insufficientGas:
                    self.showInsufficientGasError()
                }
            }
        }
    }
    
    func showInsufficientGasError() {}
    
    func validateSendForm() -> Bool { return false }
    
    func onSuccess() {
        onPublishSuccess?()
    }
}
