// 
//  TransferFundsHorizontalView.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 22.9.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct TransferFundsHorizontalViewConfiguration: Configurable {
    var shadow: ShadowConfiguration? = Presets.Shadow.light
    var background: BackgroundConfiguration? = .init(backgroundColor: Colors.Background.one,
                                                     tintColor: Colors.Text.one,
                                                     border: Presets.Border.mediumPlain)
}

struct TransferFundsHorizontalViewModel: ViewModel {
    var fromTransferView: TransferFundsViewModel? = .init()
    var toTransferView: TransferFundsViewModel? = .init()
}

class TransferFundsHorizontalView: FEView<TransferFundsHorizontalViewConfiguration, TransferFundsHorizontalViewModel> {
    
    private lazy var contentStack: UIStackView = {
        let view = UIStackView()
        view.spacing = Margins.medium.rawValue
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var fromTransferView: TransferFundsView = {
        let view = TransferFundsView()
        return view
    }()
    
    private lazy var transferFundsButton: FEButton = {
        let view = FEButton()
        view.setImage(Asset.transferFunds.image, for: .normal)
        view.addTarget(self, action: #selector(transferFundsButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var toTransferView: TransferFundsView = {
        let view = TransferFundsView()
        return view
    }()
    
    var didTapTransferFunds: (() -> Void)?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
        }
        
        contentStack.addArrangedSubview(fromTransferView)
        contentStack.addArrangedSubview(toTransferView)
        
        content.addSubview(transferFundsButton)
        transferFundsButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.width.equalTo(Margins.extraExtraHuge.rawValue)
        }
    }
    
    override func configure(with config: TransferFundsHorizontalViewConfiguration?) {
        super.configure(with: config)
        
        backgroundView = fromTransferView
        shadowView = fromTransferView
        
        configure(background: config?.background)
        configure(shadow: config?.shadow)
        
        guard let background = config?.background,
        let shadow = config?.shadow else { return }
        
        toTransferView.setBackground(with: background)
        toTransferView.layer.setShadow(with: shadow)
    }
    
    override func setup(with viewModel: TransferFundsHorizontalViewModel?) {
        super.setup(with: viewModel)
        
        fromTransferView.setup(with: viewModel?.fromTransferView)
        toTransferView.setup(with: viewModel?.toTransferView)
    }
    
    @objc private func transferFundsButtonTapped(_ sender: UIButton?) {
        didTapTransferFunds?()
    }
}
