//
//  CheckListViewController.swift
//  breadwallet
//
//  Created by Rok on 06/06/2022.
//
//

import UIKit

class CheckListViewController: BaseTableViewController<BaseCoordinator,
                               CheckListInteractor,
                               CheckListPresenter,
                               CheckListStore>,
                               CheckListResponseDisplays {
    typealias Models = CheckListModels
    
    override var sceneLeftAlignedTitle: String? { return "Checklist base VC" }
    var buttonTitle: String { return L10n.Button.confirm }
    
    var checklistTitle: LabelViewModel { return .text("OVERRIDE IN SUBCLASS") }
    var headerViewModel: LabelViewModel? { return nil }
    var checkmarks: [ChecklistItemViewModel] { return [] }
    var footerViewModel: LabelViewModel? { return nil }
    
    lazy var header: FELabel = {
        let label = FELabel()
        label.configure(with: .init(font: Fonts.Body.two,
                                    textColor: LightColors.Text.two,
                                    numberOfLines: 2))
        return label
    }()
    
    lazy var footer: FELabel = {
        let label = FELabel()
        label.configure(with: .init(font: Fonts.Body.two,
                                    textColor: LightColors.Text.two,
                                    textAlignment: .center,
                                    numberOfLines: 2))
        return label
    }()
    
    // MARK: - Overrides
    
    override func setupSubviews() {
        super.setupSubviews()
        
        if let model = headerViewModel {
            header.setup(with: model)
            view.addSubview(header)
            header.snp.makeConstraints { make in
                make.top.equalTo(leftAlignedTitleLabel.snp.bottom)
                make.height.equalTo(ViewSizes.Common.defaultCommon.rawValue)
                make.leading.equalTo(view).inset(Margins.large.rawValue)
                make.trailing.equalTo(view).offset(-Margins.extraHuge.rawValue * 2)
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
            header.isUserInteractionEnabled = true
            header.addGestureRecognizer(tapGesture)
        }
        
        if let model = footerViewModel {
            view.addSubview(footer)
            footer.setup(with: model)
            tableView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(Margins.extraHuge.rawValue)
                make.bottom.equalTo(footer.snp.top)
            }
            
            footer.snp.makeConstraints { make in
                make.bottom.equalTo(verticalButtons.snp.top).offset(-Margins.extraHuge.rawValue)
                make.centerX.equalToSuperview()
                make.leading.equalTo(view.snp.leadingMargin).inset(Margins.extraLarge.rawValue)
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(footerTapped))
            footer.isUserInteractionEnabled = true
            footer.addGestureRecognizer(tapGesture)
        }
        tableView.isScrollEnabled = false
    }
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        verticalButtons.wrappedView.configure(with: .init(buttons: [Presets.Button.primary]))
        verticalButtons.wrappedView.setup(with: .init(buttons: [.init(title: buttonTitle,
                                                                      callback: { [weak self] in
            self?.buttonTapped()
        })
        ]))
    }
    
    override func prepareData() {
        sections = [
            Models.Section.title,
            Models.Section.checkmarks
        ]
        
        sectionRows = [
            Models.Section.title: [checklistTitle],
            Models.Section.checkmarks: checkmarks
        ]
        
        super.prepareData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .title:
            cell =  self.tableView(tableView, labelCellForRowAt: indexPath)
            (cell as? WrapperTableViewCell<FELabel>)?.wrappedView.configure(with: .init(font: Fonts.Title.five, textColor: LightColors.Text.three))
            
        case .checkmarks:
            cell = self.tableView(tableView, checkmarkCellForRowAt: indexPath)
            
        default:
            cell = UITableViewCell()
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .huge, horizontal: .large)
        
        return cell
    }
    
    // MARK: - User Interaction
    override func buttonTapped() {
        super.buttonTapped()
    }
    
    @objc func headerTapped() {}
    
    @objc func footerTapped() {}
    
    // MARK: - CheckListResponseDisplay
    
    func displayVerificationProgress(responseDisplay: CheckListModels.VerificationInProgress.ResponseDisplay) {}
    
    // MARK: - Additional Helpers
}
