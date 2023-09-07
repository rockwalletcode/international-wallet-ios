//
//  ExchangeDetailsViewController.swift
//  breadwallet
//
//  Created by Rok on 06/07/2022.
//
//

import UIKit

class ExchangeDetailsViewController: BaseTableViewController<BaseCoordinator,
                                     ExchangeDetailsInteractor,
                                     ExchangeDetailsPresenter,
                                     ExchangeDetailsStore>,
                                     ExchangeDetailsResponseDisplays {
    
    typealias Models = ExchangeDetailsModels
    
    override var sceneLeftAlignedTitle: String? {
        switch dataStore?.exchangeType {
        case .buyCard, .buyAch:
            return L10n.Buy.details
            
        case .swap:
            return L10n.Swap.details
            
        case .sellAch, .sellCard:
            return L10n.Sell.details
            
        default:
            return ""
        }
    }
    
    override var isModalDismissableEnabled: Bool { return isModalDismissable }
    var isModalDismissable = true
    
    // MARK: - Overrides
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<AssetView>.self)
        tableView.register(WrapperTableViewCell<OrderView>.self)
        tableView.register(WrapperTableViewCell<BuyOrderView>.self)
        
        tableView.backgroundColor = Colors.Background.two
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section
        
        let cell: UITableViewCell
        switch section {
        case .header, .toCurrency, .fromCurrency:
            cell = self.tableView(tableView, headerCellForRowAt: indexPath)
            
            let topOffset: Margins = section == .header ? .huge : .zero
            cell.contentView.setupCustomMargins(top: topOffset, leading: .large, bottom: .small, trailing: .large)
            
        case .order, .timestamp, .transactionFrom, .transactionTo:
            cell = self.tableView(tableView, orderViewCellForRowAt: indexPath)
            
            (cell as? WrapperTableViewCell<OrderView>)?.wrappedView.didCopyValue = { [weak self] value in
                self?.interactor?.copyValue(viewAction: .init(value: value))
            }
            cell.contentView.setupCustomMargins(vertical: .extraSmall, horizontal: .large)
            
        case .image:
            cell = self.tableView(tableView, coverCellForRowAt: indexPath)
            
        case .buyOrder:
            cell = self.tableView(tableView, buyOrderCellForRowAt: indexPath)
            cell.contentView.setupCustomMargins(top: .zero, leading: .large, bottom: .medium, trailing: .large)
            
        case .none:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .small, horizontal: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, headerCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<AssetView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? AssetViewModel
        else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: Presets.AssetSelection.header)
            view.setup(with: model)
            view.content.setupCustomMargins(vertical: .medium, horizontal: .large)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, buyOrderCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<BuyOrderView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? BuyOrderViewModel
        else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init(BuyOrderConfiguration(instantBuyFeeConfig: Presets.TitleValue.common)))
            view.setup(with: model)
            
            view.networkFeeInfoTapped = { [weak self] in
                self?.interactor?.showInfoPopup(viewAction: .init(isCardFee: false))
            }
            
            view.cardFeeInfoTapped = { [weak self] in
                self?.interactor?.showInfoPopup(viewAction: .init(isCardFee: true))
            }
        }

        return cell
    }
    
    // MARK: - User Interaction

    // MARK: - ExchangeDetailsResponseDisplay
    func displayInfoPopup(responseDisplay: ExchangeDetailsModels.InfoPopup.ResponseDisplay) {
        coordinator?.showPopup(with: responseDisplay.model)
    }

    // MARK: - Additional Helpers
}
