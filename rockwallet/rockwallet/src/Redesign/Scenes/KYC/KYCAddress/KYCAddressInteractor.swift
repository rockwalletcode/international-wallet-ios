//
//  KYCAddressInteractor.swift
//  breadwallet
//
//  Created by Rok on 06/01/2023.
//
//

import UIKit

class KYCAddressInteractor: NSObject, Interactor, KYCAddressViewActions {
    typealias Models = KYCAddressModels

    var presenter: KYCAddressPresenter?
    var dataStore: KYCAddressStore?
    
    // MARK: - KYCAddressViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        UserInformationWorker().execute { [weak self] result in
            switch result {
            case .success(let profileData):
                self?.dataStore?.address = profileData?.address
                self?.dataStore?.city = profileData?.city
                self?.dataStore?.state = .init(iso2: profileData?.state?.iso2 ?? "", name: profileData?.state?.name ?? "")
                self?.dataStore?.postalCode = profileData?.zip
                self?.dataStore?.country = .init(iso2: profileData?.country?.iso2 ?? "", name: profileData?.country?.name ?? "")
                self?.dataStore?.ssn = profileData?.nologSsn
                
                self?.presenter?.presentData(actionResponse: .init(item: self?.dataStore))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func setAddress(viewAction: KYCAddressModels.Address.ViewAction) {
        guard let addressId = viewAction.address.id else {
            dataStore?.address = viewAction.address.text
            presenter?.presentData(actionResponse: .init(item: dataStore))
            return
        }
        
        let request = RetrievedAddressRequestModel(id: addressId)
        RetrieveAddressWorker().execute(requestData: request) { [weak self] result in
            switch result {
            case .success(let items):
                guard let address = items?.first else { return }
                self?.dataStore?.address = "\(address.street ?? "") \(address.buildingNumber ?? "")"
                self?.dataStore?.city = address.city
                self?.dataStore?.postalCode = address.postalCode
                self?.pickCountry(viewAction: .init(iso2: address.countryIso2, countryFullName: address.countryName))
                self?.pickState(viewAction: .init(code: address.provinceCode, state: address.province))
                self?.presenter?.presentData(actionResponse: .init(item: self?.dataStore))
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func updateForm(viewAction: KYCAddressModels.FormUpdated.ViewAction) {
        switch viewAction.section as? Models.Section {
        case .address:
            dataStore?.address = viewAction.value as? String
            
        case .postalCode:
            dataStore?.postalCode = viewAction.value as? String
            
        case .ssn:
            dataStore?.ssn = viewAction.value as? String
            
        case .cityAndState:
            let item = viewAction.value as? (String?, String?)
            dataStore?.city = item?.0
            dataStore?.state = .init(iso2: item?.1 ?? "", name: item?.1 ?? "")
            
        default:
            return
        }
        presenter?.presentForm(actionResponse: .init(isValid: dataStore?.isValid))
    }
    
    func submitInfo(viewAction: KYCAddressModels.Submit.ViewAction) {
        let state = dataStore?.country?.iso2 == Constant.countryUS ? dataStore?.state?.iso2 : dataStore?.state?.name
        
        let data = KYCUserInfoRequestData(firstName: dataStore?.firstName ?? "",
                                          lastName: dataStore?.lastName ?? "",
                                          dateOfBirth: dataStore?.birthDateString ?? "",
                                          address: dataStore?.address ?? "",
                                          city: dataStore?.city ?? "",
                                          zip: dataStore?.postalCode ?? "",
                                          country: dataStore?.country?.iso2 ?? "",
                                          state: state,
                                          nologSSN: dataStore?.ssn)
        
        KYCSubmitInfoWorker().execute(requestData: data) { [weak self] result in
            switch result {
            case .success:
                self?.startExternalKYC(viewAction: .init())
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    func startExternalKYC(viewAction: KYCAddressModels.ExternalKYC.ViewAction) {
        presenter?.presentExternalKYC(actionResponses: .init())
    }
    
    func showSsnInfo(viewAction: KYCAddressModels.SsnInfo.ViewAction) {
        presenter?.presentSsnInfo(actionResponse: .init())
    }
    
    func validate(viewAction: KYCAddressModels.Validate.ViewAction) {
        presenter?.presentForm(actionResponse: .init(isValid: dataStore?.isValid))
    }

    // MARK: - Additional helpers
}
