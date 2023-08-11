//
//  BackupCodesVIP.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 23.3.23.
//
//

import UIKit

extension Scenes {
    static let BackupCodes = BackupCodesViewController.self
}

protocol BackupCodesViewActions: BaseViewActions, FetchViewActions {
    func getBackupCodes(viewAction: BackupCodesModels.BackupCodes.ViewAction)
    func skipSaving(viewAction: BackupCodesModels.SkipBackupCodeSaving.ViewAction)
}

protocol BackupCodesActionResponses: BaseActionResponses, FetchActionResponses {
    func presentSkipSaving(actionResponse: BackupCodesModels.SkipBackupCodeSaving.ActionResponse)
}

protocol BackupCodesResponseDisplays: BaseResponseDisplays, FetchResponseDisplays {
    func displaySkipSaving(responseDisplay: BackupCodesModels.SkipBackupCodeSaving.ResponseDisplay)
}

protocol BackupCodesDataStore: BaseDataStore, FetchDataStore {
}

protocol BackupCodesDataPassing {
    var dataStore: (any BackupCodesDataStore)? { get }
}

protocol BackupCodesRoutes: CoordinatableRoutes {
}
