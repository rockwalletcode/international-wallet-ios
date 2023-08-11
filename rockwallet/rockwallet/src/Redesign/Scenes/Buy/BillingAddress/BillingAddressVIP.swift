//
//  BillingAddressVIP.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 01/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Frames
import UIKit

extension Scenes {
    static let BillingAddress = BillingAddressViewController.self
}

protocol BillingAddressViewActions: BaseViewActions, CountriesAndStatesViewActions {
    func nameSet(viewAction: BillingAddressModels.Name.ViewAction)
    func cityAndZipPostalSet(viewAction: BillingAddressModels.CityAndZipPostal.ViewAction)
    func stateProvinceSet(viewAction: BillingAddressModels.StateProvince.ViewAction)
    func addressSet(viewAction: BillingAddressModels.Address.ViewAction)
    func validate(viewAction: BillingAddressModels.Validate.ViewAction)
    func submit(viewAction: BillingAddressModels.Submit.ViewAction)
}

protocol BillingAddressActionResponses: BaseActionResponses, CountriesAndStatesActionResponses {
    func presentThreeDSecure(actionResponse: BillingAddressModels.ThreeDSecure.ActionResponse)
    func presentValidate(actionResponse: BillingAddressModels.Validate.ActionResponse)
    func presentSubmit(actionResponse: BillingAddressModels.Submit.ActionResponse)
}

protocol BillingAddressResponseDisplays: BaseResponseDisplays, CountriesAndStatesResponseDisplays {
    func displayThreeDSecure(responseDisplay: BillingAddressModels.ThreeDSecure.ResponseDisplay)
    func displayValidate(responseDisplay: BillingAddressModels.Validate.ResponseDisplay)
    func displaySubmit(responseDisplay: BillingAddressModels.Submit.ResponseDisplay)
}

protocol BillingAddressDataStore: BaseDataStore, CountriesAndStatesDataStore {
    var firstName: String? { get set }
    var lastName: String? { get set }
    var country: Country? { get set }
    var state: Place? { get set }
    var city: String? { get set }
    var zipPostal: String? { get set }
    var address: String? { get set }
    var paymentReference: String? { get set }
    var paymentstatus: AddCard.Status? { get set }
    
    var cardNumber: String? { get set }
    var expMonth: String? { get set }
    var expYear: String? { get set }
    var cvv: String? { get set }
}

protocol BillingAddressDataPassing {
    var dataStore: (any BillingAddressDataStore)? { get }
}

protocol BillingAddressRoutes: CoordinatableRoutes, CountriesAndStatesRoutes {}
