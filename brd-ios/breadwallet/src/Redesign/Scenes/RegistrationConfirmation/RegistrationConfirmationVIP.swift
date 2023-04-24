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

protocol RegistrationConfirmationViewActions: BaseViewActions, FetchViewActions {
    func validate(viewAction: RegistrationConfirmationModels.Validate.ViewAction)
    func confirm(viewAction: RegistrationConfirmationModels.Confirm.ViewAction)
    func resend(viewAction: RegistrationConfirmationModels.Resend.ViewAction)
}

protocol RegistrationConfirmationActionResponses: BaseActionResponses, FetchActionResponses {
    func presentConfirm(actionResponse: RegistrationConfirmationModels.Confirm.ActionResponse)
    func presentResend(actionResponse: RegistrationConfirmationModels.Resend.ActionResponse)
    func presentNextFailure(actionResponse: RegistrationConfirmationModels.NextFailure.ActionResponse)
}

protocol RegistrationConfirmationResponseDisplays: AnyObject, BaseResponseDisplays, FetchResponseDisplays {
    func displayConfirm(responseDisplay: RegistrationConfirmationModels.Confirm.ResponseDisplay)
    func displayNextFailure(responseDisplay: RegistrationConfirmationModels.NextFailure.ResponseDisplay)
}

protocol RegistrationConfirmationDataStore: BaseDataStore, FetchDataStore {
    var confirmationType: RegistrationConfirmationModels.ConfirmationType { get set }
    var registrationRequestData: RegistrationRequestData? { get set }
    var setPasswordRequestData: SetPasswordRequestData? { get set }
    var code: String? { get set }
}

protocol RegistrationConfirmationDataPassing {
    var dataStore: (any RegistrationConfirmationDataStore)? { get }
}

protocol RegistrationConfirmationRoutes: CoordinatableRoutes {
}
