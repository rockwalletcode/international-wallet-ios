//
//  KYCBasicVIP.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

extension Scenes {
    static let KYCBasic = KYCBasicViewController.self
}

protocol KYCBasicViewActions: BaseViewActions, FetchViewActions {
    func birthDateSet(viewAction: KYCBasicModels.BirthDate.ViewAction)
    func nameSet(viewAction: KYCBasicModels.Name.ViewAction)
    func validate(viewAction: KYCBasicModels.Validate.ViewAction)
    func submit(viewAction: KYCBasicModels.Submit.ViewAction)
}

protocol KYCBasicActionResponses: BaseActionResponses, FetchActionResponses {
    func presentValidate(actionResponse: KYCBasicModels.Validate.ActionResponse)
    func presentSubmit(actionResponse: KYCBasicModels.Submit.ActionResponse)
}

protocol KYCBasicResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displayValidate(responseDisplay: KYCBasicModels.Validate.ResponseDisplay)
    func displaySubmit(responseDisplay: KYCBasicModels.Submit.ResponseDisplay)
}

protocol KYCBasicDataStore: BaseDataStore, FetchDataStore {
    var firstName: String? { get set }
    var lastName: String? { get set }
    var birthdate: Date? { get set }
    var birthDateString: String? { get set }
}

protocol KYCBasicDataPassing {
    var dataStore: (any KYCBasicDataStore)? { get }
}

protocol KYCBasicRoutes: CoordinatableRoutes {
}
