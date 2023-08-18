// 
//  CardSelectionView.swift
//  breadwallet
//
//  Created by Rok on 01/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct CardSelectionConfiguration: Configurable {
    var title: LabelConfiguration? = .init(font: Fonts.Body.three, textColor: Colors.Text.two)
    var subtitle: LabelConfiguration? = .init(font: Fonts.Subtitle.two, textColor: Colors.Text.one)
    var arrow: BackgroundConfiguration? = Presets.Background.Secondary.selected
    var shadow: ShadowConfiguration? = Presets.Shadow.light
    var background: BackgroundConfiguration? = .init(backgroundColor: Colors.Background.one,
                                                     tintColor: Colors.Text.one,
                                                     border: Presets.Border.mediumPlain)
    var cardDetails: CardDetailsConfiguration? = .init()
}

struct CardSelectionViewModel: ViewModel {
    var title: LabelViewModel? = .text(L10n.Buy.payWith)
    var subtitle: LabelViewModel? = .text(L10n.Buy.addYourCard)
    var logo: ImageViewModel?
    var cardNumber: LabelViewModel?
    var expiration: LabelViewModel?
    var arrow: ImageViewModel? = .image(Asset.chevronRight.image)
    var userInteractionEnabled = false
    var errorMessage: LabelViewModel?
}

class CardSelectionView: FEView<CardSelectionConfiguration, CardSelectionViewModel> {
    
    var moreButtonCallback: (() -> Void)?
    var didTapSelectCard: (() -> Void)?
    var errorLinkCallback: (() -> Void)?
     
    private lazy var containerStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        return view
    }()
    
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var subtitleLabel: FELabel = {
        let view = FELabel()
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    
    private lazy var cardDetailsView: CardDetailsView = {
        let view = CardDetailsView()
        return view
    }()
    
    private lazy var spacerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var arrowImageView: FEImageView = {
        let view = FEImageView()
        return view
    }()
    
    var hasError: Bool = false {
        didSet {
            let cardNumberConfig = config?.cardDetails?.cardNumber
            let cardNumberErrorConfig = config?.cardDetails?.cardNumberError
            
            let expirationConfig = config?.cardDetails?.expiration
            let expirationErrorConfig = config?.cardDetails?.expirationError
            
            config?.cardDetails?.cardNumber = hasError ? cardNumberErrorConfig : cardNumberConfig
            config?.cardDetails?.expiration = hasError ? expirationErrorConfig : expirationConfig
            
            configure(with: config)
        }
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.setupCustomMargins(all: .large)
        
        content.addSubview(containerStack)
        containerStack.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
            make.height.greaterThanOrEqualTo(ViewSizes.Common.hugeCommon.rawValue)
        }
        
        containerStack.addArrangedSubview(mainStack)
        mainStack.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.medium.rawValue / 2)
        }
        mainStack.addArrangedSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.medium.rawValue)
        }
                
        mainStack.addArrangedSubview(cardDetailsView)
        
        containerStack.addArrangedSubview(spacerView)
        spacerView.snp.makeConstraints { make in
            make.width.lessThanOrEqualToSuperview().priority(.low)
        }
        
        containerStack.addArrangedSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.width.equalTo(ViewSizes.small.rawValue)
        }
        
        cardDetailsView.moreButtonCallback = { [weak self] in
            self?.moreButtonTapped()
        }
    }
    
    override func configure(with config: CardSelectionConfiguration?) {
        super.configure(with: config)
        titleLabel.configure(with: config?.title)
        subtitleLabel.configure(with: config?.subtitle)
        cardDetailsView.configure(with: config?.cardDetails)
        arrowImageView.configure(with: config?.arrow)
        
        configure(background: config?.background)
        configure(shadow: config?.shadow)
    }
    
    override func setup(with viewModel: CardSelectionViewModel?) {
        super.setup(with: viewModel)
        
        titleLabel.setup(with: viewModel?.title)
        titleLabel.isHidden = viewModel?.title == nil
        
        subtitleLabel.setup(with: viewModel?.subtitle)
        subtitleLabel.isHidden = viewModel?.logo != nil && viewModel?.cardNumber != nil && viewModel?.expiration != nil || viewModel?.subtitle == nil
        
        cardDetailsView.isHidden = viewModel?.logo == nil
        
        arrowImageView.setup(with: viewModel?.arrow)
        arrowImageView.isHidden = (viewModel?.expiration != nil && titleLabel.isHidden) || viewModel?.userInteractionEnabled == false
        
        let moreOption = viewModel?.expiration != nil && titleLabel.isHidden
        
        cardDetailsView.setup(with: .init(logo: viewModel?.logo,
                                          title: titleLabel.isHidden == true ? viewModel?.title : nil,
                                          cardNumber: viewModel?.cardNumber,
                                          expiration: viewModel?.expiration,
                                          moreOption: moreOption,
                                          errorMessage: viewModel?.errorMessage))
        cardDetailsView.errorLinkCallback = { [weak self] in
            self?.errorLinkCallback?()
        }
        hasError = viewModel?.errorMessage != nil
        
        spacerView.isHidden = arrowImageView.isHidden
        
        guard viewModel?.userInteractionEnabled == true else {
            gestureRecognizers?.forEach { removeGestureRecognizer($0) }
            return
        }
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardSelectorTapped)))
    }
    
    @objc private func cardSelectorTapped() {
        didTapSelectCard?()
    }
    
    private func moreButtonTapped() {
        moreButtonCallback?()
    }
}
