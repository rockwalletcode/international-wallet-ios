//
//  BillingAddressViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 01/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class BillingAddressViewController: BaseTableViewController<ExchangeCoordinator,
                                    BillingAddressInteractor,
                                    BillingAddressPresenter,
                                    BillingAddressStore>,
                                    BillingAddressResponseDisplays {
    typealias Models = BillingAddressModels
    
    override var isRoundedBackgroundEnabled: Bool { return true }
    override var sceneTitle: String? {
        return L10n.Buy.billingAddress
    }
    
    private var isValid = false
    
    // MARK: - Overrides
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .name:
            cell = self.tableView(tableView, nameCellForRowAt: indexPath)
            
        case .country:
            cell = self.tableView(tableView, countryTextFieldCellForRowAt: indexPath)
            
        case .stateProvince:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
        case .cityAndZipPostal:
            cell = self.tableView(tableView, cityAndZipPostalCellForRowAt: indexPath)
            
        case .address:
            cell = self.tableView(tableView, textFieldCellForRowAt: indexPath)
            
        case .confirm:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.contentView.setupCustomMargins(vertical: .small, horizontal: .zero)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, nameCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<DoubleHorizontalTextboxView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? DoubleHorizontalTextboxViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
            view.valueChanged = { [weak self] first, second in
                self?.interactor?.nameSet(viewAction: .init(first: first, last: second))
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cityAndZipPostalCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<DoubleHorizontalTextboxView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? DoubleHorizontalTextboxViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
            view.valueChanged = { [weak self] first, second in
                self?.interactor?.cityAndZipPostalSet(viewAction: .init(city: first, zipPostal: second))
            }
        }
        
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
    
    override func tableView(_ tableView: UITableView, buttonCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var model = dataSource?.itemIdentifier(for: indexPath) as? ButtonViewModel,
              let cell: WrapperTableViewCell<FEButton> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        model.enabled = isValid
        
        cell.setup { view in
            view.configure(with: Presets.Button.primary)
            view.setup(with: model)
            view.setupCustomMargins(vertical: .large, horizontal: .large)
            view.snp.makeConstraints { make in
                make.height.equalTo(ViewSizes.Common.largeCommon.rawValue)
            }
            
            view.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .country:
            interactor?.pickCountry(viewAction: .init())
            
        default:
            return
        }
    }
    
    // MARK: - User Interaction
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        LoadingView.show()
        
        interactor?.submit(viewAction: .init())
    }

    // MARK: - BillingAddressResponseDisplay
    func displayValidate(responseDisplay: BillingAddressModels.Validate.ResponseDisplay) {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.confirm.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<FEButton> else { return }
        
        isValid = responseDisplay.isValid
        cell.wrappedView.isEnabled = isValid
    }
    
    func displaySubmit(responseDisplay: BillingAddressModels.Submit.ResponseDisplay) {
        LoadingView.hideIfNeeded()
        coordinator?.showOverlay(with: .success) { [weak self] in
            Store.trigger(name: .reloadBuy)
            self?.coordinator?.popToRoot()
        }
    }
    
    func displayThreeDSecure(responseDisplay: BillingAddressModels.ThreeDSecure.ResponseDisplay) {
        coordinator?.showThreeDSecure(url: responseDisplay.url)
    }
    
    // MARK: - Additional Helpers
    
    override func textFieldDidFinish(for indexPath: IndexPath, with text: String?) {
        let section = dataSource?.sectionIdentifier(for: indexPath.section)
        
        switch section as? Models.Section {
        case .stateProvince:
            interactor?.stateProvinceSet(viewAction: .init(stateProvince: text))
            
        case .address:
            interactor?.addressSet(viewAction: .init(address: text))
            
        default:
            break
        }
        
        super.textFieldDidFinish(for: indexPath, with: text)
    }
}
