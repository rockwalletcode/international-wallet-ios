//
//  BackupCodesViewController.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 23.3.23.
//
//

import UIKit

class BackupCodesViewController: BaseTableViewController<AccountCoordinator,
                                 BackupCodesInteractor,
                                 BackupCodesPresenter,
                                 BackupCodesStore>,
                                 BackupCodesResponseDisplays {
    typealias Models = BackupCodesModels

    // MARK: - Overrides
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.BackupCodes.title
    }
    
    lazy var nextButton: FEButton = {
        let view = FEButton()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.register(WrapperTableViewCell<BackupCodesView>.self)
    }
    
    override func setupVerticalButtons() {
        super.setupVerticalButtons()
        
        continueButton.configure(with: Presets.Button.primary)
        continueButton.setup(with: .init(title: L10n.Button.download,
                                         image: Asset.download.image,
                                         enabled: true,
                                         callback: { [weak self] in
            self?.createPDF()
        }))
        
        nextButton.configure(with: Presets.Button.noBorders)
        nextButton.setup(with: .init(title: L10n.Button.continueAction,
                                     isUnderlined: true,
                                     enabled: true,
                                     callback: { [weak self] in
            self?.buttonTapped()
        }))
        
        guard let continueButtonConfig = continueButton.config,
              let continueButtonModel = continueButton.viewModel,
              let nextButtonConfig = nextButton.config,
              let nextButtonModel = nextButton.viewModel else { return }
        verticalButtons.wrappedView.configure(with: .init(buttons: [continueButtonConfig, nextButtonConfig]))
        verticalButtons.wrappedView.setup(with: .init(buttons: [continueButtonModel, nextButtonModel]))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch dataSource?.sectionIdentifier(for: indexPath.section) as? Models.Section {
        case .instructions:
            cell = self.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
            
        case .backupCodes:
            cell = self.tableView(tableView, backupCodesCellForRowAt: indexPath)
        
        case .getNewCodes:
            cell = self.tableView(tableView, multipleButtonsCellForRowAt: indexPath)
            
        default:
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setBackground(with: Presets.Background.transparent)
        cell.setupCustomMargins(vertical: .large, horizontal: .large)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, multipleButtonsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? MultipleButtonsViewModel,
              let cell: WrapperTableViewCell<MultipleButtonsView> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(buttons: [Presets.Button.noBorders],
                                       axis: .horizontal))
            view.setup(with: model)
            
            view.callbacks = [
                getCodesTapped
            ]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, backupCodesCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<BackupCodesView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? BackupCodesViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
        }
        
        return cell
    }

    // MARK: - User Interaction
    
    override func buttonTapped() {
        super.buttonTapped()
        
        interactor?.skipSaving(viewAction: .init())
    }
    
    private func getCodesTapped() {
        interactor?.getBackupCodes(viewAction: .init(method: .delete))
    }

    // MARK: - BackupCodesResponseDisplay
    
    func displaySkipSaving(responseDisplay: BackupCodesModels.SkipBackupCodeSaving.ResponseDisplay) {
        guard let navigationController = coordinator?.navigationController else { return }
        
        coordinator?.showPopup(on: navigationController,
                               blurred: false,
                               with: responseDisplay.popupViewModel,
                               config: responseDisplay.popupConfig,
                               closeButtonCallback: { [weak self] in
            self?.coordinator?.hidePopup()
        }, callbacks: [ { [weak self] in
            self?.coordinator?.hidePopup()
            
            self?.coordinator?.popToRoot(completion: { [weak self] in
                self?.coordinator?.showToastMessage(model: InfoViewModel(description: .text(L10n.TwoStep.Success.message),
                                                                         dismissType: .auto),
                                                    configuration: Presets.InfoView.warning)
            })
        } ])
    }
    
    // MARK: - Additional Helpers
    
    private func createPDF() {
        guard let section = sections.firstIndex(where: { $0.hashValue == Models.Section.backupCodes.hashValue }),
              let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? WrapperTableViewCell<BackupCodesView> else { return }
        
        let documentDirectory = FileManager.default.temporaryDirectory
        let outputFileURL = documentDirectory.appendingPathComponent("RW_2FA_Backup_Codes_\(UserDefaults.email ?? "").pdf")
        
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: cell.bounds)
        
        do {
            try pdfRenderer.writePDF(to: outputFileURL, withActions: { context in
                context.beginPage()
                cell.layer.render(in: context.cgContext)
                
                let activityViewController = UIActivityViewController(activityItems: [outputFileURL], applicationActivities: nil)
                present(activityViewController, animated: true, completion: nil)
            })
        } catch {
            print("Could not create PDF file: \(error)")
        }
    }
}
