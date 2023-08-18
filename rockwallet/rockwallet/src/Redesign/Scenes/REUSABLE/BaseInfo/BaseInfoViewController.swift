//
//  BaseInfoViewController.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 13.7.22.
//
//

import UIKit

class BaseInfoViewController: BaseTableViewController<BaseCoordinator,
                              BaseInfoInteractor,
                              BaseInfoPresenter,
                              BaseInfoStore>,
                              BaseInfoResponseDisplays {
    typealias Models = BaseInfoModels
    
    override var isModalDismissableEnabled: Bool { return isModalDismissable }
    var isModalDismissable = true
    
    var shouldDismiss = false
    
    var imageName: String? { return nil }
    var titleText: String? { return nil }
    var descriptionText: String? { return nil }
    
    var buttonViewModels: [ButtonViewModel] { return [] }
    var buttonConfigurations: [ButtonConfiguration] { return [] }
    
    var didTapMainButton: (() -> Void)?
    var didTapSecondaryButton: (() -> Void)?
    var didTapThirdButton: (() -> Void)?
    
    // MARK: - Overrides
    
    override var closeImage: UIImage? { return Asset.close.image }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard shouldDismiss else { return }
        coordinator?.dismissFlow()
    }
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        verticalButtons.wrappedView.configure(with: .init(buttons: buttonConfigurations))
        verticalButtons.wrappedView.setup(with: .init(buttons: buttonViewModels))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .image:
            cell = self.tableView(tableView, coverCellForRowAt: indexPath)
            
        case .title:
            cell = self.tableView(tableView, titleLabelCellForRowAt: indexPath)
            
        case .description:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(all: .extraHuge)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, coverCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<FEImageView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? ImageViewModel else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: Presets.Background.transparent)
            view.setup(with: model)
            view.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(ViewSizes.extraExtraHuge.rawValue)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleLabelCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? LabelViewModel else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(font: Fonts.Title.six, textColor: Colors.Text.three, textAlignment: .center))
            view.setup(with: model)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, descriptionLabelCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? LabelViewModel else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(font: Fonts.Body.two, textColor: Colors.Text.two, textAlignment: .center))
            view.setup(with: model)
            view.setupCustomMargins(vertical: .extraHuge, horizontal: .extraHuge)
            view.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(Margins.extraHuge.rawValue)
            }
        }
        
        return cell
    }
    
    // MARK: - User Interaction
    
    // MARK: - BaseInfoResponseDisplay
    
    /// Override in subclass
    func displayAssetSelectionData(responseDisplay: BaseInfoModels.Assets.ResponseDisplay) { }
    
    // MARK: - Additional Helpers
}
