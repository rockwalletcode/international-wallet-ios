//
//  SsnAdditionalInfoViewController.swift
//  breadwallet
//
//  Created by Dino Gacevic on 24/07/2023.
//
//

import UIKit
import Combine

class SsnAdditionalInfoViewController: BaseTableViewController<ExchangeCoordinator,
                                       SsnAdditionalInfoInteractor,
                                       SsnAdditionalInfoPresenter,
                                       SsnAdditionalInfoStore>,
                                       SsnAdditionalInfoResponseDisplays {
    typealias Models = SsnAdditionalInfoModels
    
    private var observers: [AnyCancellable] = []

    // MARK: - Overrides
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Sell.SsnInput.Title.additionalInfo
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<SsnInputView>.self)
        
        tableView.delaysContentTouches = false
        tableView.backgroundColor = Colors.Background.two
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .ssn:
            return self.tableView(tableView, ssnInputCellForRowAt: indexPath)
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, ssnInputCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<SsnInputView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? SsnInputViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: SsnInputConfiguration())
            view.setup(with: model)
            
            view.valueChanged = { [weak self] value in
                self?.interactor?.validateSsn(viewAction: .init(value: value))
            }
            
            view.confirmTapped = { [weak self] in
                self?.interactor?.confirmSsn(viewAction: .init())
            }
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .zero, horizontal: .large)
        
        return cell
    }

    // MARK: - User Interaction

    // MARK: - SsnAdditionalInfoResponseDisplay
    
    func displayValidateSsn(responseDisplay: SsnAdditionalInfoModels.ValidateSsn.ResponseDisplay) {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.ssn.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<SsnInputView>
        else { return }
        
        cell.setup { view in
            view.setup(with: responseDisplay.viewModel)
        }
    }
    
    func displayConfirmSsn(responseDisplay: SsnAdditionalInfoModels.ConfirmSsn.ResponseDisplay) {
        coordinator?.open(scene: Scenes.Waiting) { vc in
            vc.dataStore?.ssn = responseDisplay.ssn
            vc.errorPublisher.sink { [unowned self] error in
                self.interactor?.showSsnError(viewAction: .init(error: error))
            }.store(in: &self.observers)
        }
    }

    // MARK: - Additional Helpers
}
