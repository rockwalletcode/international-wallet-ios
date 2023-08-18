//
//  ItemSelectionViewController.swift
//  breadwallet
//
//  Created by Rok on 31/05/2022.
//
//

import UIKit

class ItemSelectionViewController: BaseTableViewController<ItemSelectionCoordinator,
                                   ItemSelectionInteractor,
                                   ItemSelectionPresenter,
                                   ItemSelectionStore>,
                                   ItemSelectionResponseDisplays,
                                   UISearchResultsUpdating,
                                   UISearchBarDelegate {
    typealias Models = ItemSelectionModels
    
    /// Show search on item selection
    var isSearchEnabled: Bool { return true }
    
    override var sceneTitle: String? { return dataStore?.sceneTitle ?? "" }

    var itemSelected: ((Any?) -> Void)?
    var searchController = UISearchController()
    
    var itemDeleted: (() -> Void)?
    
    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        
        navigationItem.title = sceneTitle
        
        tableView.separatorInset = .zero
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = Colors.Outline.one
        tableView.register(WrapperTableViewCell<ItemView>.self)
        
        guard isSearchEnabled else { return }
        setupSearchBar()
    }
    
    func setupSearchBar() {
        guard isSearchEnabled else {
            navigationItem.searchController = nil
            return
        }
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.sizeToFit()
        
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .addItem:
            cell = self.tableView(tableView, addItemCellForRowAt: indexPath)
            
        case .items:
            cell = self.tableView(tableView, itemCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.contentView.setupCustomMargins(vertical: .medium, horizontal: .zero)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, addItemCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<ItemView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? (any ItemSelectable)
        else { return UITableViewCell() }
        
        cell.setup { view in
            view.setup(with: .init(title: model.displayName ?? "", image: model.displayImage))
            view.setupCustomMargins(all: .large)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, itemCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<ItemView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? (any ItemSelectable)
        else { return UITableViewCell() }
        
        cell.setup { view in
            view.setup(with: .init(title: model.displayName ?? "", image: model.displayImage))
            view.setupCustomMargins(all: .large)
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section,
              section == Models.Section.items else {
            return
        }
        
        guard let model = dataSource?.itemIdentifier(for: indexPath), dataStore?.isSelectingEnabled == true else { return }
        itemSelected?(model)
        
        coordinator?.dismissFlow()
    }
    
    // MARK: - Search View Delegate
    
    func updateSearchResults(for searchController: UISearchController) {}
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            interactor?.getData(viewAction: .init())
            return
        }
        
        interactor?.search(viewAction: .init(text: searchText))
    }
    
    // MARK: - User Interaction

    // MARK: - ItemSelectionResponseDisplay
    
    func displayActionSheetRemovePayment(responseDisplay: ItemSelectionModels.ActionSheet.ResponseDisplay) {
        coordinator?.showPaymentsActionSheet(okButtonTitle: responseDisplay.actionSheetOkButton,
                                             cancelButtonTitle: responseDisplay.actionSheetCancelButton,
                                             handler: { [weak self] in
            self?.interactor?.removePaymenetPopup(viewAction: .init(instrumentID: responseDisplay.instrumentId, last4: responseDisplay.last4))
        })
    }
    
    func displayRemovePaymentPopup(responseDisplay: ItemSelectionModels.RemovePaymenetPopup.ResponseDisplay) {
        guard let navigationController = coordinator?.navigationController else { return }
        
        coordinator?.showPopup(on: navigationController,
                               blurred: false,
                               with: responseDisplay.popupViewModel,
                               config: responseDisplay.popupConfig,
                               closeButtonCallback: { [weak self] in
            self?.coordinator?.hidePopup()
        }, callbacks: [ {[weak self] in
                self?.coordinator?.hidePopup()
                self?.interactor?.removePayment(viewAction: .init())
            }, {[weak self] in
                self?.coordinator?.hidePopup()}
        ])
    }
    
    func displayRemovePaymentSuccess(responseDisplay: ItemSelectionModels.RemovePayment.ResponseDisplay) {
        interactor?.getPaymentCards(viewAction: .init())
        
        itemDeleted?()
    }

    // MARK: - Additional Helpers
}
