//
//  AuthorizeLoginViewController.swift
//  rockwallet
//
//  Created by Dino Gačević on 05/10/2023.
//
//

import UIKit

class AuthorizeLoginViewController: BaseTableViewController<AccountCoordinator,
                                    AuthorizeLoginInteractor,
                                    AuthorizeLoginPresenter,
                                    AuthorizeLoginStore>,
                                    AuthorizeLoginResponseDisplays {
    typealias Models = AuthorizeLoginModels
    
    lazy var authorizeButton = FEButton()
    lazy var rejectButton = FEButton()
    
    // MARK: - Overrides
    
    override var sceneLeftAlignedTitle: String? { return "Authorize login" }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        invalidateTimer()
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<GroupedTitleValuesView>.self)
        tableView.register(WrapperTableViewCell<CountdownTimerView>.self)
        
        tableView.contentInset.top = 60
        
        view.backgroundColor = Colors.Background.two
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .timer:
            cell = self.tableView(tableView, countdownTimerCellForRowAt: indexPath)
            
        case .description:
            guard let thisCell = self.tableView(tableView, infoViewCellForRowAt: indexPath) as? WrapperTableViewCell<WrapperView<FEInfoView>> else {
                return UITableViewCell()
            }
            
            thisCell.wrappedView.setupClearMargins()
            cell = thisCell
            
        case .data:
            cell = self.tableView(tableView, groupedTitleValueCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setupCustomMargins(all: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, countdownTimerCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? CountdownTimerViewModel,
              let cell: WrapperTableViewCell<CountdownTimerView> = tableView.dequeueReusableCell(for: indexPath) else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            view.countdownFinished = { [weak self] in
                DynamicLinksManager.shared.loginToken = nil
                self?.coordinator?.showFailure(reason: .authorizationFailed, isModalDismissable: false, hidesBackButton: true)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, groupedTitleValueCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? GroupedTitleValuesViewModel,
              let cell: WrapperTableViewCell<GroupedTitleValuesView> = tableView.dequeueReusableCell(for: indexPath) else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.setup(with: model)
        }
        
        return cell
    }
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        authorizeButton.configure(with: Presets.Button.primary)
        authorizeButton.setup(with: .init(title: "Authorize", callback: { [weak self] in
            self?.invalidateTimer()
            self?.interactor?.authorize(viewAction: .init())
            LoadingView.show()
        }))
        
        rejectButton.configure(with: Presets.Button.inverse)
        rejectButton.setup(with: .init(title: "Reject", callback: { [weak self] in
            self?.invalidateTimer()
            self?.coordinator?.showFailure(reason: .authorizationRejected, isModalDismissable: false, hidesBackButton: true)
        }))
        
        guard let authorizeButtonConfig = authorizeButton.config,
              let authorizeButtonModel = authorizeButton.viewModel,
              let rejectButtonConfig = rejectButton.config,
              let rejectButtonModel = rejectButton.viewModel else { return }
        verticalButtons.wrappedView.configure(with: .init(buttons: [authorizeButtonConfig, rejectButtonConfig]))
        verticalButtons.wrappedView.setup(with: .init(buttons: [authorizeButtonModel, rejectButtonModel]))
    }

    // MARK: - User Interaction

    // MARK: - AuthorizeLoginResponseDisplay
    
    func displayAuthorization(responseDisplay: AuthorizeLoginModels.Authorize.ResponseDisplay) {
        LoadingView.hideIfNeeded()
        
        if responseDisplay.success {
            coordinator?.showSuccess(reason: .authorizeLogin, isModalDismissable: false, hidesBackButton: true)
        } else {
            coordinator?.showFailure(reason: .authorizationFailed, isModalDismissable: false, hidesBackButton: true)
        }
    }

    // MARK: - Additional Helpers
    
    private func invalidateTimer() {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.timer.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<CountdownTimerView> else {
            return
        }
        
        cell.wrappedView.invalidateTimer()
    }
}
