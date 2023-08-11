//
//  FetchVIP.swift
//  
//
//  Created by Rok Cresnik on 02/12/2021.
//

import Foundation

protocol FetchViewActions: Hashable, AnyObject {
    func getData(viewAction: FetchModels.Get.ViewAction)
}

protocol FetchActionResponses: Hashable, AnyObject {
    func presentData(actionResponse: FetchModels.Get.ActionResponse)
}

protocol FetchResponseDisplays: Hashable, AnyObject {
    func displayData(responseDisplay: FetchModels.Get.ResponseDisplay)
}

protocol FetchDataStore: Hashable, AnyObject {}

protocol FetchDataPassing: Hashable, AnyObject {
    var dataStore: (any FetchDataStore)? { get }
}
