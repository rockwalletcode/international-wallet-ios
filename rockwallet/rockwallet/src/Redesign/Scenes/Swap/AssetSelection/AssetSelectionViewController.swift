//
//  AssetSelectionViewController.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 6.7.22.
//
//

import UIKit

extension Scenes {
    static let AssetSelection = AssetSelectionViewController.self
}

class AssetSelectionViewController: ItemSelectionViewController {
    override var sceneTitle: String? { return dataStore?.sceneTitle ?? "" }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        searchController.searchBar.placeholder = L10n.Title.searchAssets
        
        tableView.register(WrapperTableViewCell<AssetView>.self)
    }
    
    override func tableView(_ tableView: UITableView, itemCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<AssetView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? AssetViewModel
        else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: model.isDisabled ? Presets.AssetSelection.disabled : Presets.AssetSelection.enabled)
            view.setup(with: model)
            
            view.content.setupCustomMargins(vertical: .zero, horizontal: .large)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? AssetViewModel else { return }
        itemSelected?(model)
    }

    // MARK: - User Interaction

    // MARK: - AssetSelectionResponseDisplay

    // MARK: - Additional Helpers
}
