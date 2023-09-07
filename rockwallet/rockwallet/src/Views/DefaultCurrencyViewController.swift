//
//  DefaultCurrencyViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-04-06.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

class DefaultCurrencyViewController: UITableViewController, Subscriber {
    private let fiatCurrencies = CurrencyFileManager.getCurrencyMetaDataFromCache(type: .fiatCurrencies)
    
    private var selectedCurrencyCode = Store.state.defaultCurrencyCode {
        didSet {
            let filtered = fiatCurrencies.enumerated().filter({ $0.1.code == selectedCurrencyCode || $0.1.code == oldValue })
            let paths: [IndexPath] = filtered.map({ IndexPath(row: $0.0, section: 0 )})
            
            tableView.beginUpdates()
            tableView.reloadRows(at: paths, with: .none)
            tableView.endUpdates()
            
            Store.perform(action: DefaultCurrency.SetDefault(selectedCurrencyCode))
        }
    }
    
    deinit {
        Store.unsubscribe(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(WrapperTableViewCell<UITableViewCell>.self)
        tableView.rowHeight = ViewSizes.large.rawValue
        tableView.estimatedRowHeight = ViewSizes.large.rawValue
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = Colors.Background.one
        
        title = L10n.Settings.currency
        
        let faqButton = UIButton.buildHelpBarButton(articleId: ArticleIds.displayCurrency)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: faqButton)]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Scroll to the selected display currency.
        if let index = fiatCurrencies.firstIndex(where: { return $0.code.lowercased() == selectedCurrencyCode.lowercased() }) {
            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fiatCurrencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<UITableViewCell> = tableView.dequeueReusableCell(for: indexPath) else { return UITableViewCell() }
        
        let currency = fiatCurrencies[indexPath.row]
        
        cell.textLabel?.text = "\(currency.code) (\(Rate.symbolMap[currency.code] ?? currency.code)) - \(currency.name)"
        cell.textLabel?.font = Fonts.Subtitle.two
        cell.textLabel?.textColor = Colors.Text.three
        
        cell.contentView.backgroundColor = Colors.Background.one
        cell.backgroundColor = Colors.Background.one
        cell.accessoryView = nil
        
        if currency.code == selectedCurrencyCode {
            let check = UIImageView(image: Asset.check2Circled.image.withRenderingMode(.alwaysTemplate))
            check.tintColor = Colors.primary
            cell.accessoryView = check
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = fiatCurrencies[indexPath.row]
        selectedCurrencyCode = currency.code
    }
}
