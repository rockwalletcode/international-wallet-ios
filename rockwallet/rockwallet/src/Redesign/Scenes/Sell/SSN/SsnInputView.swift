// 
//  SsnInputView.swift
//  breadwallet
//
//  Created by Dino Gacevic on 24/07/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct SsnInputConfiguration: Configurable {
    var messageConfig: LabelConfiguration? = .init(font: Fonts.Body.three, textColor: Colors.Text.two)
    var textFieldConfig: TextFieldConfiguration = Presets.TextField.primary
    var buttonConfig: ButtonConfiguration = Presets.Button.primary
    var shadow: ShadowConfiguration? = Presets.Shadow.light
    var background: BackgroundConfiguration? = .init(backgroundColor: Colors.Background.one,
                                                     tintColor: Colors.Text.one,
                                                     border: Presets.Border.mediumPlain)
}

struct SsnInputViewModel: ViewModel {
    var messageViewModel: LabelViewModel = .text(L10n.Sell.SsnInput.disclaimer)
    var textFieldViewModel: TextFieldModel = .init(placeholder: L10n.Account.socialSecurityNumber)
    var buttonViewModel: ButtonViewModel = .init(title: L10n.Button.confirm, enabled: false)
}

class SsnInputView: FEView<SsnInputConfiguration, SsnInputViewModel> {
    var valueChanged: ((String?) -> Void)?
    var confirmTapped: (() -> Void)?
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Margins.large.rawValue
        return stack
    }()
    
    private lazy var messageLabel: FELabel = {
        let label = FELabel()
        return label
    }()
    
    private lazy var textField: FETextField = {
        let textField = FETextField()
        return textField
    }()
    
    private lazy var button: FEButton = {
        let button = FEButton()
        button.tap = { [weak self] in
            self?.textField.endEditing(true)
            self?.confirmTapped?()
        }
        return button
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.setupCustomMargins(all: .large)
        
        content.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
        }
        
        mainStack.addArrangedSubview(messageLabel)
        mainStack.addArrangedSubview(textField)
        mainStack.addArrangedSubview(button)
        button.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.Common.largeCommon.rawValue)
        }
    }
    
    override func configure(with config: SsnInputConfiguration?) {
        messageLabel.configure(with: config?.messageConfig)
        textField.configure(with: config?.textFieldConfig)
        button.configure(with: config?.buttonConfig)
        
        configure(background: config?.background)
        configure(shadow: config?.shadow)
    }
    
    override func setup(with viewModel: SsnInputViewModel?) {
        messageLabel.setup(with: viewModel?.messageViewModel)
        textField.setup(with: viewModel?.textFieldViewModel)
        button.setup(with: viewModel?.buttonViewModel)
        
        textField.valueChanged = { [weak self] in
            self?.valueChanged?($0.text)
        }
    }
}
