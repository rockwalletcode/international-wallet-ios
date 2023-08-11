// 
//  TitleButtonView.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 18/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct TitleButtonConfiguration: Configurable {
    var background: BackgroundConfiguration = .init(backgroundColor: LightColors.Background.two, tintColor: LightColors.Background.two,
                                                    border: Presets.Border.commonPlain)
    var title: LabelConfiguration? = .init(font: Fonts.Body.two, textColor: LightColors.Text.one)
    var button: ButtonConfiguration = Presets.Button.noBorders
}

struct TitleButtonViewModel: ViewModel {
    var title: LabelViewModel?
    var button: ButtonViewModel?
}

class TitleButtonView: FEView<TitleButtonConfiguration, TitleButtonViewModel> {
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var button: FEButton = {
        let view = FEButton()
        view.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    var didTapButton: (() -> Void)?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Margins.extraLarge.rawValue)
        }
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(button)
    }
    
    override func configure(with config: TitleButtonConfiguration?) {
        super.configure(with: config)
        
        configure(background: config?.background)
        titleLabel.configure(with: config?.title)
        button.configure(with: config?.button)
    }
    
    override func setup(with viewModel: TitleButtonViewModel?) {
        super.setup(with: viewModel)
        
        titleLabel.setup(with: viewModel?.title)
        button.setup(with: viewModel?.button)
    }
    
    // MARK: - User interaction
    
    @objc private func buttonTapped(_ sender: Any?) {
        didTapButton?()
    }
}
