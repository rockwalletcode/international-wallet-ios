//
//  KYCBasicInteractor.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

class KYCBasicInteractor: NSObject, Interactor, KYCBasicViewActions {
    typealias Models = KYCBasicModels
    
    var presenter: KYCBasicPresenter?
    var dataStore: KYCBasicStore?
    
    // MARK: - KYCBasicViewActions
    
    func getData(viewAction: FetchModels.Get.ViewAction) {
        UserInformationWorker().execute { [weak self] result in
            switch result {
            case .success(let profileData):
                self?.dataStore?.firstName = profileData?.firstName
                self?.dataStore?.lastName = profileData?.lastName
                self?.dataStore?.birthdate = self?.getBirthDateFormatter().date(from: profileData?.dateOfBirth ?? "")
                if let birthDate = self?.dataStore?.birthdate {
                    self?.dataStore?.birthDateString = self?.getBirthDateFormatter().string(from: birthDate)
                }
                
                self?.presenter?.presentData(actionResponse: .init(item: self?.dataStore))
                self?.validate(viewAction: .init())
                
            case .failure(let error):
                self?.presenter?.presentData(actionResponse: .init(item: self?.dataStore))
                self?.presenter?.presentError(actionResponse: .init(error: error))
                
            }
        }
    }
    
    func nameSet(viewAction: KYCBasicModels.Name.ViewAction) {
        dataStore?.firstName = viewAction.first
        dataStore?.lastName = viewAction.last
        
        validate(viewAction: .init())
    }
    
    func birthDateSet(viewAction: KYCBasicModels.BirthDate.ViewAction) {
        if let date = viewAction.date {
            dataStore?.birthdate = date
            dataStore?.birthDateString = getBirthDateFormatter().string(from: dataStore?.birthdate ?? Date())
        }
        
        presenter?.presentData(actionResponse: .init(item: dataStore))
        validate(viewAction: .init())
    }
    
    func validate(viewAction: KYCBasicModels.Validate.ViewAction) {
        let isValid = FieldValidator.validate(fields: [dataStore?.firstName,
                                                       dataStore?.lastName,
                                                       dataStore?.birthDateString])
        
        presenter?.presentValidate(actionResponse: .init(isValid: isValid))
    }
    
    func submit(viewAction: KYCBasicModels.Submit.ViewAction) {
        guard let birthDate = dataStore?.birthdate,
              let legalDate = Calendar.current.date(byAdding: .year, value: -18, to: Date()),
              birthDate <= legalDate else {
            presenter?.presentNotification(actionResponse: .init(body: L10n.Account.verification))
            return
        }
        
        presenter?.presentSubmit(actionResponse: .init())
    }
    
    // MARK: - Additional helpers
    
    func getBirthDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter
    }
}
