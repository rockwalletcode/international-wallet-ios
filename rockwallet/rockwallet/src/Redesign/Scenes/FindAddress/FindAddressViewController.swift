// 
//  AddressViewController.swift
//  breadwallet
//
//  Created by Dino Gacevic on 13/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let FindAddress = FindAddressViewController.self
}

class FindAddressViewController: ItemSelectionViewController {
    override var sceneTitle: String? { return L10n.AccountKYCLevelTwo.enterAddress }
    
    var callback: ((ResidentialAddress) -> Void)?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        searchController.searchBar.placeholder = L10n.Buy.address
        
        tableView.register(WrapperTableViewCell<AssetView>.self)
    }
    
    override func setupCloseButton(closeAction: Selector) {
        navigationItem.rightBarButtonItem = .init(title: L10n.Button.done.capitalized, style: .plain, target: self, action: #selector(doneTapped(_:)))
    }
    
    override func tableView(_ tableView: UITableView, itemCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<ItemView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? (any ItemSelectable)
        else { return UITableViewCell() }
        
        cell.setup { view in
            view.setup(with: .init(title: model.displayName ?? "", image: model.displayImage))
            view.setupCustomMargins(vertical: Margins.extraSmall, horizontal: Margins.huge)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) as? ResidentialAddress, let text = item.displayName, !text.isEmpty else { return }
        callback?(item)
        coordinator?.dismissFlow()
    }
    
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        interactor?.findAddress(viewAction: .init(input: searchText))
    }
    
    // MARK: - User Interaction
    
    @objc func doneTapped(_ sender: UIBarButtonItem) {
        guard let text = searchController.searchBar.text, !text.isEmpty else {
            coordinator?.dismissFlow()
            return
        }
        callback?(ResidentialAddress(text: text, id: nil))
        coordinator?.dismissFlow()
    }
}
