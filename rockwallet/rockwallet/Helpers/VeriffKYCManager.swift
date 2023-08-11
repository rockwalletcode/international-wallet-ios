// 
//  VeriffKYCManager.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 29/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit
import MobileIntelligence
import Veriff

class VeriffKYCManager: NSObject, VeriffSdkDelegate {
    enum VeriffType {
        case kyc, liveness
    }
    
    private var completion: ((VeriffSdk.Result) -> Void)?
    
    private var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func showExternalKYC(completion: ((VeriffSdk.Result) -> Void)?) {
        self.completion = completion
        
        navigationController?.popToRootViewController(animated: false)
        
        UserManager.shared.getVeriffSessionUrl { result in
            switch result {
            case .success(let data):
                guard let navigationController = self.navigationController else { return }
                self.turnOnSardineMobileIntelligence(completion: {
                    VeriffSdk.shared.delegate = self
                    VeriffSdk.shared.startAuthentication(sessionUrl: data?.sessionUrl ?? "",
                                                         configuration: Presets.veriff,
                                                         presentingFrom: navigationController)
                })
                
            case.failure(let error):
                guard let error = error as? ServerResponse.ServerError else { return }
                self.handleVeriffFailure(error: error)
                
            default:
                break
            }
        }
    }
    
    func showExternalKYCForLivenessCheck(livenessCheckData: VeriffSessionRequestData?, completion: ((VeriffSdk.Result) -> Void)?) {
        self.completion = completion
        
        UserManager.shared.getVeriffSessionUrl(livenessCheckData:
                .init(quoteId: livenessCheckData?.quoteId,
                      isBiometric: livenessCheckData?.isBiometric,
                      biometricType: livenessCheckData?.biometricType)) { result in
            switch result {
            case .success(let data):
                guard let navigationController = self.navigationController else { return }
                
                VeriffSdk.shared.delegate = self
                VeriffSdk.shared.startAuthentication(sessionUrl: data?.sessionUrl ?? "",
                                                     configuration: Presets.veriff,
                                                     presentingFrom: navigationController)
            
            case.failure(let error):
                guard let error = error as? ServerResponse.ServerError else { return }
                self.handleVeriffFailure(error: error)
                
            default:
                break
            }
        }
    }
    
    private func handleVeriffFailure(error: ServerResponse.ServerError?) {
        LoadingView.hideIfNeeded()
        
        guard let message = error?.errorMessage else { return }
        ToastMessageManager.shared.show(model: InfoViewModel(description: .text(message),
                                                             dismissType: .auto),
                                        configuration: Presets.InfoView.error)
    }
    
    func sessionDidEndWithResult(_ result: Veriff.VeriffSdk.Result) {
        MobileIntelligence.submitData { [weak self] _ in
            self?.turnOffSardineMobileIntelligence()
        }
        
        completion?(result)
        
        LoadingView.hideIfNeeded()
    }
    
    private func turnOffSardineMobileIntelligence() {
        let options = OptionsBuilder()
            .setClientId(with: "")
            .setSessionKey(with: "")
            .enableBehaviorBiometrics(with: false)
            .enableClipboardTracking(with: false)
            .enableFieldTracking(with: false)
            .setShouldAutoSubmitOnInit(with: false)
            .build()
        MobileIntelligence(withOptions: options)
    }
    
    private func turnOnSardineMobileIntelligence(completion: (() -> Void)?) {
        SardineSessionWorker().execute(requestData: SardineSessionRequestData()) { result in
            switch result {
            case .success(let data):
                guard let sessionKey = data?.sessionKey else { return }
                
                let options = OptionsBuilder()
                    .setClientId(with: E.sardineClientId)
                    .setSessionKey(with: sessionKey)
                    .setEnvironment(with: E.isProduction ? Options.ENV_PRODUCTION : Options.ENV_SANDBOX)
                    .enableBehaviorBiometrics(with: true)
                    .enableClipboardTracking(with: true)
                    .enableFieldTracking(with: true)
                    .setShouldAutoSubmitOnInit(with: true)
                    .build()
                MobileIntelligence(withOptions: options)
                
                completion?()
                
            case .failure:
                break
            }
        }
    }
}
