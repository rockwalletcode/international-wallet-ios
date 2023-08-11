//
//  FETextField.swift
//  breadwallet
//
//  Created by Rok on 11/05/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct TextFieldConfiguration: Configurable {
    var leadingImageConfiguration: BackgroundConfiguration?
    var titleConfiguration: LabelConfiguration?
    var selectedTitleConfiguration: LabelConfiguration?
    var textConfiguration: LabelConfiguration?
    var placeholderConfiguration: LabelConfiguration?
    var hintConfiguration: LabelConfiguration?
    
    var trailingImageConfiguration: BackgroundConfiguration?
    var backgroundConfiguration: BackgroundConfiguration?
    var selectedBackgroundConfiguration: BackgroundConfiguration?
    var disabledBackgroundConfiguration: BackgroundConfiguration?
    var errorBackgroundConfiguration: BackgroundConfiguration?
    
    var shadow: ShadowConfiguration?
    var background: BackgroundConfiguration?
    
    var autocapitalizationType: UITextAutocapitalizationType = .none
    var autocorrectionType: UITextAutocorrectionType = .no
    var keyboardType: UIKeyboardType = .default
    var isSecureTextEntry: Bool = false
}

extension TextFieldConfiguration {
    func setSecure(_ isSecure: Bool) -> TextFieldConfiguration {
        var copy = self
        copy.isSecureTextEntry = isSecure
        return copy
    }
}

struct TextFieldModel: ViewModel {
    var leading: ImageViewModel?
    var title: String?
    var value: String?
    var placeholder: String?
    var hint: String?
    var info: InfoViewModel?
    var trailing: ImageViewModel?
    var displayState: DisplayState?
    var displayStateAnimated: Bool?
    var isUserInteractionEnabled: Bool = true
    var showPasswordToggle: Bool = false
}

class FETextField: FEView<TextFieldConfiguration, TextFieldModel>, UITextFieldDelegate, StateDisplayable {
    var displayState: DisplayState = .normal
    
    var valueChanged: ((UITextField) -> Void)?
    var beganEditing: ((UITextField) -> Void)?
    var finishedEditing: ((UITextField) -> Void)?
    
    var didTapTrailingView: (() -> Void)?
    var didPasteText: ((String) -> Void)?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        isUserInteractionEnabled = true
        value = nil
    }
    
    override var isUserInteractionEnabled: Bool {
        get {
            return textField.isUserInteractionEnabled
        }
        
        set {
            content.isUserInteractionEnabled = newValue
            textField.isUserInteractionEnabled = newValue
        }
    }
    
    var value: String? {
        get { return textField.text }
        set {
            textField.text = newValue
        }
    }
    
    // MARK: Lazy UI
    
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
    private lazy var textFieldContent: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var textFieldStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        return view
    }()
    
    private lazy var titleStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = Margins.small.rawValue
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var hintLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var leadingView: FEImageView = {
        let view = FEImageView()
        return view
    }()
    
    private lazy var textField: UITextField = {
        let view = UITextField()
        return view
    }()
    
    private lazy var trailingView: FEImageView = {
        let view = FEImageView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    var delegate: UITextFieldDelegate?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        mainStack.addArrangedSubview(textFieldContent)
        mainStack.addArrangedSubview(hintLabel)
        
        textFieldContent.addSubview(textFieldStack)
        textFieldContent.addSubview(trailingView)
        
        textFieldStack.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(ViewSizes.Common.defaultCommon.rawValue)
            make.leading.equalTo(Margins.large.rawValue)
            make.trailing.equalTo(trailingView.snp.leading).offset(-Margins.minimum.rawValue)
        }
        
        textFieldStack.addArrangedSubview(titleStack)
        textFieldStack.addArrangedSubview(textField)
        
        titleStack.addArrangedSubview(leadingView)
        titleStack.addArrangedSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().priority(.low)
        }
        
        trailingView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.height.equalTo(textFieldStack.snp.height)
            make.width.equalTo(ViewSizes.extraSmall.rawValue)
            make.trailing.equalTo(-Margins.large.rawValue)
            make.centerY.equalToSuperview()
        }
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = delegate ?? self
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(startEditing))
        addGestureRecognizer(tapped)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(trailingViewTapped))
        trailingView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func configure(with config: TextFieldConfiguration?) {
        guard let config = config else { return }
        
        super.configure(with: config)
        
        textField.autocapitalizationType = config.autocapitalizationType
        textField.autocorrectionType = config.autocorrectionType
        textField.keyboardType = config.keyboardType
        textField.isSecureTextEntry = config.isSecureTextEntry
        
        if viewModel?.showPasswordToggle == true {
            let trailingModel: ImageViewModel = config.isSecureTextEntry ?
                .image(Asset.eyeShow.image.tinted(with: LightColors.Text.three)) : .image(Asset.eyeHide.image.tinted(with: LightColors.Text.three))
            trailingView.setup(with: trailingModel)
        }
        
        if let textConfig = config.textConfiguration {
            textField.font = textConfig.font
            textField.textColor = textConfig.textColor
            textField.textAlignment = textConfig.textAlignment
        }
        
        hintLabel.configure(with: config.hintConfiguration)
        
        leadingView.configure(with: config.leadingImageConfiguration)
        trailingView.configure(with: config.trailingImageConfiguration)
        
        shadowView = mainStack
        backgroundView = textFieldContent
        
        configure(background: config.background)
        configure(shadow: config.shadow)
    }
    
    override func setup(with viewModel: TextFieldModel?) {
        guard let viewModel = viewModel else { return }
        
        super.setup(with: viewModel)
        
        titleLabel.setup(with: .text(viewModel.title))
        titleLabel.isHidden = viewModel.title == nil
        textField.text = viewModel.value ?? textField.text
        
        if let placeholder = viewModel.placeholder,
           let config = config?.placeholderConfiguration {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: (config.textColor ?? .black),
                .font: config.font
            ]
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
        
        hintLabel.setup(with: .text(viewModel.hint))
        
        leadingView.setup(with: viewModel.leading)
        leadingView.isHidden = viewModel.leading == nil
        
        let shouldHideTrailingView = viewModel.trailing == nil && !viewModel.showPasswordToggle
        trailingView.isHidden = shouldHideTrailingView
        
        trailingView.snp.updateConstraints { make in
            make.width.equalTo(shouldHideTrailingView ? 0 : ViewSizes.extraSmall.rawValue)
        }
        
        if let trailing = viewModel.trailing {
            trailingView.setup(with: trailing)
        }
        
        titleStack.isHidden = leadingView.isHidden && titleLabel.isHidden
        
        mainStack.spacing = titleStack.isHidden ? 0 : Margins.extraSmall.rawValue
        textFieldStack.spacing = titleStack.isHidden ? 0 : -Margins.medium.rawValue
        
        isUserInteractionEnabled = viewModel.isUserInteractionEnabled
        
        animateTo(state: viewModel.displayState ?? .normal, withAnimation: viewModel.displayStateAnimated == true)
    }
    
    @objc private func startEditing() {
        textField.becomeFirstResponder()
        
        viewModel?.displayState = .selected
        animateTo(state: viewModel?.displayState ?? .normal, withAnimation: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewModel?.displayState = .selected
        animateTo(state: viewModel?.displayState ?? .normal, withAnimation: true)
        
        beganEditing?(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel?.displayState = .normal
        animateTo(state: viewModel?.displayState ?? .normal, withAnimation: true)
        
        finishedEditing?(textField)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        valueChanged?(textField)
    }
    
    @objc private func trailingViewTapped() {
        guard viewModel?.showPasswordToggle == false else {
            config?.isSecureTextEntry.toggle()
            configure(with: config)
            return
        }

        didTapTrailingView?()
    }
    
    func animateTo(state: DisplayState, withAnimation: Bool = true) {
        viewModel?.displayState = state
        
        let hint = viewModel?.hint
        var hideTextField = textField.text?.isEmpty == true
        var titleConfig: LabelConfiguration? = config?.titleConfiguration
        let background: BackgroundConfiguration?
        
        switch state {
        case .normal:
            background = config?.backgroundConfiguration
            
        case .highlighted, .selected, .filled:
            background = config?.selectedBackgroundConfiguration
            titleConfig = config?.selectedTitleConfiguration
            
            hideTextField = false
            
        case .disabled:
            background = config?.disabledBackgroundConfiguration
            
        case .error:
            background = config?.errorBackgroundConfiguration
        }
        
        UIView.setAnimationsEnabled(withAnimation)
        
        UIView.animate(withDuration: Presets.Animation.short.rawValue) { [weak self] in
            if self?.viewModel?.placeholder == nil {
                self?.textField.isHidden = hideTextField
            }
        }
        
        hintLabel.setup(with: .text(hint))
        titleLabel.configure(with: titleConfig)
        configure(background: background)
        
        UIView.setAnimationsEnabled(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 1,
           string.count == UIPasteboard.general.string?.count,
           let didPasteText = didPasteText {
            didPasteText(string)
            return false
        }
        return true
    }
    
    func setAccessoryView(with view: UIView) {
        textField.inputAccessoryView = view
    }
    
    func changeToFirstResponder() {
        startEditing()
    }
}
