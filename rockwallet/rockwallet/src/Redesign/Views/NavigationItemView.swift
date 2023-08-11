// 
//  ImageLabelView.swift
//  breadwallet
//
//  Created by Rok on 26/05/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct NavigationConfiguration: Configurable {
    var image: BackgroundConfiguration?
    var label: LabelConfiguration?
    var button: ButtonConfiguration?
    var shadow: ShadowConfiguration?
    var background: BackgroundConfiguration?
}

struct NavigationViewModel: ViewModel {
    var image: ImageViewModel?
    var label: LabelViewModel?
    var button: ButtonViewModel?
    var showError: Bool = false
}

class NavigationItemView: FEView<NavigationConfiguration, NavigationViewModel> {
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.spacing = Margins.medium.rawValue
        return view
    }()
    
    private lazy var leadingImageContainer: UIView = {
        return UIView()
    }()
    
    private lazy var leadingImageView: FEImageView = {
        let view = FEImageView()
        return view
    }()
    
    private lazy var titleLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var trailing: FEButton = {
        let view = FEButton()
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
            make.edges.equalToSuperview()
        }
        
        mainStack.addArrangedSubview(leadingImageContainer)
        leadingImageContainer.snp.makeConstraints { make in
            make.width.equalTo(ViewSizes.medium.rawValue)
        }
        
        leadingImageContainer.addSubview(leadingImageView)
        leadingImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(ViewSizes.small.rawValue)
        }
        
        leadingImageView.addSubview(errorIndicator)
        errorIndicator.snp.makeConstraints { make in
            make.width.height.equalTo(ViewSizes.extraExtraSmall.rawValue)
            make.centerX.equalTo(leadingImageView.snp.trailing)
            make.centerY.equalTo(leadingImageView.snp.bottom).inset(Margins.extraSmall.rawValue)
        }
        
        mainStack.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().priority(.low)
        }
        
        mainStack.addArrangedSubview(trailing)
        trailing.snp.makeConstraints { make in
            make.width.equalTo(Margins.huge.rawValue)
        }
    }
    
    override func configure(with config: NavigationConfiguration?) {
        guard let config = config else { return }
        super.configure(with: config)
        
        leadingImageView.configure(with: config.image)
        titleLabel.configure(with: config.label)
        trailing.configure(with: config.button)
        
        configure(background: config.background)
        configure(shadow: config.shadow)
    }
    
    override func setup(with viewModel: NavigationViewModel?) {
        guard let viewModel = viewModel else { return }
        super.setup(with: viewModel)
        
        leadingImageView.setup(with: viewModel.image)
        leadingImageView.isHidden = viewModel.image == nil
        errorIndicator.isHidden = !viewModel.showError
        
        titleLabel.setup(with: viewModel.label)
        titleLabel.isHidden = viewModel.label == nil
        
        trailing.setup(with: viewModel.button)
        trailing.isHidden = viewModel.button == nil
    }
}
