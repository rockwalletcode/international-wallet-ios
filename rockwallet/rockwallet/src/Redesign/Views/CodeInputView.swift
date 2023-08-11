// 
//  CodeInputView.swift
//  breadwallet
//
//  Created by Rok on 02/06/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct CodeInputConfiguration: Configurable {
    var normal: BackgroundConfiguration? = Presets.Background.TextField.normal
    var selected: BackgroundConfiguration? = Presets.Background.TextField.selected
    var error: BackgroundConfiguration? = Presets.Background.TextField.error
    var input: TextFieldConfiguration = .init(textConfiguration: .init(font: Fonts.Subtitle.one,
                                                                       textColor: LightColors.Text.one,
                                                                       textAlignment: .center,
                                                                       numberOfLines: 1))
}

struct CodeInputViewModel: ViewModel {
}

class CodeInputView: FEView<CodeInputConfiguration, CodeInputViewModel>, StateDisplayable, UITextFieldDelegate {
    static var numberOfFields: Int { return 6 }
    
    var valueChanged: ((String?) -> Void)?
    
    var displayState: DisplayState = .normal
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var inputStack: UIStackView = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = Margins.small.rawValue
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var hiddenTextField: UITextField = {
        let view = UITextField()
        view.keyboardType = .numberPad
        view.tintColor = .clear
        view.textColor = .clear
        view.backgroundColor = .clear
        view.borderStyle = .none
        view.font = UIFont.systemFont(ofSize: 0)
        view.delegate = self
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(hiddenTextField)
        hiddenTextField.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        content.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        stack.addArrangedSubview(inputStack)
        inputStack.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        for _ in (0..<CodeInputView.numberOfFields) {
            let field = FETextField()
            field.setup(with: .init())
            inputStack.addArrangedSubview(field)
        }
        
        hiddenTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func configure(background: BackgroundConfiguration? = nil) {
        guard let background = background else { return }
        
        inputStack.arrangedSubviews.forEach { textField in
            textField.setBackground(with: background)
        }
    }
    
    override func configure(with config: CodeInputConfiguration?) {
        super.configure(with: config)
        
        configure(background: config?.normal)
        
        inputStack.arrangedSubviews.forEach { field in
            (field as? FETextField)?.configure(with: config?.input)
        }
        
        hiddenTextField.becomeFirstResponder()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        valueChanged?(textField.text)
        
        guard let text = textField.text,
              text.count <= CodeInputView.numberOfFields else {
            if let text = textField.text?.prefix(CodeInputView.numberOfFields) {
                textField.text = String(text)
            }
            return
        }
        
        let textArray = Array(text)
        for (index, field) in inputStack.arrangedSubviews.enumerated() {
            var value = ""
            if textArray.count > index {
                value = String(textArray[index])
            }
            
            (field as? FETextField)?.setup(with: .init(value: value, isUserInteractionEnabled: false))
        }
        
        animateTo(state: text.isEmpty ? .normal : .selected)
    }
    
    func animateTo(state: DisplayState, withAnimation: Bool = true) {
        guard let config = config else { return }
        
        let background: BackgroundConfiguration?
        switch state {
        case .selected:
            background = config.selected
            
        case .error:
            background = config.error
            
        default:
            background = config.normal
        }
        
        displayState = state
        configure(background: background)
        
        UIView.setAnimationsEnabled(withAnimation)
        
        Self.animate(withDuration: Presets.Animation.short.rawValue) { [weak self] in
            self?.layoutIfNeeded()
        }
        
        UIView.setAnimationsEnabled(true)
    }
    
    func showErrorMessage() {
        animateTo(state: .error)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        
        guard let text = textField.text,
                allowedCharacters.isSuperset(of: CharacterSet(charactersIn: string))
                && string.count <= CodeInputView.numberOfFields else { return false }
        
        let newLength = text.count + string.count - range.length
        
        return allowedCharacters.isSuperset(of: CharacterSet(charactersIn: text))
        && newLength <= CodeInputView.numberOfFields
    }
}
