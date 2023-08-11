//
//  RegistrationConfirmationVIP.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

extension Scenes {
    static let RegistrationConfirmation = RegistrationConfirmationViewController.self
}

protocol RegistrationConfirmationViewActions: BaseViewActions, FetchViewActions, TwoStepViewActions {
    func validate(viewAction: RegistrationConfirmationModels.Validate.ViewAction)
    func confirm(viewAction: RegistrationConfirmationModels.Confirm.ViewAction)
    func resend(viewAction: RegistrationConfirmationModels.Resend.ViewAction)
}

protocol RegistrationConfirmationActionResponses: BaseActionResponses, FetchActionResponses, TwoStepActionResponses {
    func presentConfirm(actionResponse: RegistrationConfirmationModels.Confirm.ActionResponse)
    func presentResend(actionResponse: RegistrationConfirmationModels.Resend.ActionResponse)
}

protocol RegistrationConfirmationResponseDisplays: BaseResponseDisplays, FetchResponseDisplays, TwoStepResponseDisplays {
    func displayConfirm(responseDisplay: RegistrationConfirmationModels.Confirm.ResponseDisplay)
}

protocol RegistrationConfirmationDataStore: BaseDataStore, FetchDataStore, TwoStepDataStore {
    var confirmationType: RegistrationConfirmationModels.ConfirmationType { get set }
    var registrationRequestData: RegistrationRequestData? { get set }
    var setPasswordRequestData: SetPasswordRequestData? { get set }
    var setTwoStepAppModel: SetTwoStepAuth? { get set }
    var code: String? { get set }
}

protocol RegistrationConfirmationDataPassing {
    var dataStore: (any RegistrationConfirmationDataStore)? { get }
}

protocol RegistrationConfirmationRoutes: CoordinatableRoutes {
}
