// 
//  VerificationInProgressViewController.swift
//  breadwallet
//
//  Created by Dino Gacevic on 03/02/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let VerificationInProgress = VerificationInProgressViewController.self
}

class VerificationInProgressViewController: CheckListViewController {
    
    // MARK: - Overrides
    
    override var sceneLeftAlignedTitle: String? { return nil }
    
    override var checklistTitle: LabelViewModel {
        let attributedText = NSAttributedString(string: L10n.AccountKYCLevelTwo.inProgress,
                                                attributes: [.font: Fonts.Title.five])
        return .attributedText(attributedText)
    }
    
    override var checkmarks: [ChecklistItemViewModel] {
        return [.init(title: .text(L10n.AccountKYCLevelTwo.uploadingPhoto), image: .image(Asset.checkboxSelectedCircle.image)),
                .init(title: .text(L10n.AccountKYCLevelTwo.imageQualityChecked), image: .image(Asset.checkboxSelectedCircle.image)),
                .init(title: .text(L10n.AccountKYCLevelTwo.documentInspected), image: .image(Asset.checkboxSelectedCircle.image)),
                .init(title: .text(L10n.AccountKYCLevelTwo.biometricsVerified), image: .image(Asset.checkboxSelectedCircle.image)),
                .init(title: .text(L10n.Account.finalizingDecision), image: .animation(Animations.loader.animation, .loop))]
    }
    
    override var footerViewModel: LabelViewModel? {
        return .text(L10n.Account.waitFewMinutes)
    }
    
    override func prepareData() {
        super.prepareData()
        
        interactor?.checkVerificationProgress(viewAction: .init())
    }
    
    // Override to change footer bottom constraint, since there are no buttons on this screen
    override func setupSubviews() {
        super.setupSubviews()
        
        footer.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-Margins.extraHuge.rawValue)
            make.centerX.equalToSuperview()
            make.leading.equalTo(view.snp.leadingMargin).inset(Margins.extraLarge.rawValue)
        }
    }
    
    // MARK: - TableView setup
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .title:
            cell =  self.tableView(tableView, labelCellForRowAt: indexPath)
            (cell as? WrapperTableViewCell<FELabel>)?.wrappedView.configure(with: .init(font: Fonts.Title.five, textColor: Colors.Text.three))
            
        case .checkmarks:
            cell = self.tableView(tableView, checkmarkCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, checkmarkCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<ChecklistItemView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? ChecklistItemViewModel else {
            return UITableViewCell()
        }
        
        var labelConfig: LabelConfiguration {
            if let rowCount = sectionRows[CheckListModels.Section.checkmarks]?.count, indexPath.row == rowCount - 1 {
                return .init(font: Fonts.Body.one, textColor: Colors.Text.three)
            } else {
                return .init(font: ThemeManager.shared.font(for: Fonts.Secondary, size: 16), textColor: Colors.Text.three)
            }
        }
        
        cell.setup { view in
            view.configure(with: .init(title: labelConfig, image: nil))
            view.setup(with: model)
            view.setupCustomMargins(horizontal: .large)
        }
        
        return cell
    }
    
    // MARK: - ResponseDisplay
    
    override func displayVerificationProgress(responseDisplay: CheckListModels.VerificationInProgress.ResponseDisplay) {
        switch responseDisplay.status {
        case .success:
            coordinator?.showSuccess(reason: .documentVerification,
                                     isModalDismissable: false,
                                     hidesBackButton: true)
            
        case .failure(let reason):
            coordinator?.showFailure(reason: reason)
        }
    }
}
