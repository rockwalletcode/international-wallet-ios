//
//  SwapCurrencyView.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 05/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct SwapCurrencyConfiguration: Configurable {
    var shadow: ShadowConfiguration?
    var background: BackgroundConfiguration?
    var currencyIconBackground = BackgroundConfiguration(border: BorderConfiguration(borderWidth: 0, cornerRadius: .fullRadius))
}

struct SwapCurrencyViewModel: ViewModel {
    var amount: Amount?
    var currencyCode: String?
    var currencyImage: UIImage?
    var headerInfoButtonTitle: String?
    var formattedFiatString: NSMutableAttributedString?
    var formattedTokenString: NSMutableAttributedString?
    var fee: Amount?
    var formattedTokenFeeString: String?
    var title: LabelViewModel?
    var feeDescription: LabelViewModel?
    var selectionDisabled = false
}

class SwapCurrencyView: FEView<SwapCurrencyConfiguration, SwapCurrencyViewModel>, UITextFieldDelegate {
    var didTapSelectAsset: (() -> Void)?
    var didTapHeaderInfoButton: (() -> Void)?
    var didChangeFiatAmount: ((String?) -> Void)?
    var didChangeCryptoAmount: ((String?) -> Void)?
    var didChangeContent: (() -> Void)?
    var didFinish: ((_ didSwitchPlaces: Bool) -> Void)?
    
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.medium.rawValue
        return view
    }()
    
    private lazy var headerStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    private lazy var headerTitleLabel: FELabel = {
        let view = FELabel()
        view.font = Fonts.Body.three
        view.textColor = Colors.Text.three
        view.textAlignment = .left
        return view
    }()
    
    private lazy var headerInfoButton: FEButton = {
        let view = FEButton()
        view.addTarget(self, action: #selector(headerInfoButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private lazy var fiatStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = Margins.extraSmall.rawValue
        return view
    }()
    
    private lazy var fiatAmountField: UITextField = {
        let view = UITextField()
        view.textColor = Colors.Text.three
        view.font = Fonts.Subtitle.one
        view.tintColor = view.textColor
        view.textAlignment = .right
        view.keyboardType = .decimalPad
        view.delegate = self
        view.addTarget(self, action: #selector(fiatAmountDidChange(_:)), for: .editingChanged)
        return view
    }()
    
    private lazy var cryptoAmountField: UITextField = {
        let view = UITextField()
        view.textColor = Colors.Text.three
        view.font = Fonts.Title.five
        view.tintColor = view.textColor
        view.textAlignment = .right
        view.keyboardType = .decimalPad
        view.delegate = self
        view.addTarget(self, action: #selector(cryptoAmountDidChange(_:)), for: .editingChanged)
        view.adjustsFontSizeToFitWidth = true
        view.contentScaleFactor = 0.8
        return view
    }()
    
    private lazy var fiatCurrencyLabel: FELabel = {
        let view = FELabel()
        view.text = Constant.usdCurrencyCode
        view.font = Fonts.Subtitle.three
        view.textColor = Colors.Text.two
        view.textAlignment = .right
        return view
    }()
    
    private lazy var cryptoStack: UIStackView = {
        let view = UIStackView()
        return view
    }()
    
    lazy var selectorStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = Margins.small.rawValue
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectorTapped(_:))))
        return view
    }()
    
    private lazy var currencyIconImageView: WrapperView<FEImageView> = {
        let view = WrapperView<FEImageView>()
        return view
    }()
    
    private lazy var codeLabel: FELabel = {
        let view = FELabel()
        view.font = Fonts.Title.five
        view.textColor = Colors.Text.three
        view.textAlignment = .left
        view.sizeToFit()
        return view
    }()
    
    private lazy var selectorImageView: FEImageView = {
        let view = FEImageView()
        view.setup(with: .image(Asset.chevronDown.image))
        view.setupCustomMargins(all: .extraSmall)
        view.tintColor = Colors.Text.three
        return view
    }()
    
    private lazy var feeAndAmountsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .equalSpacing
        return view
    }()
    
    private lazy var feeLabel: FELabel = {
        let view = FELabel()
        view.font = Fonts.Subtitle.three
        view.textColor = Colors.Text.two
        view.textAlignment = .left
        return view
    }()
    
    private lazy var feeAmountLabel: FELabel = {
        let view = FELabel()
        view.font = Fonts.Subtitle.three
        view.textColor = Colors.Text.two
        view.textAlignment = .right
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
        
        mainStack.addArrangedSubview(feeAndAmountsStackView)
        feeAndAmountsStackView.addArrangedSubview(feeLabel)
        feeAndAmountsStackView.addArrangedSubview(feeAmountLabel)
        
        hideFeeAndAmountsStackView(noFee: true)
        
        mainStack.addArrangedSubview(headerStack)
        headerStack.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.small.rawValue)
        }
        headerStack.addArrangedSubview(headerTitleLabel)
        headerStack.addArrangedSubview(UIView())
        headerStack.addArrangedSubview(headerInfoButton)
        
        mainStack.addArrangedSubview(cryptoStack)
        cryptoStack.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.medium.rawValue)
        }
        
        cryptoStack.addArrangedSubview(selectorStackView)
        selectorStackView.snp.makeConstraints { make in
            make.width.equalTo(ViewSizes.extraExtraHuge.rawValue + ViewSizes.large.rawValue)
        }
        
        selectorStackView.addArrangedSubview(currencyIconImageView)
        currencyIconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(ViewSizes.medium.rawValue)
        }
        
        selectorStackView.addArrangedSubview(codeLabel)
        selectorStackView.addArrangedSubview(selectorImageView)
        selectorImageView.snp.makeConstraints { make in
            make.width.equalTo(ViewSizes.small.rawValue)
        }
        
        cryptoStack.addArrangedSubview(cryptoAmountField)
        cryptoAmountField.snp.makeConstraints { make in
            make.width.lessThanOrEqualToSuperview()
        }
        
        cryptoAmountField.setContentHuggingPriority(.required, for: .horizontal)
        
        mainStack.addArrangedSubview(fiatStack)
        
        let fiatSpacer = UIView()
        cryptoStack.addArrangedSubview(fiatSpacer)
        fiatSpacer.snp.makeConstraints { make in
            make.width.lessThanOrEqualToSuperview().priority(.required)
        }
        
        fiatStack.addArrangedSubview(fiatSpacer)
        fiatStack.addArrangedSubview(fiatAmountField)
        fiatStack.addArrangedSubview(fiatCurrencyLabel)
        
        decidePlaceholder()
    }
    
    @objc func fiatAmountDidChange(_ textField: UITextField) {
        let text = cleanupFormatting(textField: textField, forFiat: true)
        
        didChangeFiatAmount?(text)
        didChangeContent?()
    }
    
    @objc func cryptoAmountDidChange(_ textField: UITextField) {
        let text = cleanupFormatting(textField: textField, forFiat: false)
        
        didChangeCryptoAmount?(text)
        didChangeContent?()
    }
    
    private func cleanupFormatting(textField: UITextField, forFiat: Bool) -> String {
        let description = textField.text?.description ?? ""
        var text = String(describing: description.cleanupFormatting(forFiat: forFiat))
        
        if text == "0" && textField.text != "0" {
            text = ""
            textField.text = text
        }
        
        let range = textField.selectedTextRange
        textField.text = text
        textField.attributedText = ExchangeFormatter.createAmountString(string: text)
        textField.selectedTextRange = range

        decidePlaceholder()

        return text.isEmpty ? "0" : text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setChangedText(for: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setChangedText(for: textField)
        
        didFinish?(false)
    }
    
    override func configure(with config: SwapCurrencyConfiguration?) {
        super.configure(with: config)
        
        configure(background: config?.background)
        configure(shadow: config?.shadow)
        
        currencyIconImageView.wrappedView.configure(background: config?.currencyIconBackground)
        
        let buttonConfig = BackgroundConfiguration(backgroundColor: Colors.purpleMuted,
                                                   tintColor: Colors.instantPurple,
                                                   border: BorderConfiguration(tintColor: .clear,
                                                                               borderWidth: 0,
                                                                               cornerRadius: .fullRadius))
        headerInfoButton.configure(with: .init(normalConfiguration: buttonConfig,
                                               selectedConfiguration: buttonConfig,
                                               disabledConfiguration: buttonConfig,
                                               font: Fonts.Body.three))
    }
    
    override func setup(with viewModel: SwapCurrencyViewModel?) {
        guard let viewModel = viewModel else { return }
        super.setup(with: viewModel)
        
        headerTitleLabel.setup(with: viewModel.title)
        headerTitleLabel.isHidden = viewModel.title == nil
        
        headerInfoButton.setup(with: .init(title: viewModel.headerInfoButtonTitle, shouldCapitalize: true))
        headerInfoButton.isHidden = viewModel.headerInfoButtonTitle == nil
        
        if !fiatAmountField.isFirstResponder {
            fiatAmountField.attributedText = viewModel.formattedFiatString
        }
        
        if !cryptoAmountField.isFirstResponder {
            cryptoAmountField.attributedText = viewModel.formattedTokenString
        }
        
        fiatStack.isHidden = viewModel.formattedFiatString == nil
        
        codeLabel.text = viewModel.amount?.currency.code ?? viewModel.currencyCode
        
        currencyIconImageView.wrappedView.setup(with: .image(viewModel.amount?.currency.imageSquareBackground ?? viewModel.currencyImage))
        
        if viewModel.amount == nil {
            currencyIconImageView.wrappedView.contentMode = .scaleAspectFill
        }
        
        if let tokenFee = viewModel.formattedTokenFeeString {
            feeAmountLabel.text = "\(tokenFee)"
        }
        
        feeLabel.setup(with: viewModel.feeDescription)
        
        let noFee = viewModel.fee == nil || viewModel.fee?.tokenValue == 0 || viewModel.amount?.tokenValue == 0
        hideFeeAndAmountsStackView(noFee: noFee)
        
        let image: UIImage? = viewModel.selectionDisabled ? nil : Asset.chevronDown.image
        selectorImageView.setup(with: .image(image))
        
        decidePlaceholder()
    }
    
    func hideFeeAndAmountsStackView(noFee: Bool) {
        feeAndAmountsStackView.alpha = noFee ? 0 : 1
        feeAndAmountsStackView.isHidden = noFee
    }
    
    func resetTextFieldValues() {
        fiatAmountField.text = nil
        cryptoAmountField.text = nil
    }
    
    private func setChangedText(for textField: UITextField) {
        if textField == fiatAmountField {
            fiatAmountDidChange(textField)
        } else if textField == cryptoAmountField {
            cryptoAmountDidChange(textField)
        }
    }
    
    @objc private func selectorTapped(_ sender: Any) {
        endEditing(true)
        
        didTapSelectAsset?()
    }
    
    @objc private func headerInfoButtonTapped(_ sender: FEButton) {
        didTapHeaderInfoButton?()
    }
    
    private func setPlaceholder(for field: UITextField) {
        guard let textColor = field.textColor,
              let font = field.font,
              let text = field.text,
              let attributedPlaceholder = ExchangeFormatter.createAmountString(string: ExchangeFormatter.fiat.string(for: 0) ?? "") else { return }
        
        let isActive = field.isFirstResponder && text.isEmpty
        
        attributedPlaceholder.addAttributes([NSAttributedString.Key.foregroundColor: isActive ? Colors.Outline.two : textColor,
                                             NSAttributedString.Key.font: font],
                                            range: NSRange(location: 0, length: attributedPlaceholder.length))
        
        field.attributedPlaceholder = attributedPlaceholder
    }
    
    private func decidePlaceholder() {
        setPlaceholder(for: fiatAmountField)
        setPlaceholder(for: cryptoAmountField)
    }
    
    func setAlpha(value: Double) {
        headerTitleLabel.alpha = value
        fiatStack.alpha = value
        fiatAmountField.alpha = value
        fiatCurrencyLabel.alpha = value
        cryptoAmountField.alpha = value
    }
}
