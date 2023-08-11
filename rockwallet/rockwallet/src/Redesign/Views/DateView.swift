// 
//  DateView.swift
//  breadwallet
//
//  Created by Rok on 30/05/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct DateConfiguration: Configurable {
}

struct DateViewModel: ViewModel {
    var date: Date?
    var title: LabelViewModel?
    var month: TextFieldModel?
    var day: TextFieldModel?
    var year: TextFieldModel?
}

class DateView: FEView<DateConfiguration, DateViewModel>, StateDisplayable {
    var didPresentPicker: (() -> Void)?
    var displayState: DisplayState = .normal
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.extraSmall.rawValue
        return view
    }()
    
    private lazy var dateStack: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var monthTextfield: FETextField = {
        let view = FETextField()
        return view
    }()
    
    private lazy var dayTextField: FETextField = {
        let view = FETextField()
        return view
    }()
    
    private lazy var yearTextField: FETextField = {
        let view = FETextField()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
        }
        
        stack.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.extraSmall.rawValue)
        }
        
        stack.addArrangedSubview(dateStack)
        dateStack.addArrangedSubview(monthTextfield)
        dateStack.addArrangedSubview(dayTextField)
        dateStack.addArrangedSubview(yearTextField)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(triggerPresentPicker)))
    }
    
    override func configure(with config: DateConfiguration?) {
        super.configure(with: config)
        
        titleLabel.configure(with: .init(font: Fonts.Body.two, textColor: LightColors.Text.two))
        
        monthTextfield.configure(with: Presets.TextField.primary)
        dayTextField.configure(with: Presets.TextField.primary)
        yearTextField.configure(with: Presets.TextField.primary)
    }
    
    override func setup(with viewModel: DateViewModel?) {
        super.setup(with: viewModel)

        titleLabel.setup(with: viewModel?.title)
        
        var month = viewModel?.month
        month?.isUserInteractionEnabled = false
        
        var day = viewModel?.day
        day?.isUserInteractionEnabled = false
        
        var year = viewModel?.year
        year?.isUserInteractionEnabled = false
        
        monthTextfield.setup(with: month)
        dayTextField.setup(with: day)
        yearTextField.setup(with: year)
        
        animateTo(state: .normal)
    }
    
    @objc private func triggerPresentPicker() {
        didPresentPicker?()
        
        animateTo(state: .selected)
    }
    
    func animateTo(state: DisplayState, withAnimation: Bool = true) {
        let background: BackgroundConfiguration?
        
        switch state {
        case .normal:
            background = Presets.TextField.primary.backgroundConfiguration
            
        default:
            background = Presets.TextField.primary.selectedBackgroundConfiguration
        }
        
        displayState = state
        
        monthTextfield.configure(background: background)
        dayTextField.configure(background: background)
        yearTextField.configure(background: background)
    }
}
