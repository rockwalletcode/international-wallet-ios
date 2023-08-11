//
//  Presenter.swift
//  MagicFactory
//
//  Created by Rok Cresnik on 20/08/2021.
//

import UIKit
import Frames

protocol Presenter: NSObject, BaseActionResponses {
    associatedtype ResponseDisplays: BaseResponseDisplays
    
    var viewController: ResponseDisplays? { get set }
}

extension Presenter {
    func presentError(actionResponse: MessageModels.Errors.ActionResponse) {
        guard !isAccessDenied(error: actionResponse.error) else { return }
        
        if let error = actionResponse.error as? NetworkingError, (error == .twoStepEmailRequired || error == .twoStepAppRequired) {
            let responseDisplay: MessageModels.ResponseDisplays = .init(error: error)
            
            viewController?.displayMessage(responseDisplay: responseDisplay)
        } else if self.isKind(of: SwapPresenter.self) {
            handleSwapErrors(actionResponse: actionResponse)
        } else if self.isKind(of: BuyPresenter.self) || self.isKind(of: SellPresenter.self) {
            handleBuyAndSellErrors(actionResponse: actionResponse)
        } else {
            handleGeneralErrors(error: actionResponse.error)
        }
    }
    
    private func handleGeneralErrors(error: Error?) {
        let responseDisplay: MessageModels.ResponseDisplays
        
        if let error = error as? NetworkingError, case .sessionExpired = error {
            responseDisplay = .init(error: error)
        } else if let error = error as? ExchangeErrors {
            let model = InfoViewModel(description: .text(error.errorMessage), dismissType: .auto)
            let config = Presets.InfoView.error
            responseDisplay = .init(model: model, config: config)
        } else if let error = error as? FEError {
            let message = error.errorMessage
            let model = InfoViewModel(description: .text(message), dismissType: .auto)
            
            let config = Presets.InfoView.error
            responseDisplay = .init(model: model, config: config)
        } else if error is TokenRequestError {
            let model = InfoViewModel(description: .text(L10n.ErrorMessages.authorizationFailed), dismissType: .auto)
            let config = Presets.InfoView.error
            responseDisplay = .init(model: model, config: config)
        } else {
            let model = InfoViewModel(headerTitle: .text(L10n.Alert.error), description: .text(error?.localizedDescription ?? ""), dismissType: .auto)
            let config = Presets.InfoView.error
            responseDisplay = .init(model: model, config: config)
        }
        
        viewController?.displayMessage(responseDisplay: responseDisplay)
    }
    
    private func handleSwapErrors(actionResponse: MessageModels.Errors.ActionResponse) {
        if let error = actionResponse.error as? ExchangeErrors, error.errorMessage == ExchangeErrors.selectAssets.errorMessage {
            (self as? SwapPresenter)?.presentAssetInfoPopup(actionResponse: .init())
        } else if let error = actionResponse.error as? FEError {
            let model = InfoViewModel(description: .text(error.errorMessage), dismissType: .auto)
            let config: InfoViewConfiguration
            
            switch error as? ExchangeErrors {
            case .highFees:
                config = Presets.InfoView.warning

            default:
                config = Presets.InfoView.error
            }
            
            viewController?.displayMessage(responseDisplay: .init(error: error, model: model, config: config))
        } else {
            viewController?.displayMessage(responseDisplay: .init())
        }
    }
    
    func handleBuyAndSellErrors(actionResponse: MessageModels.Errors.ActionResponse) {
        guard let error = actionResponse.error as? FEError else {
            viewController?.displayMessage(responseDisplay: .init())
            return
        }
        
        let model = InfoViewModel(description: .text(error.errorMessage), dismissType: .auto)
        let config = Presets.InfoView.error
        
        viewController?.displayMessage(responseDisplay: .init(error: error, model: model, config: config))
    }
    
    func isAccessDenied(error: Error?) -> Bool {
        guard let error = error as? NetworkingError, case .accessDenied = error else { return false }
        
        let model = InfoViewModel(description: .text(error.errorMessage), dismissType: .auto)
        let config = Presets.InfoView.error
        let responseDisplay: MessageModels.ResponseDisplays = .init(error: error, model: model, config: config)
        
        viewController?.displayMessage(responseDisplay: responseDisplay)
        
        return true
    }
    
    func presentNotification(actionResponse: MessageModels.Notification.ActionResponse) {
        let model = InfoViewModel(title: actionResponse.title != nil ?.text(actionResponse.title) : nil,
                                  description: actionResponse.body != nil ?.text(actionResponse.body) : nil,
                                  dismissType: actionResponse.dismiss)
        let config = Presets.InfoView.error
        
        viewController?.displayMessage(responseDisplay: .init(model: model, config: config))
    }
    
    func presentAlert(actionResponse: MessageModels.Alert.ActionResponse) {
        let model = InfoViewModel(title: .text(actionResponse.title),
                                  description: .text(actionResponse.body))
        let config = Presets.InfoView.error
        viewController?.displayMessage(responseDisplay: .init(model: model, config: config))
    }
}
