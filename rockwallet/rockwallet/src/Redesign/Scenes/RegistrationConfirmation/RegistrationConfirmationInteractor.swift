//
//  RegistrationConfirmationInteractor.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

class RegistrationConfirmationInteractor: NSObject, Interactor, RegistrationConfirmationViewActions {
    typealias Models = RegistrationConfirmationModels
    
    var presenter: RegistrationConfirmationPresenter?
    var dataStore: RegistrationConfirmationStore?
    
    // MARK: - RegistrationConfirmationViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        guard let confirmationType = dataStore?.confirmationType else { return }
        
        presenter?.presentData(actionResponse: .init(item: Models.Item(type: confirmationType,
                                                                       email: UserDefaults.email
                                                                       ?? dataStore?.registrationRequestData?.email
                                                                       ?? DynamicLinksManager.shared.email)))
        
        switch dataStore?.confirmationType {
        case .twoStepEmail,
                .twoStepEmailLogin,
                .twoStepAccountEmailSettings,
                .twoStepEmailSendFunds,
                .twoStepEmailBuy,
                .twoStepAccountAppSettings,
                .twoStepEmailResetPassword,
                .twoStepEmailRequired,
                .twoStepDisable:
            resend(viewAction: .init())
            
        default:
            break
        }
        
        guard E.isDevelopment else { return }
        ConfirmationCodesWorker().execute { _ in }
    }
    
    func validate(viewAction: RegistrationConfirmationModels.Validate.ViewAction) {
        let code = viewAction.code ?? ""
        
        dataStore?.code = code
        
        if code.count == CodeInputView.numberOfFields {
            confirm(viewAction: .init())
        }
    }
    
    func confirm(viewAction: RegistrationConfirmationModels.Confirm.ViewAction) {
        switch viewAction.type ?? dataStore?.confirmationType {
        case .account:
            executeRegistrationConfirmation()
            
        case .twoStepEmail, .twoStepAccountEmailSettings:
            executeSetTwoStepEmail(type: .email, updateCode: dataStore?.code)
            
        case .twoStepAccountAppSettings:
            executeExchange(type: .app)
            
        case .twoStepApp:
            executeSetTwoStepApp()
            
        case .twoStepEmailLogin, .twoStepAppLogin:
            executeLogin()
            
        case .twoStepEmailResetPassword, .twoStepAppResetPassword:
            executeResetPassword()
            
        case .twoStepAppBuy, .twoStepEmailBuy, .twoStepAppSendFunds, .twoStepEmailSendFunds:
            presentConfirm()
            
        case .twoStepDisable:
            executeDisable()
            
        case .twoStepAppRequired, .twoStepEmailRequired:
            executeRefreshUserWithCode()
            
        case .twoStepAppBackupCode(let type):
            confirm(viewAction: .init(type: type))
            
        default:
            break
        }
    }
    
    func resend(viewAction: RegistrationConfirmationModels.Resend.ViewAction) {
        switch dataStore?.confirmationType {
        case .twoStepEmailLogin, .twoStepAppLogin, .twoStepEmailResetPassword,
                .twoStepAppResetPassword, .twoStepEmailBuy, .twoStepEmailSendFunds:
            executeCodeEmailRequest()
            
        case .twoStepEmail, .twoStepApp, .twoStepAccountEmailSettings,
                .twoStepAccountAppSettings, .twoStepEmailRequired, .twoStepDisable:
            executeChangeRequest()
            
        case .account:
            executeRegular()
            
        case .forgotPassword:
            executeEmailResend()
            
        default:
            break
        }
    }
    
    /// Regular account code request
    private func executeRegular() {
        ResendConfirmationWorker().execute { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.presentResend(actionResponse: .init())
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    /// Account 2FA required
    private func executeRefreshUserWithCode() {
        var secondFactorCode: String?
        var secondFactorBackup: String?
        
        switch dataStore?.confirmationType {
        case .twoStepAppBackupCode:
            secondFactorBackup = dataStore?.code
            
        default:
            secondFactorCode = dataStore?.code
        }
        
        UserManager.shared.refresh(secondFactorCode: secondFactorCode, secondFactorBackup: secondFactorBackup) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.presentConfirm(actionResponse: .init())
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
                
            default:
                return
            }
        }
    }
    
    /// Exchange TOTP or Email
    private func executeExchange(type: SetTwoStepAuthRequestData.AuthType) {
        TwoStepExchangeWorker().execute(requestData: TwoStepExchangeRequestData(code: dataStore?.code)) { [weak self] result in
            switch result {
            case .success(let data):
                let updateCode = data?.updateCode
                
                self?.executeSetTwoStepEmail(type: type, updateCode: updateCode)
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    /// Change code request
    private func executeChangeRequest() {
        TwoStepChangeWorker().execute(requestData: TwoStepChangeRequestData()) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.presentResend(actionResponse: .init())
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    /// Email code request
    private func executeCodeEmailRequest() {
        let email = dataStore?.registrationRequestData?.email ?? DynamicLinksManager.shared.email
        
        RequestTwoStepCodeWorker().execute(requestData: RequestTwoStepCodeRequestData(email: email)) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.presentResend(actionResponse: .init())
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    /// Reset
    private func executeResetPassword() {
        switch dataStore?.confirmationType {
        case .twoStepAppBackupCode:
            dataStore?.setPasswordRequestData?.secondFactorBackup = dataStore?.code
            
        default:
            dataStore?.setPasswordRequestData?.secondFactorCode = dataStore?.code
        }
        
        guard let setPasswordRequestData = dataStore?.setPasswordRequestData else { return }
        
        SetPasswordWorker().execute(requestData: setPasswordRequestData) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.presentConfirm(actionResponse: .init())
                
            case .failure(let error):
                self?.handleNextFailure(viewAction: .init(setPasswordRequestData: setPasswordRequestData, error: error))
            }
        }
    }
    
    /// Register/Login
    private func executeLogin() {
        switch dataStore?.confirmationType {
        case .twoStepAppBackupCode:
            dataStore?.registrationRequestData?.secondFactorBackup = dataStore?.code
            
        default:
            dataStore?.registrationRequestData?.secondFactorCode = dataStore?.code
        }
        
        guard let registrationRequestData = dataStore?.registrationRequestData else { return }
        
        RegistrationWorker().execute(requestData: registrationRequestData) { [weak self] result in
            switch result {
            case .success(let data):
                guard let sessionKey = data?.sessionKey, let sessionKeyHash = data?.sessionKeyHash else { return }
                
                UserManager.shared.setUserCredentials(email: registrationRequestData.email ?? "", sessionToken: sessionKey, sessionTokenHash: sessionKeyHash)
                
                self?.presentConfirm()
                
            case .failure(let error):
                self?.handleNextFailure(viewAction: .init(registrationRequestData: registrationRequestData, error: error))
            }
        }
    }
    
    /// Phone code
    private func executeSetTwoStepPhone() {
        let data = SetTwoStepPhoneCodeRequestData(code: dataStore?.code)
        SetTwoStepPhoneCodeWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success:
                self?.presentConfirm()
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    /// TOTP Confirm
    private func executeSetTwoStepApp() {
        let data = SetTwoStepAppCodeRequestData(code: dataStore?.code)
        SetTwoStepAppCodeWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success:
                self?.presentConfirm()
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    /// Set TOTP or Email
    private func executeSetTwoStepEmail(type: SetTwoStepAuthRequestData.AuthType, updateCode: String?) {
        let data = SetTwoStepAuthRequestData(type: type, updateCode: updateCode)
        SetTwoStepAuthWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success(let data):
                self?.dataStore?.setTwoStepAppModel = data
                
                self?.presentConfirm()
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    /// Regular account
    private func executeRegistrationConfirmation() {
        let data = RegistrationConfirmationRequestData(code: dataStore?.code)
        RegistrationConfirmationWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success:
                self?.presentConfirm()
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    /// Disable 2FA
    private func executeDisable() {
        let data = TwoStepDeleteRequestData(updateCode: dataStore?.code)
        TwoStepDeleteWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success:
                self?.presentConfirm()
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    /// Password reset request
    private func executeEmailResend() {
        PasswordResetWorker().execute(requestData: PasswordResetRequestData(email: dataStore?.registrationRequestData?.email)) { [weak self] result in
            switch result {
            case .success:
                self?.presenter?.presentConfirm(actionResponse: .init())
                
                UserManager.shared.setUserCredentials(email: self?.dataStore?.registrationRequestData?.email, sessionToken: nil, sessionTokenHash: nil)
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    // MARK: - Additional helpers
    
    private func presentConfirm() {
        UserManager.shared.refresh { [weak self] _ in
            self?.presenter?.presentConfirm(actionResponse: .init())
        }
    }
}
