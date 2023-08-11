// 
//  MultipleButtonsView.swift
//  breadwallet
//
//  Created by Rok on 03/06/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct MultipleButtonsConfiguration: Configurable {
    var background: BackgroundConfiguration?
    var buttons: [ButtonConfiguration] = []
    var isRightAligned = false
    var axis: NSLayoutConstraint.Axis = .vertical
}

struct MultipleButtonsViewModel: ViewModel {
    var buttons: [ButtonViewModel] = []
}

class MultipleButtonsView: FEView<MultipleButtonsConfiguration, MultipleButtonsViewModel> {
    var callbacks: [(() -> Void)] = []
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        return view
    }()
    
    private var buttons: [FEButton] = []
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.setupClearMargins()
        
        content.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func configure(with config: MultipleButtonsConfiguration?) {
        super.configure(with: config)
        
        configure(background: config?.background)
    }
    
    override func setup(with viewModel: MultipleButtonsViewModel?) {
        super.setup(with: viewModel)
        
        setupButtons()
    }
    
    private func setupButtons() {
        guard let viewModel = viewModel, let config = config else { return }
        
        buttons = []
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, model) in viewModel.buttons.enumerated() {
            let button = FEButton()
            
            var buttonConfig: ButtonConfiguration?
            if index < config.buttons.count {
                buttonConfig = config.buttons[index]
            } else {
                buttonConfig = config.buttons.last
            }
            
            button.configure(with: buttonConfig)
            button.setup(with: model)
            
            buttons.append(button)
            stack.addArrangedSubview(button)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        
        stack.axis = config.axis
        stack.distribution = .fill
        stack.spacing = config.axis == .horizontal ? Margins.huge.rawValue : Margins.small.rawValue
        
        if config.axis == .vertical {
            stack.alignment = .leading
        } else {
            let spacer = UIView()
            stack.insertArrangedSubview(spacer, at: config.isRightAligned ? 0 : stack.arrangedSubviews.endIndex)
            spacer.snp.makeConstraints { make in
                make.width.greaterThanOrEqualToSuperview().priority(.low)
            }
        }
        
        stack.layoutIfNeeded()
    }
    
    // MARK: - User interaction
    @objc private  func buttonTapped(_ sender: UIButton) {
        guard let index = buttons.firstIndex(where: { $0 == sender }) else { return }
        
        if index >= callbacks.count {
            callbacks.last?()
        } else {
            callbacks[index]()
        }
    }
}
