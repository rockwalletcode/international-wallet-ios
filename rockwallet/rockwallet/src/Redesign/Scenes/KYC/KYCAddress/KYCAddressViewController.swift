//
//  KYCAddressViewController.swift
//  breadwallet
//
//  Created by Rok on 06/01/2023.
//
//

import UIKit

class KYCAddressViewController: BaseTableViewController<KYCCoordinator,
                                KYCAddressInteractor,
                                KYCAddressPresenter,
                                KYCAddressStore>,
                                KYCAddressResponseDisplays {
    
    typealias Models = KYCAddressModels
    
    override var isRoundedBackgroundEnabled: Bool { return true }
    override var sceneLeftAlignedTitle: String? {
        return L10n.Account.residentialAddress
    }
    
    private var veriffKYCManager: VeriffKYCManager?
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .mandatory:
            cell = self.tableView(tableView, labelCellForRowAt: indexPath)
            
        case .country:
            cell = self.tableView(tableView, countryTextFieldCellForRowAt: indexPath)
            
        case .postalCode:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
        case .cityAndState:
            cell = self.tableView(tableView, cityAndStateCellForRowAt: indexPath)
            
        case .address:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
        case .ssn:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
        case .ssnInfo:
            cell = self.tableView(tableView, multipleButtonsCellForRowAt: indexPath)
            
        case .confirm:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.contentView.setupCustomMargins(vertical: .small, horizontal: .zero)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, countryTextFieldCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? TextFieldModel,
              let cell: WrapperTableViewCell<FETextField> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: Presets.TextField.two)
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cityAndStateCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = dataSource?.sectionIdentifier(for: indexPath.section),
              let cell: WrapperTableViewCell<DoubleHorizontalTextboxView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? DoubleHorizontalTextboxViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
            view.finishedEditing = { [weak self] first, second in
                self?.interactor?.updateForm(viewAction: .init(section: section, value: (first, second)))
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, multipleButtonsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? MultipleButtonsViewModel,
              let cell: WrapperTableViewCell<MultipleButtonsView> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(buttons: [Presets.Button.noBorders],
                                       isRightAligned: true,
                                       axis: .horizontal))
            view.setup(with: model)
            
            view.callbacks = [
                ssnInfoTapped
            ]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section else { return }
        switch section {
        case .country:
            interactor?.pickCountry(viewAction: .init())
            
        case .address:
            coordinator?.showFindAddress(completion: { [weak self] address in
                self?.interactor?.setAddress(viewAction: .init(address: address))
            })
            
        case .cityAndState:
            interactor?.pickState(viewAction: .init())
            
        default:
            return
        }
    }
    
    override func textFieldDidFinish(for indexPath: IndexPath, with text: String?) {
        guard let section = dataSource?.sectionIdentifier(for: indexPath.section) else { return }
        
        interactor?.updateForm(viewAction: .init(section: section, value: text))
        
        super.textFieldDidFinish(for: indexPath, with: text)
    }
    
    // MARK: Responses
    
    override func displayData(responseDisplay: FetchModels.Get.ResponseDisplay) {
        super.displayData(responseDisplay: responseDisplay)
        interactor?.validate(viewAction: .init())
    }
    
    func displayForm(responseDisplay: KYCAddressModels.FormUpdated.ResponseDisplay) {
        guard var model = sectionRows[Models.Section.confirm]?.first as? ButtonViewModel else { return }
        
        model.enabled = responseDisplay.isValid
        sectionRows[Models.Section.confirm] = [model]
        
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.confirm.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<FEButton> else {
            return
        }
        
        cell.setup { view in
            view.setup(with: model)
        }
    }
    
    func displayExternalKYC(responseDisplay: KYCAddressModels.ExternalKYC.ResponseDisplay) {
        veriffKYCManager = VeriffKYCManager(navigationController: coordinator?.navigationController)
        veriffKYCManager?.showExternalKYC { [weak self] result in
            self?.coordinator?.handleVeriffKYC(result: result, for: .kyc)
        }
    }
    
    func displaySsnInfo(responseDisplay: KYCAddressModels.SsnInfo.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model)
    }
    
    // MARK: - User Interaction
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.submitInfo(viewAction: .init())
    }
    
    private func ssnInfoTapped() {
        interactor?.showSsnInfo(viewAction: .init())
    }
}
