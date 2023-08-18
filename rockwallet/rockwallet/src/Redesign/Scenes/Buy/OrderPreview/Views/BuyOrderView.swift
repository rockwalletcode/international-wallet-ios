// 
//  BuyOrderView.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 12.8.22.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct BuyOrderConfiguration: Configurable {
    var notice: LabelConfiguration = .init(font: Fonts.Body.three, textColor: LightColors.instantPurple, textAlignment: .center)
    var noticeBackground: BackgroundConfiguration? = .init(backgroundColor: LightColors.purpleMuted,
                                                           tintColor: LightColors.purpleMuted,
                                                           border: Presets.Border.commonPlain)
    var title: LabelConfiguration = .init(font: Fonts.Body.two, textColor: LightColors.Text.one)
    var currencyAmountName: LabelConfiguration = .init(font: Fonts.Title.five, textColor: LightColors.Text.one)
    var common: TitleValueConfiguration = Presets.TitleValue.common
    var bold: TitleValueConfiguration = Presets.TitleValue.bold
    var shadow: ShadowConfiguration? = Presets.Shadow.light
    var background: BackgroundConfiguration? = .init(backgroundColor: LightColors.Background.one,
                                                     tintColor: LightColors.Text.one,
                                                     border: Presets.Border.mediumPlain)
    var currencyIconImage = BackgroundConfiguration(border: BorderConfiguration(borderWidth: 0, cornerRadius: .fullRadius))
}

struct BuyOrderViewModel: ViewModel {
    var notice: LabelViewModel?
    var title: LabelViewModel = .text(L10n.Buy.yourOrder)
    var currencyIcon: ImageViewModel?
    var currencyAmountName: LabelViewModel?
    var rate: TitleValueViewModel?
    var amount: TitleValueViewModel
    var cardFee: TitleValueViewModel?
    var instantBuyFee: TitleValueViewModel?
    var networkFee: TitleValueViewModel?
    var totalCost: TitleValueViewModel
    var paymentMethod: PaymentMethodViewModel?
    var exceedInstantBuyLimit: Bool?
}

class BuyOrderView: FEView<BuyOrderConfiguration, BuyOrderViewModel> {
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.medium.rawValue
        return view
    }()
    
    private lazy var noticeContainer: WrapperView<UIView> = {
        let view = WrapperView<UIView>()
        return view
    }()
    
    private lazy var noticeLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    lazy var currencyStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    private lazy var currencyIconImageView: WrapperView<FEImageView> = {
        let view = WrapperView<FEImageView>()
        return view
    }()
    
    private lazy var currencyNameLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var topLineView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = LightColors.Outline.one.cgColor
        return view
    }()
    
    private lazy var rateView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var amountView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var cardFeeView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var instantBuyFeeView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var networkFeeView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var bottomLineView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = LightColors.Outline.one.cgColor
        return view
    }()
    
    private lazy var totalCostView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var paymentLineView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1.0
        view.layer.borderColor = LightColors.Outline.one.cgColor
        return view
    }()
    
    private lazy var paymentMethodView: PaymentMethodView = {
        let view = PaymentMethodView()
        return view
    }()
    
    var cardFeeInfoTapped: (() -> Void)?
    var networkFeeInfoTapped: (() -> Void)?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
        }
        content.setupCustomMargins(all: .huge)
        
        mainStack.addArrangedSubview(noticeContainer)
        noticeContainer.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(ViewSizes.large.rawValue)
        }
        
        noticeContainer.addSubview(noticeLabel)
        
        noticeLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Margins.small.rawValue)
        }
        
        mainStack.addArrangedSubview(titleLabel)
        
        mainStack.addArrangedSubview(currencyStackView)
        currencyStackView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.small.rawValue)
        }
        
        currencyStackView.addArrangedSubview(currencyIconImageView)
        currencyIconImageView.snp.makeConstraints { make in
            make.width.equalTo(ViewSizes.small.rawValue)
        }
        
        currencyStackView.addArrangedSubview(currencyNameLabel)
        
        mainStack.addArrangedSubview(rateView)
        
        mainStack.addArrangedSubview(topLineView)
        topLineView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.minimum.rawValue)
        }
        
        mainStack.addArrangedSubview(amountView)
        mainStack.addArrangedSubview(cardFeeView)
        mainStack.addArrangedSubview(instantBuyFeeView)
        mainStack.addArrangedSubview(networkFeeView)
        
        mainStack.addArrangedSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.minimum.rawValue)
        }
        
        mainStack.addArrangedSubview(totalCostView)
        
        [titleLabel, rateView, amountView, cardFeeView, instantBuyFeeView, networkFeeView, totalCostView].forEach { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(ViewSizes.extraSmall.rawValue)
            }
        }
        
        mainStack.addArrangedSubview(paymentLineView)
        paymentLineView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.minimum.rawValue)
        }
        
        mainStack.addArrangedSubview(paymentMethodView)
        
        cardFeeView.didTapInfoButton = { [weak self] in
            self?.cardFeeInfoButtonTapped()
        }
        
        networkFeeView.didTapInfoButton = { [weak self] in
            self?.networkFeeViewInfoButtonTapped()
        }
    }
    
    override func configure(with config: BuyOrderConfiguration?) {
        super.configure(with: config)
        
        noticeLabel.configure(with: config?.notice)
        noticeContainer.configure(background: config?.noticeBackground)
        titleLabel.configure(with: config?.title)
        currencyIconImageView.wrappedView.configure(background: config?.currencyIconImage)
        currencyNameLabel.configure(with: config?.currencyAmountName)
        rateView.configure(with: config?.common)
        amountView.configure(with: config?.common)
        cardFeeView.configure(with: config?.common)
        
        var instantBuyFeeConfig = config?.common
        instantBuyFeeConfig?.title.textColor = LightColors.instantPurple
        instantBuyFeeConfig?.title.font = Fonts.Subtitle.two
        instantBuyFeeView.configure(with: instantBuyFeeConfig)
        
        networkFeeView.configure(with: config?.common)
        totalCostView.configure(with: config?.bold)
        
        paymentMethodView.configure(with: .init(background: .init(backgroundColor: LightColors.Background.one,
                                                                  tintColor: LightColors.Text.one)))
        paymentMethodView.content.setupCustomMargins(all: .zero)
        
        configure(background: config?.background)
        configure(shadow: config?.shadow)
    }
    
    override func setup(with viewModel: BuyOrderViewModel?) {
        super.setup(with: viewModel)
        
        noticeLabel.setup(with: viewModel?.notice)
        noticeContainer.isHidden = viewModel?.notice == nil
        
        titleLabel.setup(with: viewModel?.title)
        currencyIconImageView.wrappedView.setup(with: viewModel?.currencyIcon)
        currencyNameLabel.setup(with: viewModel?.currencyAmountName)
        
        rateView.setup(with: viewModel?.rate)
        rateView.isHidden = viewModel?.rate == nil
        
        [titleLabel, currencyStackView, topLineView].forEach { view in
            view.isHidden = viewModel?.currencyIcon == nil && viewModel?.currencyAmountName == nil
        }
        
        amountView.setup(with: viewModel?.amount)
        cardFeeView.setup(with: viewModel?.cardFee)
        cardFeeView.isHidden = viewModel?.cardFee == nil
        
        instantBuyFeeView.setup(with: viewModel?.instantBuyFee)
        instantBuyFeeView.isHidden = viewModel?.instantBuyFee == nil
        
        networkFeeView.setup(with: viewModel?.networkFee)
        networkFeeView.isHidden = viewModel?.networkFee == nil
        
        totalCostView.setup(with: viewModel?.totalCost)
        
        paymentMethodView.setup(with: viewModel?.paymentMethod)
        paymentMethodView.isHidden = viewModel?.paymentMethod == nil
        paymentLineView.isHidden = viewModel?.paymentMethod == nil
        
        needsUpdateConstraints()
    }
    
    private func cardFeeInfoButtonTapped() {
        cardFeeInfoTapped?()
    }
    
    private func networkFeeViewInfoButtonTapped() {
        networkFeeInfoTapped?()
    }
}
