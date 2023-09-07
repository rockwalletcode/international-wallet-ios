//
//  FeeSelector.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-07-20.
//  Copyright © 2017-2019 Breadwinner AG. All rights reserved.
//

import UIKit

//TODO:CRYPTO_V2 - these should come from BlockchainDB eventually
enum FeeLevel: Int {
    case economy
    case regular
    case priority
    
    //Time in millis
    func preferredTime(forCurrency currency: Currency) -> Int {
        
        if currency.uid == Currencies.shared.btc?.uid {
            switch self {
            case .economy:
                return Int(Constant.secondsInMinute) * 60 * 7 * 1000 //7 hrs
            case .regular:
                return Int(Constant.secondsInMinute) * 30 * 1000 //30 mins
            case .priority:
                return Int(Constant.secondsInMinute) * 10 * 1000 //10 mins
            }
        }
        
        if currency.isEthereumCompatible {
            switch self {
            case .economy:
                return Int(Constant.secondsInMinute) * 60 * 1000 // 60 min
            case .regular:
                return Int(Constant.secondsInMinute) * 20 * 1000 // 20 min
            case .priority:
                return Int(Constant.secondsInMinute) * 1 * 1000 // 1 min
            }
        }
        
        if currency.uid == "tezos-mainnet:__native__" {
            return 60000
        }
        
        return Int(Constant.secondsInMinute) * 3 * 1000 // 3 mins
    }
}

class FeeSelector: UIView {
    init(currency: Currency) {
        self.currency = currency
        super.init(frame: .zero)
        setupViews()
    }
    
    private let defaultPriority: Int = 2
    var didUpdateFee: ((FeeLevel) -> Void)?

    private let currency: Currency
    private let topBorder = UIView(color: Colors.Outline.one)
    private let header = UILabel(font: Fonts.Subtitle.two, color: Colors.Text.two)
    private let footer = UILabel(font: Fonts.Body.three, color: Colors.Text.two)
    private let warning = UILabel.wrapping(font: Fonts.Body.three, color: Colors.Error.one)
    private let control = SegmentControl()
    
    private func setupViews() {
        addSubview(topBorder)
        addSubview(control)
        addSubview(header)
        addSubview(footer)
        addSubview(warning)

        topBorder.constrainTopCorners(height: 1.0)
        header.constrain([
            header.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Margins.large.rawValue),
            header.topAnchor.constraint(equalTo: topBorder.bottomAnchor, constant: Margins.small.rawValue)])
        footer.constrain([
            footer.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            footer.topAnchor.constraint(equalTo: control.bottomAnchor, constant: Margins.small.rawValue)])

        warning.constrain([
            warning.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            warning.topAnchor.constraint(equalTo: footer.bottomAnchor, constant: Margins.small.rawValue),
            warning.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Margins.large.rawValue),
            warning.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Margins.small.rawValue)])
        header.text = L10n.FeeSelector.title
        footer.text = currency.feeText(forIndex: 1)
        control.constrain([
            control.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            control.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 4.0),
            control.widthAnchor.constraint(equalTo: widthAnchor, constant: -Margins.extraHuge.rawValue)])
        control.configure(with: .init())
        control.didChangeValue = { [weak self] value in
            guard let self = self else { return }
            
            let fee: FeeLevel
            let subheader: String
            let warning: String
            
            switch value {
            case 1:
                fee = .regular
                subheader = self.currency.feeText(forIndex: 1)
                warning = ""
                
            case 2:
                fee = .priority
                subheader = self.currency.feeText(forIndex: 2)
                warning = ""
                
            default:
                fee = .economy
                subheader = self.currency.feeText(forIndex: 0)
                warning = L10n.FeeSelector.economyWarning
            }
            
            self.didUpdateFee?(fee)
            self.footer.text = subheader
            self.warning.text = warning
        }

        clipsToBounds = true
        setupSegmentControl()
    }
    
    private func setupSegmentControl() {
        control.configure(with: .init(font: Fonts.Body.two,
                                      normal: .init(backgroundColor: Colors.Background.two, tintColor: Colors.Text.two, border: nil),
                                      selected: .init(backgroundColor: Colors.Text.two, tintColor: Colors.Contrast.two, border: nil),
                                      inset: .init(x: Margins.small.rawValue, y: Margins.small.rawValue)))
        control.setup(with: .init(selectedIndex: defaultPriority,
                                  segments: [.init(image: nil, title: L10n.FeeSelector.economy),
                                             .init(image: nil, title: L10n.FeeSelector.regular),
                                             .init(image: nil, title: L10n.FeeSelector.priority)]))
        
        control.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.medium.rawValue)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
