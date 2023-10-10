// 
//  TransferFundsView.swift
//  rockwallet
//
//  Created by Dijana Angelovska on 22.9.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct TransferFundsConfiguration: Configurable {
    var shadow: ShadowConfiguration? = Presets.Shadow.light
    var background: BackgroundConfiguration? = .init(backgroundColor: Colors.Background.one,
                                                     tintColor: Colors.Text.one,
                                                     border: Presets.Border.mediumPlain)
}

struct TransferFundsViewModel: ViewModel {
    var headerTitle: String?
    var icon: ImageViewModel?
    var title: String?
    var subTitle: String?
}

class TransferFundsView: FEView<TransferFundsConfiguration, TransferFundsViewModel> {
    
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.medium.rawValue
        return view
    }()
    
    private lazy var headerTitleLabel: FELabel = {
        let view = FELabel()
        view.font = Fonts.Body.two
        view.textColor = Colors.Text.one
        view.textAlignment = .left
        return view
    }()
    
    private lazy var iconView: FEImageView = {
        let view = FEImageView()
        view.setup(with: .image(Asset.chevronDown.image))
        view.setupCustomMargins(all: .extraSmall)
        view.tintColor = Colors.Text.three
        view.contentMode = .left
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        view.font = Fonts.Subtitle.one
        view.textColor = Colors.Text.three
        view.textAlignment = .left
        return view
    }()
    
    private lazy var subTitleLabel: FELabel = {
        let view = FELabel()
        view.font = Fonts.Body.one
        view.textColor = Colors.Text.three
        view.textAlignment = .left
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(mainStack)
        content.setupCustomMargins(all: .extraLarge)
        mainStack.snp.makeConstraints { make in
            make.topMargin.leadingMargin.trailingMargin.equalTo(content)
            make.bottom.equalToSuperview().inset(Margins.extraLarge.rawValue).priority(.low)
        }
        
        mainStack.addArrangedSubview(headerTitleLabel)
        mainStack.addArrangedSubview(iconView)
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(subTitleLabel)
    }
    
    override func configure(with config: TransferFundsConfiguration?) {
        super.configure(with: config)
        
        backgroundView = mainStack
        shadowView = mainStack
        
        configure(background: config?.background)
        configure(shadow: config?.shadow)
    }
    
    override func setup(with viewModel: TransferFundsViewModel?) {
        super.setup(with: viewModel)
        
        headerTitleLabel.setup(with: .text(viewModel?.headerTitle))
        headerTitleLabel.isHidden = viewModel?.headerTitle == nil
        
        iconView.setup(with: viewModel?.icon)
        iconView.isHidden = viewModel?.icon == nil
        
        titleLabel.setup(with: .text(viewModel?.title))
        titleLabel.isHidden = viewModel?.title == nil
        
        subTitleLabel.setup(with: .text(viewModel?.subTitle))
        subTitleLabel.isHidden = viewModel?.subTitle == nil
    }
}
