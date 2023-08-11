//
//  KYCAddressVIP.swift
//  breadwallet
//
//  Created by Rok on 06/01/2023.
//
//

import UIKit

extension Scenes {
    static let KYCAddress = KYCAddressViewController.self
}

protocol KYCAddressViewActions: BaseViewActions, CountriesAndStatesViewActions {
    func updateForm(viewAction: KYCAddressModels.FormUpdated.ViewAction)
    func startExternalKYC(viewAction: KYCAddressModels.ExternalKYC.ViewAction)
    func submitInfo(viewAction: KYCAddressModels.Submit.ViewAction)
    func showSsnInfo(viewAction: KYCAddressModels.SsnInfo.ViewAction)
    func setAddress(viewAction: KYCAddressModels.Address.ViewAction)
    func validate(viewAction: KYCAddressModels.Validate.ViewAction)
}

protocol KYCAddressActionResponses: BaseActionResponses, CountriesAndStatesActionResponses {
    func presentForm(actionResponse: KYCAddressModels.FormUpdated.ActionResponse)
    func presentExternalKYC(actionResponses: KYCAddressModels.ExternalKYC.ActionResponse)
    func presentSsnInfo(actionResponse: KYCAddressModels.SsnInfo.ActionResponse)
}

protocol KYCAddressResponseDisplays: BaseResponseDisplays, CountriesAndStatesResponseDisplays {
    func displayForm(responseDisplay: KYCAddressModels.FormUpdated.ResponseDisplay)
    func displayExternalKYC(responseDisplay: KYCAddressModels.ExternalKYC.ResponseDisplay)
    func displaySsnInfo(responseDisplay: KYCAddressModels.SsnInfo.ResponseDisplay)
}

protocol KYCAddressDataStore: BaseDataStore, CountriesAndStatesDataStore {
    var firstName: String? { get set }
    var lastName: String? { get set }
    var birthDateString: String? { get set }
    var address: String? { get set }
    var city: String? { get set }
    var state: Place? { get set }
    var postalCode: String? { get set }
    var country: Country? { get set }
    
    var isValid: Bool { get }
}

protocol KYCAddressDataPassing {
    var dataStore: (any KYCAddressDataStore)? { get }
}

protocol KYCAddressRoutes: CoordinatableRoutes {
}
