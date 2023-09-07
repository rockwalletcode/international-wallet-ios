//
//  VIPTableViewController.swift
//  
//
//  Created by Rok Cresnik on 01/12/2021.
//

import UIKit

class VIPTableViewController<C: CoordinatableRoutes,
                             I: Interactor,
                             P: Presenter,
                             DS: BaseDataStore & NSObject>: VIPViewController<C, I, P, DS>,
                                                            UITableViewDelegate,
                                                            UITableViewDataSource {
    typealias DataSource = UITableViewDiffableDataSource<AnyHashable, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<AnyHashable, AnyHashable>
    
    var sections: [AnyHashable] = []
    var sectionRows: [AnyHashable: [Any]] = [:]
    
    var dataSource: DataSource?
    
    // MARK: LazyUI
    
    lazy var tableView: ContentSizedTableView = {
        var tableView = ContentSizedTableView(frame: .zero, style: .grouped)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // This prevents the top offset on tableViews
        let zeroView = UIView(frame: .init(origin: .zero, size: .init(width: 0, height: CGFloat.leastNonzeroMagnitude)))
        tableView.tableHeaderView = zeroView
        tableView.tableFooterView = zeroView
        
        tableView.estimatedSectionHeaderHeight = CGFloat.leastNormalMagnitude
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.estimatedSectionFooterHeight = CGFloat.leastNormalMagnitude
        tableView.sectionFooterHeight = UITableView.automaticDimension
        
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    lazy var contentShadowView: UIView = {
        var contentShadowView = UIView()
        contentShadowView.backgroundColor = Colors.Background.one
        contentShadowView.isUserInteractionEnabled = false
        contentShadowView.clipsToBounds = true
        contentShadowView.layer.cornerRadius = CornerRadius.common.rawValue
        contentShadowView.layer.shadowRadius = contentShadowView.layer.cornerRadius * 3
        contentShadowView.layer.shadowOpacity = 0.1
        contentShadowView.layer.shadowOffset = CGSize(width: 0, height: 8)
        contentShadowView.layer.shadowColor = UIColor(red: 0.043, green: 0.082, blue: 0.165, alpha: 1.0).cgColor
        contentShadowView.layer.masksToBounds = false
        contentShadowView.layer.shouldRasterize = true
        contentShadowView.layer.rasterizationScale = UIScreen.main.scale
        return contentShadowView
    }()
    
    // MARK: Lifecycle
    override func setupSubviews() {
        super.setupSubviews()
        
        view.backgroundColor = Colors.Background.one
        
        view.addSubview(tableView)
        tableView.addSubview(leftAlignedTitleLabel)
        
        view.addSubview(contentShadowView)
        
        tableView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(self.isRoundedBackgroundEnabled ? Margins.extraHuge.rawValue : 0)
        }
        
        leftAlignedTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.lessThanOrEqualTo(view.snp.width)
            make.leading.equalToSuperview().inset(isRoundedBackgroundEnabled ? -Margins.large.rawValue : Margins.large.rawValue)
        }
        
        view.addSubview(verticalButtons)
        verticalButtons.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            let inset: Margins = UIDevice.current.hasNotch ? .zero : .large // Added to fix button offset for iPhone SE
            make.bottom.equalToSuperview().inset(inset.rawValue)
        }
        
        tableView.heightUpdated = { height in
            self.contentShadowView.snp.remakeConstraints { make in
                make.leading.equalToSuperview().inset(Margins.large.rawValue)
                make.trailing.equalToSuperview().inset(Margins.large.rawValue)
                make.top.equalTo(self.tableView.snp.top).inset(self.tableView.contentInset.top)
                make.height.equalTo(height + Margins.large.rawValue)
            }
        }
        
        contentShadowView.layer.zPosition = tableView.layer.zPosition - 1
        contentShadowView.alpha = isRoundedBackgroundEnabled ? 1 : 0
        
        tableView.contentInset.top = isRoundedBackgroundEnabled ? Margins.small.rawValue : 0
        
        tableView.clipsToBounds = !isRoundedBackgroundEnabled
        tableView.layer.masksToBounds = !isRoundedBackgroundEnabled
        
        tableView.verticalScrollIndicatorInsets.right = isRoundedBackgroundEnabled ? -Margins.huge.rawValue : 0
        
        setupVerticalButtons()
    }
    
    func setupVerticalButtons() {}
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.contentInset.top = isRoundedBackgroundEnabled ? Margins.small.rawValue + leftAlignedTitleLabel.frame.height : leftAlignedTitleLabel.frame.height
        
        leftAlignedTitleLabel.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(-tableView.contentInset.top)
        }
        
        contentShadowView.snp.updateConstraints { make in
            make.top.equalTo(self.tableView.snp.top).inset(tableView.contentInset.top)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentShadowView.transform = .init(translationX: 0, y: -scrollView.contentOffset.y - tableView.contentInset.top)
    }
    
    // MARK: ResponseDisplay
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSections(in: tableView) ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.tableView(tableView, numberOfRowsInSection: section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return .init(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return .init(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    func tableView(_ tableView: UITableView, didSelectHeaderIn section: Int) {}
    
    func tableView(_ tableView: UITableView, didSelectFooterIn section: Int) {}
}
