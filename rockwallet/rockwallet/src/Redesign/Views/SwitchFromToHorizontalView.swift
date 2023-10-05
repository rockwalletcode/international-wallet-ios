// 
//  SwitchFromToHorizontalView.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 22.9.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct SwitchFromToHorizontalViewConfiguration: Configurable {
    var shadow: ShadowConfiguration? = Presets.Shadow.light
    var background: BackgroundConfiguration? = .init(backgroundColor: Colors.Background.one,
                                                     tintColor: Colors.Text.one,
                                                     border: Presets.Border.mediumPlain)
}

struct SwitchFromToHorizontalViewModel: ViewModel {
    var fromTransferView: TransferFundsViewModel? = .init()
    var toTransferView: TransferFundsViewModel? = .init()
}

class SwitchFromToHorizontalView: FEView<SwitchFromToHorizontalViewConfiguration, SwitchFromToHorizontalViewModel> {
    
    private lazy var contentStack: UIStackView = {
        let view = UIStackView()
        view.spacing = Margins.medium.rawValue
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var fromView: TransferFundsView = {
        let view = TransferFundsView()
        return view
    }()
    
    private lazy var switchPlacesButton: FEButton = {
        let view = FEButton()
        view.setImage(Asset.transferFunds.image, for: .normal)
        view.addTarget(self, action: #selector(switchPlacesButtonTapped), for: .touchUpInside)
        return view
    }()
    
    private lazy var toView: TransferFundsView = {
        let view = TransferFundsView()
        return view
    }()
    
    var didTapSwitchPlacesButton: (() -> Void)?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
        }
        
        contentStack.addArrangedSubview(fromView)
        contentStack.addArrangedSubview(toView)
        
        content.addSubview(switchPlacesButton)
        switchPlacesButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.width.equalTo(Margins.extraExtraHuge.rawValue)
        }
    }
    
    override func configure(with config: SwitchFromToHorizontalViewConfiguration?) {
        super.configure(with: config)
        
        backgroundView = fromView
        shadowView = fromView
        
        configure(background: config?.background)
        configure(shadow: config?.shadow)
        
        guard let background = config?.background,
        let shadow = config?.shadow else { return }
        
        toView.setBackground(with: background)
        toView.layer.setShadow(with: shadow)
    }
    
    override func setup(with viewModel: SwitchFromToHorizontalViewModel?) {
        super.setup(with: viewModel)
        
        fromView.setup(with: viewModel?.fromTransferView)
        toView.setup(with: viewModel?.toTransferView)
    }
    
    @objc private func switchPlacesButtonTapped(_ sender: UIButton?) {
        didTapSwitchPlacesButton?()
    }
}
