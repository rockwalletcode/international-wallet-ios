// 
//  KYCCoordinator.swift
//  breadwallet
//
//  Created by Rok on 06/06/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import AVFoundation
import UIKit
import Veriff

class KYCCoordinator: BaseCoordinator,
                      KYCBasicRoutes,
                      CountriesAndStatesRoutes,
                      KYCAddressRoutes,
                      AssetSelectionDisplayable {
    override func start() {
        let coordinator = AccountCoordinator(navigationController: navigationController)
        coordinator.start()
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
    }
    
    func showKYCAddress(firstName: String?, lastName: String?, birthDate: String?) {
        open(scene: Scenes.KYCAddress) { vc in
            vc.dataStore?.firstName = firstName
            vc.dataStore?.lastName = lastName
            vc.dataStore?.birthDateString = birthDate
        }
    }
    
    func showCountrySelector(countries: [Country], selected: ((Country?) -> Void)?) {
        openModally(coordinator: ExchangeCoordinator.self,
                    scene: Scenes.ItemSelection,
                    presentationStyle: .formSheet) { vc in
            vc?.dataStore?.items = countries
            vc?.dataStore?.sceneTitle = L10n.Account.selectCountry
            vc?.itemSelected = { item in
                selected?(item as? Country)
            }
        }
    }
    
    func showStateSelector(states: [Place], selected: ((Place?) -> Void)?) {
        openModally(coordinator: ExchangeCoordinator.self,
                    scene: Scenes.ItemSelection,
                    presentationStyle: .formSheet) { vc in
            vc?.dataStore?.items = states
            vc?.dataStore?.sceneTitle = L10n.Account.selectState
            vc?.itemSelected = { item in
                selected?(item as? Place)
            }
        }
    }
    
    func showFindAddress(completion: ((ResidentialAddress) -> Void)?) {
        openModally(coordinator: ExchangeCoordinator.self,
                    scene: Scenes.FindAddress,
                    presentationStyle: .formSheet) { vc in
            vc?.callback = { address in
                completion?(address)
            }
        }
    }
    
    // MARK: - Additional helpers
}

extension BaseCoordinator {
    func handleVeriffKYC(result: VeriffSdk.Result? = nil, for veriffType: VeriffKYCManager.VeriffType) {
        switch veriffType {
        case .kyc:
            forKYC(result: result)
            
        case .liveness:
            forLiveness()
            
        }
    }
    
    private func forKYC(result: VeriffSdk.Result?) {
        switch result?.status {
        case .done:
            open(scene: Scenes.VerificationInProgress) { vc in
                vc.navigationItem.hidesBackButton = true
            }
            
        case .error(let error):
            print(error.localizedDescription)
            
            showFailure(reason: .documentVerification)
            
        default:
            dismissFlow()
        }
    }
    
    private func forLiveness() {}
}

extension KYCCoordinator {
    func showDatePicker(model: DateViewModel) {
        guard let viewController = navigationController.children.last(where: { $0 is KYCBasicViewController }) as? KYCBasicViewController else { return }
        DatePickerViewController.show(on: viewController,
                                      sourceView: viewController.view,
                                      title: nil,
                                      date: model.date ?? Date(),
                                      minimumDate: Calendar.current.date(byAdding: .year, value: -120, to: Date()),
                                      maximumDate: Date()) { date in
            viewController.interactor?.birthDateSet(viewAction: .init(date: date))
        }
    }
}
