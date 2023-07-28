//
//  AssetDetailsFooterView.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-16.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import Combine
import UIKit

enum AssetDetailsFooterAction {
    case send, receive, buySell, swap
}

class AssetDetailsFooterView: UIView, Subscriber {
    
    static let height: CGFloat = 120.0
    
    private let actionSubject = PassthroughSubject<AssetDetailsFooterAction, Never>()
    var actionPublisher: AnyPublisher<AssetDetailsFooterAction, Never> {
        actionSubject.eraseToAnyPublisher()
    }
    
    private let currency: Currency
    
    init(currency: Currency) {
        self.currency = currency
        super.init(frame: .zero)
        setup()
    }

    private func toRadian(value: Int) -> CGFloat {
        return CGFloat(Double(value) / 180.0 * .pi)
    }
    
    private func setup() {
        let separator = UIView(color: LightColors.Outline.one)
        addSubview(separator)
        backgroundColor = LightColors.Background.one
        separator.constrainTopCorners(height: 0.5)
        layer.cornerRadius = CornerRadius.large.rawValue
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        setupToolbarButtons()
    }
    
    private var isSupported: Bool {
        return SupportedCurrenciesManager.shared.isSupported(currency: currency.code)
    }
    
    private func setupToolbarButtons() {
        let canSend: Bool = true//(currency.state?.balance?.fiatValue ?? 0) > 0

        let bottomButtonModels: [BottomBarItemViewModel] = [
            .init(title: L10n.Button.send, image: Asset.send.image, enabled: canSend, callback: { self.send() }),
            .init(title: L10n.Button.receive, image: Asset.receive.image, callback: { self.receive() }),
            .init(title: L10n.Drawer.title, image: Asset.buySell.image, enabled: isSupported, callback: { self.buy() }),
            .init(title: L10n.HomeScreen.trade, image: Asset.trade.image, enabled: isSupported, callback: { self.swap() })
        ]
        
        let buttons = bottomButtonModels.compactMap { model -> BottomBarItem in
            let button = BottomBarItem()
            button.setup(with: model)
            return button
        }
        
        let buttonsView = UIStackView(arrangedSubviews: buttons)
        buttonsView.spacing = Margins.small.rawValue
        buttonsView.distribution = .equalSpacing
        
        let bottomMargin: Margins = UIDevice.current.hasNotch ? .extraHuge : .medium
        
        addSubview(buttonsView)
        buttonsView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Margins.medium.rawValue)
            make.height.equalTo(BottomBarItem.defaultheight)
            make.leading.equalToSuperview().offset(Margins.huge.rawValue)
            make.trailing.equalToSuperview().offset(-Margins.huge.rawValue)
            make.bottom.equalToSuperview().inset(bottomMargin.rawValue)
        }
    }

    @objc private func send() { actionSubject.send(.send) }
    @objc private func receive() { actionSubject.send(.receive) }
    @objc private func buy() { actionSubject.send(.buySell) }
    @objc private func swap() { actionSubject.send(.swap) }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
}
