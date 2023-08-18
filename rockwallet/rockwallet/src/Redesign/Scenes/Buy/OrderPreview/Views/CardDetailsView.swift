// 
//  CardDetailsView.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 16/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct CardDetailsConfiguration: Configurable {
    var logo: BackgroundConfiguration? = .init(tintColor: LightColors.Text.two)
    var title: LabelConfiguration? = .init(font: Fonts.Body.three, textColor: LightColors.Text.two, numberOfLines: 1)
    var cardNumber: LabelConfiguration? = .init(font: Fonts.Subtitle.two, textColor: LightColors.Text.one, numberOfLines: 1)
    var cardNumberError: LabelConfiguration? = .init(font: Fonts.Subtitle.two, textColor: LightColors.Text.two, numberOfLines: 1)
    var expiration: LabelConfiguration? = .init(font: Fonts.Subtitle.two, textColor: LightColors.Text.one)
    var expirationError: LabelConfiguration? = .init(font: Fonts.Subtitle.two, textColor: LightColors.Text.two)
    var moreButton: BackgroundConfiguration? = Presets.Background.Secondary.selected
}

struct CardDetailsViewModel: ViewModel {
    var logo: ImageViewModel?
    var title: LabelViewModel?
    var cardNumber: LabelViewModel?
    var expiration: LabelViewModel?
    var moreOption: Bool = false
    var errorMessage: LabelViewModel?
}

class CardDetailsView: FEView<CardDetailsConfiguration, CardDetailsViewModel> {
    var moreButtonCallback: (() -> Void)?
    var errorLinkCallback: (() -> Void)?
    
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    private lazy var selectorStack: UIStackView = {
        let view = UIStackView()
        view.spacing = Margins.medium.rawValue
        return view
    }()
    
    private lazy var logoImageView: FEImageView = {
        let view = FEImageView()
        return view
    }()
    
    private lazy var titleStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = Margins.minimum.rawValue
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var cardNumberLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var expirationLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var moreButton: FEButton = {
        let view = FEButton()
        view.setImage(Asset.more.image, for: .normal)
        return view
    }()
    
    private lazy var errorLabel: FELabel = {
        let view = FELabel()
        view.configure(with: .init())
        return view
    }()
    
    private lazy var errorIndicator: UIImageView = {
        let view = UIImageView(image: Asset.redWarning.image)
        view.isHidden = true
        return view
    }()

    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        mainStack.addArrangedSubview(selectorStack)
        
        selectorStack.addArrangedSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(ViewSizes.medium.rawValue)
        }
        
        logoImageView.addSubview(errorIndicator)
        errorIndicator.snp.makeConstraints { make in
            make.width.height.equalTo(ViewSizes.extraExtraSmall.rawValue)
            make.centerX.equalTo(logoImageView.snp.trailing)
            make.bottom.equalTo(logoImageView.snp.bottom)
        }
        
        selectorStack.addArrangedSubview(titleStack)
        titleStack.snp.makeConstraints { make in
            make.width.lessThanOrEqualToSuperview().priority(.low)
        }
        
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(cardNumberLabel)
        
        selectorStack.addArrangedSubview(expirationLabel)
        selectorStack.addArrangedSubview(UIView())
        
        selectorStack.addArrangedSubview(moreButton)
        moreButton.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        
        mainStack.addArrangedSubview(errorLabel)
        
        layoutIfNeeded()
    }
    
    override func configure(with config: CardDetailsConfiguration?) {
        super.configure(with: config)
        
        logoImageView.configure(with: config?.logo)
        titleLabel.configure(with: config?.title)
        cardNumberLabel.configure(with: config?.cardNumber)
        expirationLabel.configure(with: config?.expiration)
        moreButton.configure(background: config?.moreButton)
    }
    
    override func setup(with viewModel: CardDetailsViewModel?) {
        super.setup(with: viewModel)
        
        titleLabel.setup(with: viewModel?.title)
        titleLabel.isHidden = viewModel?.title == nil
        
        cardNumberLabel.setup(with: viewModel?.cardNumber)
        cardNumberLabel.isHidden = viewModel?.cardNumber == nil
        
        logoImageView.setup(with: viewModel?.logo)
        logoImageView.isHidden = viewModel?.logo == nil
        
        expirationLabel.setup(with: viewModel?.expiration)
        expirationLabel.isHidden = viewModel?.expiration == nil
        
        errorLabel.setup(with: viewModel?.errorMessage)
        errorLabel.isHidden = viewModel?.errorMessage == nil
        errorLabel.isUserInteractionEnabled = viewModel?.errorMessage != nil
        errorLabel.didTapLink = { [weak self] in
            self?.errorLinkCallback?()
        }
        errorIndicator.isHidden = errorLabel.isHidden
        
        guard let moreOption = viewModel?.moreOption else { return }
        moreButton.isHidden = !moreOption || viewModel?.errorMessage != nil
    }
    
    @objc private func moreButtonTapped(_ sender: UIButton?) {
        moreButtonCallback?()
    }
}
