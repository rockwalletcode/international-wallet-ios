//
//  AddCardViewController.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 03/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class AddCardViewController: BaseTableViewController<ExchangeCoordinator,
                             AddCardInteractor,
                             AddCardPresenter,
                             AddCardStore>,
                             AddCardResponseDisplays {
    typealias Models = AddCardModels
    
    override var isRoundedBackgroundEnabled: Bool { return true }
    override var isModalDismissableEnabled: Bool { return false }
    override var sceneTitle: String? { return L10n.Buy.addCard }
    
    private var isValid = false

    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<BankCardInputDetailsView>.self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .notificationPrompt:
            cell = self.tableView(tableView, infoViewCellForRowAt: indexPath)
            
        case .cardDetails:
            cell = self.tableView(tableView, bankCardInputDetailsCellForRowAt: indexPath)

        case .button:
            cell = self.tableView(tableView, buttonCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.contentView.setupCustomMargins(vertical: .small, horizontal: .zero)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, bankCardInputDetailsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<BankCardInputDetailsView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? BankCardInputDetailsViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            
            view.valueChanged = { [weak self] number, cvv in
                self?.interactor?.cardInfoSet(viewAction: .init(number: number, cvv: cvv))
            }
            
            view.didTapCvvInfo = { [weak self] in
                self?.interactor?.showCvvInfoPopup(viewAction: .init())
            }
            
            view.didTriggerExpirationField = { [weak self] in
                guard let self = self, let dataStore = self.dataStore else { return }
                self.coordinator?.showMonthYearPicker(model: [dataStore.months, dataStore.years])
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, infoViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? InfoViewModel,
              let cell: WrapperTableViewCell<WrapperView<FEInfoView>> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.setup { view in
                view.configure(with: dataStore?.fromCardWithdrawal == true ? Presets.InfoView.error : Presets.InfoView.verification)
                view.setup(with: model)
                view.setupCustomMargins(all: .large)
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
        
        LoadingView.show()
        
        interactor?.submit(viewAction: .init())
    }

    // MARK: - AddCardResponseDisplay
    
    func displayCardInfo(responseDisplay: AddCardModels.CardInfo.ResponseDisplay) {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.cardDetails.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<BankCardInputDetailsView> else { return }
        
        cell.wrappedView.setup(with: responseDisplay.model)
        tableView.invalidateTableViewIntrinsicContentSize()
    }
    
    func displayValidate(responseDisplay: AddCardModels.Validate.ResponseDisplay) {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.button.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<FEButton> else { return }
        
        isValid = responseDisplay.isValid
        cell.wrappedView.isEnabled = isValid
    }
    
    func displaySubmit(responseDisplay: AddCardModels.Submit.ResponseDisplay) {
        guard let store = dataStore else { return }
        
        coordinator?.showBillingAddress(store)
    }
    
    func displayCvvInfoPopup(responseDisplay: AddCardModels.CvvInfoPopup.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model, config: Presets.Popup.normal)
    }
    
    // MARK: - Additional Helpers
    
}
