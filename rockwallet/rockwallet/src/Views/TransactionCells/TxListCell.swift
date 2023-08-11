//
//  TxListCell.swift
//  breadwallet
//
//  Created by Ehsan Rezaie on 2018-02-19.
//  Copyright © 2018-2019 Breadwinner AG. All rights reserved.
//

import UIKit

class TxListCell: UITableViewCell, Identifiable {

    // MARK: - Views

    private  let iconImageView: UIImageView = {
        let view = UIImageView()
        view.layer.masksToBounds = true
        return view
    }()
    
    private  let amount: UILabel = {
        let label = UILabel(font: Fonts.Subtitle.two, color: LightColors.Text.three)
        return label
    }()
    
    private let titleLabel = UILabel(font: Fonts.Subtitle.two, color: LightColors.Text.three)
    private let descriptionLabel = UILabel(font: Fonts.Body.two, color: LightColors.Text.two)
    private let separator = UIView(color: LightColors.Outline.one)
    private var viewModel: TxListViewModel?
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconImageView.layer.cornerRadius = iconImageView.frame.height * CornerRadius.fullRadius.rawValue
    }
    
    func setTransaction(_ viewModel: TxListViewModel, showFiatAmounts: Bool, rate: Rate) {
        self.viewModel = viewModel
        
        let status = viewModel.status
        iconImageView.image = viewModel.icon?.tinted(with: status.tintColor)
        iconImageView.backgroundColor = status.backgroundColor
        
        titleLabel.text = viewModel.title
        amount.text = viewModel.amount(showFiatAmounts: showFiatAmounts, rate: rate)
        descriptionLabel.text = viewModel.shortDescription()
        
        setupStyle()
        layoutSubviews()
    }
    
    // MARK: - Private
    
    private func setupViews() {
        addSubviews()
        addConstraints()
        setupStyle()
    }
    
    private func addSubviews() {
        contentView.addSubview(iconImageView)
        iconImageView.contentMode = .center
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(amount)
        contentView.addSubview(separator)
    }
    
    private func addConstraints() {
        iconImageView.constrain([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Margins.large.rawValue),
            iconImageView.widthAnchor.constraint(equalToConstant: ViewSizes.medium.rawValue),
            iconImageView.heightAnchor.constraint(equalToConstant: ViewSizes.medium.rawValue),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        titleLabel.constrain([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.medium.rawValue),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Margins.large.rawValue)])
        descriptionLabel.constrain([
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Margins.medium.rawValue),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: amount.leadingAnchor, constant: -Margins.large.rawValue)
        ])
        amount.constrain([
            amount.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Margins.large.rawValue),
            amount.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.medium.rawValue),
            amount.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Margins.large.rawValue)])
        separator.constrainBottomCorners(height: ViewSizes.minimum.rawValue)
    }
    
    private func setupStyle() {
        selectionStyle = .none
        backgroundColor = LightColors.Background.two
        amount.textAlignment = .right
        descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        switch viewModel?.exchangeType {
        case .unknown:
            descriptionLabel.lineBreakMode = .byTruncatingTail
            descriptionLabel.numberOfLines = 1
            
        default:
            descriptionLabel.numberOfLines = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
