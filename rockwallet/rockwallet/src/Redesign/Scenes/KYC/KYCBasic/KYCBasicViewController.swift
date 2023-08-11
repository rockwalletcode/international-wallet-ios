//
//  KYCBasicViewController.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//
//

import UIKit

class KYCBasicViewController: BaseTableViewController<KYCCoordinator,
                              KYCBasicInteractor,
                              KYCBasicPresenter,
                              KYCBasicStore>,
                              KYCBasicResponseDisplays {
    typealias Models = KYCBasicModels
    
    override var isRoundedBackgroundEnabled: Bool { return true }
    override var dismissText: String { return L10n.Button.close }
    override var sceneLeftAlignedTitle: String? {
        return L10n.Account.personalInformation
    }
    
    private var isValid = false

    // MARK: - Overrides
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .name:
            cell = self.tableView(tableView, nameCellForRowAt: indexPath)
            
        case .birthdate:
            cell = self.tableView(tableView, dateCellForRowAt: indexPath)
            
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
            
            view.valueChanged = { [weak self] first, last in
                self?.interactor?.nameSet(viewAction: .init(first: first, last: last))
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, dateCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<DateView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? DateViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
            view.didPresentPicker = { [weak self] in
                self?.coordinator?.showDatePicker(model: model)
            }
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
    
    // MARK: - User Interaction
    
    @objc override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.submit(viewAction: .init())
    }

    // MARK: - KYCBasicResponseDisplay
    
    func displayValidate(responseDisplay: KYCBasicModels.Validate.ResponseDisplay) {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.confirm.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<FEButton> else { return }
        
        isValid = responseDisplay.isValid
        cell.wrappedView.isEnabled = isValid
    }
    
    func displaySubmit(responseDisplay: KYCBasicModels.Submit.ResponseDisplay) {
        coordinator?.showKYCAddress(firstName: dataStore?.firstName, lastName: dataStore?.lastName, birthDate: dataStore?.birthDateString)
    }
    
    // MARK: - Additional Helpers
}
