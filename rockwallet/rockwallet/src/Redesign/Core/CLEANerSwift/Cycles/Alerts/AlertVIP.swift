//
//  AlertVIP.swift
//  
//
//  Created by Rok Cresnik on 01/12/2021.
//

import Foundation

protocol AlertViewActions: BaseViewActions, FetchViewActions {}

protocol AlertActionResponses: BaseActionResponses, FetchActionResponses {
    func presentAlert(actionResponse: AlertModels.Alerts.ActionResponse)
}

protocol AlertResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displayAlert(responseDisplay: AlertModels.Alerts.ResponseDisplay)
}
