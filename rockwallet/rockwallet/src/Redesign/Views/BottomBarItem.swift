// 
//  BottomBarItem.swift
//  breadwallet
//
//  Created by Dino Gacevic on 03/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct BottomBarItemConfiguration: Configurable {
}

struct BottomBarItemViewModel: ViewModel {
    static func == (lhs: BottomBarItemViewModel, rhs: BottomBarItemViewModel) -> Bool {
        return lhs.title == rhs.title && lhs.image == rhs.image
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title.hashValue)
        hasher.combine(image.hashValue)
    }
    
    var title: String
    var image: UIImage?
    var enabled: Bool = true
    var callback: (() -> Void)?
}

class BottomBarItem: FEView<BottomBarItemConfiguration, BottomBarItemViewModel> {
    static let defaultheight: CGFloat = 72.0
    
    private lazy var imageContainerView: UIView = {
        let container = UIView()
        container.clipsToBounds = true
        container.backgroundColor = LightColors.primary
        return container
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: Asset.buy.image)
        imageView.tintColor = LightColors.Contrast.two
        return imageView
    }()
    
    private lazy var label: FELabel = {
        let label = FELabel()
        label.textAlignment = .center
        label.configure(with: .init(font: Fonts.Body.three, textColor: LightColors.Text.one))
        return label
    }()
    
    private lazy var tappableView: UIView = {
        return UIView()
    }()
    
    private var onTap: (() -> Void)?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(imageContainerView)
        
        imageContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.width.equalTo(ViewSizes.Common.defaultCommon.rawValue)
        }
        imageContainerView.layer.cornerRadius = CornerRadius.fullRadius.rawValue  * ViewSizes.Common.defaultCommon.rawValue
        
        imageContainerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Margins.medium.rawValue)
        }
        
        content.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(imageContainerView.snp.bottom).offset(Margins.small.rawValue)
            make.centerX.equalTo(imageContainerView.snp.centerX)
        }
        
        content.addSubview(tappableView)
        tappableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tappableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
    }
    
    override func configure(with config: BottomBarItemConfiguration?) {
        super.configure(with: config)
    }
    
    override func setup(with viewModel: BottomBarItemViewModel?) {
        guard let viewModel = viewModel else { return }
        
        imageView.image = viewModel.image
        label.setup(with: .text(viewModel.title))
        content.isUserInteractionEnabled = viewModel.enabled
        content.alpha = viewModel.enabled ? 1.0 : 0.5
        onTap = viewModel.callback
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        onTap?()
    }
}
