// 
//  BaseTableViewController.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

class BaseTableViewController<C: CoordinatableRoutes,
                              I: Interactor,
                              P: Presenter,
                              DS: BaseDataStore & NSObject>: VIPTableViewController<C, I, P, DS>,
                                                             FetchResponseDisplays {
    override var isRoundedBackgroundEnabled: Bool { return false }
    override var isModalDismissableEnabled: Bool { return true }
    override var dismissText: String { return L10n.Button.skip }
    override var closeImage: UIImage? { return Asset.close.image }
    
    // MARK: - Cleaner Swift setup
    
    lazy var continueButton: FEButton = {
        let view = FEButton()
        return view
    }()
    
    override func setupCloseButton(closeAction: Selector) {
        var closeButton: UIBarButtonItem = .init()
        
        if self.isKind(of: SignInViewController.self) ||
            self.isKind(of: SignUpViewController.self) ||
            self.isKind(of: ForgotPasswordViewController.self) ||
            self.isKind(of: SetPasswordViewController.self) {
            guard navigationItem.leftBarButtonItem?.title != dismissText,
                  navigationItem.rightBarButtonItem?.title != dismissText else { return }
            
            let attributes: [NSAttributedString.Key: Any] = [.font: Fonts.Subtitle.two,
                                                             .foregroundColor: Colors.Text.three,
                                                             .underlineStyle: NSUnderlineStyle.single.rawValue]
            closeButton = UIBarButtonItem(title: dismissText, style: .plain, target: self, action: closeAction)
            closeButton.setTitleTextAttributes(attributes, for: .normal)
            closeButton.setTitleTextAttributes(attributes, for: .highlighted)
        } else {
            guard navigationItem.leftBarButtonItem?.image != closeImage,
                  navigationItem.rightBarButtonItem?.image != closeImage else { return }
            
            closeButton = UIBarButtonItem(image: closeImage,
                                          style: .plain,
                                          target: self,
                                          action: closeAction)
        }
        
        guard navigationItem.rightBarButtonItem == nil else {
            navigationItem.setLeftBarButton(closeButton, animated: false)
            return
        }
        
        closeButton.tintColor = (navigationController as? RootNavigationController)?.navigationBar.tintColor
        navigationItem.setRightBarButton(closeButton, animated: false)
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        view.backgroundColor = Colors.Background.one
        tableView.backgroundColor = .clear
        tableView.bounces = false // TODO: Remove when dataSource issues are resolved.
        
        tableView.registerAccessoryView(WrapperAccessoryView<FELabel>.self)
        tableView.registerAccessoryView(WrapperAccessoryView<FEButton>.self)
        tableView.registerAccessoryView(WrapperAccessoryView<AssetView>.self)
        tableView.register(WrapperTableViewCell<FELabel>.self)
        tableView.register(WrapperTableViewCell<FEButton>.self)
        tableView.register(WrapperTableViewCell<FETextField>.self)
        tableView.register(WrapperTableViewCell<WrapperView<FEInfoView>>.self)
        tableView.register(WrapperTableViewCell<NavigationItemView>.self)
        tableView.register(WrapperTableViewCell<ProfileView>.self)
        tableView.register(WrapperTableViewCell<DoubleHorizontalTextboxView>.self) // TODO: Add validators
        tableView.register(WrapperTableViewCell<FEImageView>.self)
        tableView.register(WrapperTableViewCell<MultipleButtonsView>.self)
        tableView.register(WrapperTableViewCell<ChecklistItemView>.self)
        tableView.register(WrapperTableViewCell<TickboxItemView>.self)
        tableView.register(WrapperTableViewCell<SegmentControl>.self)
        tableView.register(WrapperTableViewCell<ExchangeRateView>.self)
        tableView.register(WrapperTableViewCell<DateView>.self)
        tableView.register(WrapperTableViewCell<TitleValueView>.self)
        tableView.register(WrapperTableViewCell<IconTitleSubtitleToggleView>.self)
        tableView.register(WrapperTableViewCell<TitleButtonView>.self)
        tableView.register(WrapperTableViewCell<PaddedImageView>.self)
        tableView.register(WrapperTableViewCell<OrderView>.self)
        tableView.register(WrapperTableViewCell<CardSelectionView>.self)
        tableView.register(WrapperTableViewCell<UIView>.self)
    }

    override func prepareData() {
        super.prepareData()
        
        (interactor as? (any FetchViewActions))?.getData(viewAction: .init())
    }

    // MARK: ResponseDisplay
    
    func displayData(responseDisplay: FetchModels.Get.ResponseDisplay) {
        sections = responseDisplay.sections
        sectionRows = responseDisplay.sectionRows
        
        dataSource?.defaultRowAnimation = .fade
        dataSource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, _ in
            return self?.tableView(tableView, cellForRowAt: indexPath)
        }
        
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        for section in sections {
            guard let items = sectionRows[section] as? [AnyHashable] else { continue }
            snapshot.appendItems(items, toSection: section)
        }
        
        dataSource?.apply(snapshot, completion: { [weak self] in
            self?.tableView.reloadData()
            self?.tableView.invalidateIntrinsicContentSize()
        })
        
        tableView.backgroundView?.isHidden = !sections.isEmpty
        
        LoadingView.hideIfNeeded()
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let type = (sections[section] as? (any Sectionable))?.header
        return self.tableView(tableView, accessoryViewForType: type, for: section) { [weak self] in
            self?.tableView(tableView, didSelectHeaderIn: section)
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let type = (sections[section] as? (any Sectionable))?.footer
        return self.tableView(tableView, accessoryViewForType: type, for: section) { [weak self] in
            self?.tableView(tableView, didSelectFooterIn: section)
        }
    }

    // MARK: Headers/Footer dequeuing
    func tableView(_ tableView: UITableView, accessoryViewForType type: AccessoryType?, for section: Int, callback: @escaping (() -> Void)) -> UIView? {
        let view: UIView?
        switch type {
        case .plain(let string):
            view = self.tableView(tableView, supplementaryViewWith: string)
            view?.setupCustomMargins(vertical: .small, horizontal: .small)

        case .attributed(let attributedString):
            view = self.tableView(tableView, supplementaryViewWith: attributedString)
            view?.setupCustomMargins(vertical: .small, horizontal: .small)

        case .action(let title):
            view = self.tableView(tableView, supplementaryViewWith: title, for: section, callback: callback)
            view?.setupCustomMargins(vertical: .small, horizontal: .small)
            
        case .advanced(let icon, let title, let description):
            view = self.tableView(tableView, advancedSupplementaryViewWith: icon, title: title, description: description, for: section)

        default:
            view = UIView(frame: .zero)
        }

        return view
    }
    
    private func tableView(_ tableView: UITableView, supplementaryViewWith text: String?) -> UIView? {
        guard let view: WrapperAccessoryView<FELabel> = tableView.dequeueAccessoryView(),
              let text = text
        else { return UIView(frame: .zero) }

        view.setup { view in
            view.setup(with: .text(text))
            view.configure(with: .init(font: Fonts.Body.three, textColor: Colors.Text.one))
        }

        return view
    }

    private func tableView(_ tableView: UITableView, supplementaryViewWith attributedText: NSAttributedString?) -> UIView? {
        guard let view: WrapperAccessoryView<FELabel> = tableView.dequeueAccessoryView(),
              let text = attributedText
        else { return UIView(frame: .zero) }

        view.setup { view in
            // TODO: attributed string support
            view.setup(with: .attributedText(text))
            view.configure(with: .init(font: Fonts.Body.three, textColor: Colors.Text.one))
        }

        return view
    }

    private func tableView(_ tableView: UITableView, supplementaryViewWith buttonTitle: String?, for section: Int, callback: @escaping (() -> Void)) -> UIView? {
        // TODO: custom button (actionButton look alike?)
        guard let view: WrapperAccessoryView<FEButton> = tableView.dequeueAccessoryView(),
              let text = buttonTitle
        else { return UIView(frame: .zero) }

        view.setup { view in
            view.setup(with: .init(title: text))
            view.configure(with: Presets.Button.primary)
            // TODO: add callback to suplementaryViewTapped
        }

        return view
    }
    
    private func tableView(_ tableView: UITableView,
                           advancedSupplementaryViewWith icon: UIImage? = nil,
                           title: String? = nil,
                           description: String? = nil,
                           for section: Int) -> UIView? {
        guard let view: WrapperAccessoryView<AssetView> = tableView.dequeueAccessoryView()
        else { return UIView(frame: .zero) }
        
        view.setup { view in
            view.configure(with: Presets.AssetSelection.header)
        }
        view.setupCustomMargins(vertical: .small, horizontal: .large)

        return view
    }
    
    func tableView(_ tableView: UITableView, supplementaryViewTapped section: Int) {
        // TODO: override in class to handle suplementary button events
    }
    
    // MARK: Custom cells
    
    func tableView(_ tableView: UITableView, emptyCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<UIView> = tableView.dequeueReusableCell(for: indexPath) else { return UITableViewCell() }
        return cell
    }
    
    func tableView(_ tableView: UITableView, coverCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<FEImageView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? ImageViewModel
        else { return UITableViewCell() }
        
        cell.setup { view in
            view.configure(with: Presets.Background.transparent)
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleButtonViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<TitleButtonView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? TitleButtonViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, paddedImageViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<PaddedImageView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? PaddedImageViewModel
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, orderViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<OrderView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? OrderViewModel
        else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: Presets.Order.small)
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, labelCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? LabelViewModel,
              let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(font: Fonts.Body.three, textColor: Colors.Text.two))
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleLabelCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? LabelViewModel,
              let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(font: Fonts.Title.five, textColor: Colors.Text.three))
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, iconTitleSubtitleToggleViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? IconTitleSubtitleToggleViewModel,
              let cell: WrapperTableViewCell<IconTitleSubtitleToggleView> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleValueCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? TitleValueViewModel,
              let cell: WrapperTableViewCell<TitleValueView> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.setupCustomMargins(vertical: .large, horizontal: .huge)
            view.axis = .vertical
            
            view.configure(with: .init(title: .init(font: Fonts.Subtitle.two,
                                                    textColor: Colors.Text.three),
                                       value: .init(font: Fonts.Body.two,
                                                    textColor: Colors.Text.two),
                                       shadow: Presets.Shadow.light,
                                       background: .init(backgroundColor: Colors.Background.one,
                                                         border: .init(borderWidth: 0,
                                                                       cornerRadius: .medium))))
            view.setup(with: model)
        }
        
        cell.contentView.setupCustomMargins(vertical: .extraSmall, horizontal: .large)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, descriptionLabelCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? LabelViewModel,
              let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(font: Fonts.Body.two, textColor: Colors.Text.two))
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, buttonCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? ButtonViewModel,
              let cell: WrapperTableViewCell<FEButton> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: Presets.Button.primary)
            view.setup(with: model)
            view.setupCustomMargins(vertical: .large, horizontal: .large)
            view.snp.makeConstraints { make in
                make.height.equalTo(ViewSizes.Common.largeCommon.rawValue)
            }
            view.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, multipleButtonsCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? MultipleButtonsViewModel,
              let cell: WrapperTableViewCell<MultipleButtonsView> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(background: Presets.Background.transparent,
                                       buttons: [Presets.Button.primary]))
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, textFieldCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? TextFieldModel,
              let cell: WrapperTableViewCell<FETextField> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: Presets.TextField.primary)
            view.setup(with: model)
            view.snp.makeConstraints { make in
                make.bottom.equalToSuperview()                
            }
            
            view.beganEditing = { [weak self] field in
                self?.textFieldDidBegin(for: indexPath, with: field.text)
            }
            
            view.valueChanged = { [weak self] field in
                self?.textFieldDidUpdate(for: indexPath, with: field.text)
            }
            
            view.finishedEditing = { [weak self] field in
                self?.textFieldDidFinish(for: indexPath, with: field.text)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, infoViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = dataSource?.itemIdentifier(for: indexPath) as? InfoViewModel,
              let cell: WrapperTableViewCell<WrapperView<FEInfoView>> = tableView.dequeueReusableCell(for: indexPath)
        else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.setup { view in
                view.setup(with: model)
                view.configure(with: Presets.InfoView.verification)
                view.setupCustomMargins(all: .large)
            }
            view.setupCustomMargins(all: .large)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, navigationCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<NavigationItemView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? NavigationViewModel
        else { return UITableViewCell() }
        
        cell.setup { view in
            view.configure(with: .init(image: .init(tintColor: Colors.Text.three),
                                       label: .init(font: Fonts.Subtitle.one, textColor: Colors.Text.three),
                                       button: Presets.Button.blackIcon))
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, profileViewCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<ProfileView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? ProfileViewModel
        else { return UITableViewCell() }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, checkmarkCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<ChecklistItemView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? ChecklistItemViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            view.setupCustomMargins(horizontal: .large)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, tickboxCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<TickboxItemView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? TickboxItemViewModel else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: model)
            view.setupCustomMargins(horizontal: .large)
        }
        
        return cell
    }
    
    // MARK: UserInteractions
    
    /// Override in subclass
    func textFieldDidBegin(for indexPath: IndexPath, with text: String?) {
        tableView.invalidateTableViewIntrinsicContentSize()
    }
    
    /// Override in subclass
    func textFieldDidFinish(for indexPath: IndexPath, with text: String?) {
        tableView.invalidateTableViewIntrinsicContentSize()
    }
    
    /// Override in subclass
    func textFieldDidUpdate(for indexPath: IndexPath, with text: String?) {
        tableView.invalidateTableViewIntrinsicContentSize()
    }
    
    /// Override in subclass
    @objc func buttonTapped() {
        view.endEditing(true)
    }
}
