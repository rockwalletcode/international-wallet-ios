//
//  MenuViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-03-30.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController, Subscriber {
    init(items: [MenuItem], title: String, faqButton: UIButton? = nil) {
        self.items = items
        self.faqButton = faqButton
        super.init(style: .plain)
        self.title = title
    }

    deinit {
        Store.unsubscribe(self)
    }
    
    private let items: [MenuItem]
    private var visibleItems: [MenuItem] {
        return items.filter { $0.shouldShow() }
    }
    private let faqButton: UIButton?
    
    func reloadMenu() {
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(WrapperTableViewCell<MenuCell>.self)
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = LightColors.Outline.one
        tableView.backgroundColor = LightColors.Background.one
        tableView.backgroundView?.backgroundColor = LightColors.Background.one
        
        if let button = faqButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        }
        
        Store.lazySubscribe(self, selector: { $0.defaultCurrencyCode != $1.defaultCurrencyCode }, callback: { [weak self] _ in
            guard let self = self else { return }
            self.reloadMenu()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<MenuCell> = tableView.dequeueReusableCell(for: indexPath) else { return UITableViewCell() }
        cell.shouldHighlight = true
        cell.setup { view in
            view.set(item: visibleItems[indexPath.row])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        visibleItems[indexPath.row].callback()
        tableView.deselectRow(at: indexPath, animated: true)
        
        GoogleAnalytics.logEvent(GoogleAnalytics.Menu(settingsOption: visibleItems[indexPath.row].title))
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = items[indexPath.row]
        
        if let subTitle = item.subTitle, !subTitle.isEmpty {
            return ViewSizes.Common.hugeCommon.rawValue
        } else {
            return ViewSizes.Common.largeCommon.rawValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
