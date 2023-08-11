//
//  RecoveryKeyFlowController.swift
//  breadwallet
//
//  Created by Ray Vander Veen on 2019-03-18.
//  Copyright © 2019 Breadwinner AG. All rights reserved.
//

import UIKit

// Modes in which the the user can enter the recover key flow.
enum EnterRecoveryKeyMode {
    // User is generating the key for the first time.
    case generateKey
    
    // User entering the recovery key flow to write down the key.
    case writeKey
    
    // User is wiping the wallet from the device, which requires entry of the recovery key.
    case unlinkWallet
}

enum ExitRecoveryKeyAction {
    case generateKey
    case writeKey
    case confirmKey
    case unlinkWallet
    case abort
}

//
// Manages entry points for generating or writing down the paper key:
//
//  - new-user onboarding
//  - home screen prompt or security settings menu
//  - unlinking a wallet
//  - resetting the login PIN
//
class RecoveryKeyFlowController {
    
    static let pinTransitionDelegate = PinTransitioningDelegate()
    
    //
    // Entry point into the recovery key flow.
    //
    // pin - the user's PIN, which will already be set to a valid pin if entering from the onboarding flow
    // keyMaster - used for obtaining the recovery key phrase words
    // viewController - the view controller that is initiating the recovery key flow
    // context - event context for logging analytics events
    // dismissAction - a custom dismiss action
    // modalPresentation - whether the recovery key flow should be presented as a modal view controller
    // canExit - whether the user can exit the recovery key flow; when entering from onboarding,
    //          this is 'false' to ensure the user sees the first few intro pages of the flow
    //
    static func enterRecoveryKeyFlow(pin: String?,
                                     keyMaster: KeyMaster,
                                     from viewController: UIViewController,
                                     context: EventContext,
                                     showIntro: Bool,
                                     dismissAction: (() -> Void)?,
                                     modalPresentation: Bool = true,
                                     canExit: Bool = true) {
        
        let isGeneratingKey = UserDefaults.walletRequiresBackup
        let eventContext = (context == .none) ? (isGeneratingKey ? .generateKey : .writeKey) : context
        
        let recoveryKeyNavController = RecoveryKeyFlowController.makeNavigationController()
        var baseNavigationController: RootNavigationController?
        var modalPresentingViewController: UIViewController?
        
        if modalPresentation {
            modalPresentingViewController = viewController
        } else if let nc = viewController as? RootNavigationController {
            baseNavigationController = nc
        }
        
        let dismissFlow = {
            if let dismissAction = dismissAction {
                dismissAction()
            } else {
                if modalPresentation {
                    modalPresentingViewController?.dismiss(animated: true, completion: nil)
                } else {
                    baseNavigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
        
        let pushNext: ((UIViewController) -> Void) = { (next) in
            if modalPresentation {
                (baseNavigationController ?? recoveryKeyNavController).pushViewController(next, animated: true)
            } else {
                baseNavigationController?.pushViewController(next, animated: true)
            }
        }
        
        // invoked when the user leaves the write-recovery-key view controller
        let handleWriteKeyResult: ((ExitRecoveryKeyAction, [String]) -> Void) = { (action, words) in
            switch action {
            case .abort:
                let navController = context == .onboarding ? viewController : (baseNavigationController ?? recoveryKeyNavController)
                
                guard context != .viewRecoveryPhrase else {
                    navController.dismiss(animated: true)
                    return
                }
                
                promptToSetUpRecoveryKeyLater(from: navController) { userWantsToSetUpLater in
                    guard userWantsToSetUpLater else { return }
                    dismissFlow()
                }
                
            case .confirmKey:
                pushNext(ConfirmRecoveryKeyViewController(words: words,
                                                          keyMaster: keyMaster,
                                                          eventContext: eventContext,
                                                          confirmed: {
                    Store.perform(action: Alert.Show(.recoveryPhraseConfirmed(callback: { dismissFlow() })))
                }))
                
            default:
                break
            }
        }
        
        if showIntro {
            let introVC = RecoveryKeyIntroViewController()
            introVC.exitAction = .generateKey
            introVC.exitCallback = { exitAction in
                switch exitAction {
                case .generateKey:
                    self.ensurePinAvailable(pin: pin,
                                            presentingViewController: recoveryKeyNavController,
                                            keyMaster: keyMaster,
                                            pinResponse: { (responsePin) in
                        guard let phrase = keyMaster.seedPhrase(pin: responsePin) else { return }
                        let hideActionButtons = context == .viewRecoveryPhrase
                        pushNext(EnterPhraseViewController(keyMaster: keyMaster, reason: .display(phrase, hideActionButtons, handleWriteKeyResult)))
                    })

                default:
                    break
                }
            }
            
            if modalPresentation {
                recoveryKeyNavController.viewControllers = [introVC]
                modalPresentingViewController?.present(recoveryKeyNavController, animated: true, completion: nil)
            } else {
                baseNavigationController?.navigationItem.hidesBackButton = true
                baseNavigationController?.pushViewController(introVC, animated: true)
            }
        } else {
            let presentingViewController = modalPresentation ? modalPresentingViewController : baseNavigationController
            
            ensurePinAvailable(pin: pin,
                               presentingViewController: presentingViewController,
                               keyMaster: keyMaster,
                               pinResponse: { (responsePin) in
                guard let phrase = keyMaster.seedPhrase(pin: responsePin) else { return }
                let hideActionButtons = context == .viewRecoveryPhrase
                
                let enterPhraseViewController = EnterPhraseViewController(keyMaster: keyMaster, reason: .display(phrase, hideActionButtons, handleWriteKeyResult),
                                                                          showBackButton: true)
                
                baseNavigationController = RootNavigationController()
                baseNavigationController?.viewControllers = [enterPhraseViewController]
                baseNavigationController?.modalPresentationStyle = .fullScreen
                
                guard let baseNavigationController = baseNavigationController else { return }
                
                if modalPresentation {
                    modalPresentingViewController?.present(baseNavigationController, animated: true, completion: nil)
                } else {
                    baseNavigationController.navigationItem.hidesBackButton = true
                    baseNavigationController.pushViewController(baseNavigationController, animated: true)
                }
            })
        }
    }
    
    static func presentUnlinkWalletFlow(from viewController: UIViewController,
                                        keyMaster: KeyMaster,
                                        phraseEntryReason: PhraseEntryReason) {
        let navController = RecoveryKeyFlowController.makeNavigationController()
        
        let enterPhrase: (() -> Void) = {
            let enterPhraseVC = EnterPhraseViewController(keyMaster: keyMaster, reason: phraseEntryReason)
            navController.pushViewController(enterPhraseVC, animated: true)
        }
        
        let introVC = UnlinkWalletViewController()
        introVC.exitAction = .unlinkWallet
        introVC.exitCallback = { action in
            if action == .unlinkWallet {
                enterPhrase()
            } else if action == .abort {
                navController.dismiss(animated: true, completion: nil)
            }
        }

        navController.viewControllers = [introVC]
        viewController.present(navController, animated: true, completion: nil)
    }
    
    static func pushUnlinkWalletFlowWithoutIntro(from navigationController: UINavigationController,
                                                 keyMaster: KeyMaster,
                                                 phraseEntryReason: PhraseEntryReason,
                                                 completion: @escaping ((FEButton?, UIBarButtonItem?) -> Void)) {
        let enterPhraseVC = EnterPhraseViewController(keyMaster: keyMaster,
                                                      reason: phraseEntryReason,
                                                      showBackButton: false)
        
        enterPhraseVC.didToggleNextButton = { nextButton, barButton in
            completion(nextButton, barButton)
        }
        
        navigationController.pushViewController(enterPhraseVC, animated: true)
    }
    
    static func enterResetPinFlow(from viewController: UIViewController,
                                  keyMaster: KeyMaster,
                                  callback: @escaping ((String, UINavigationController) -> Void)) {
    
        let navController = RecoveryKeyFlowController.makeNavigationController()
        let enterPhraseVC = EnterPhraseViewController(keyMaster: keyMaster, reason: .validateForResettingPin({ phrase in
                Store.perform(action: Alert.Show(.walletRestored(callback: {
                    callback(phrase, navController)
            })))
        }))

        navController.viewControllers = [enterPhraseVC]
        
        viewController.present(navController, animated: true, completion: nil)
    }
    
    static func promptToSetUpRecoveryKeyLater(from viewController: UIViewController, setUpLater: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: L10n.RecoveryKeyFlow.exitRecoveryKeyPromptTitle,
                                      message: L10n.RecoveryKeyFlow.exitRecoveryKeyPromptBody,
                                      preferredStyle: .alert)
        
        let no = UIAlertAction(title: L10n.Button.no, style: .default, handler: nil)
        let yes = UIAlertAction(title: L10n.Button.yes, style: .default) { _ in
            setUpLater(true)
        }
        
        alert.addAction(no)
        alert.addAction(yes)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    private static func makeNavigationController() -> RootNavigationController {
        let navController = RootNavigationController()
        navController.modalPresentationStyle = .overFullScreen
        return navController
    }
    
    private static func ensurePinAvailable(pin: String?,
                                           presentingViewController: UIViewController?,
                                           keyMaster: KeyMaster,
                                           pinResponse: @escaping (String) -> Void) {
        
        // If the pin was already available, just call back with it.
        if let pin = pin, !pin.isEmpty {
            pinResponse(pin)
            return
        }
        
        let pinViewController = VerifyPinViewController(bodyText: L10n.VerifyPin.continueBody,
                                                        pinLength: Store.state.pinLength,
                                                        walletAuthenticator: keyMaster,
                                                        pinAuthenticationType: .recoveryKey,
                                                        success: { pin in
                                                            pinResponse(pin)
        })
        
        pinViewController.transitioningDelegate = RecoveryKeyFlowController.pinTransitionDelegate
        
        let navigation = UINavigationController(rootViewController: pinViewController)
        navigation.modalPresentationStyle = .overFullScreen
        navigation.modalPresentationCapturesStatusBarAppearance = true
        
        presentingViewController?.present(navigation, animated: true, completion: nil)
    }
}
