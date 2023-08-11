//
//  RegistrationConfirmationStore.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//
//

import UIKit

class RegistrationConfirmationStore: NSObject, BaseDataStore, RegistrationConfirmationDataStore {
    // MARK: - RegistrationConfirmationDataStore
    
    var confirmationType: RegistrationConfirmationModels.ConfirmationType = .account
    var registrationRequestData: RegistrationRequestData?
    var setPasswordRequestData: SetPasswordRequestData?
    var setTwoStepAppModel: SetTwoStepAuth?
    var code: String?
    
    // MARK: - TwoStepDataStore
    
    var secondFactorCode: String?
    var secondFactorBackup: String?
    
    // MARK: - Additional helpers
}
