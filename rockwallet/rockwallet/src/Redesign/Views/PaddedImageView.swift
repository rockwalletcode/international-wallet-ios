// 
//  PaddedImageView.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 18/04/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct PaddedImageConfiguration: Configurable {
    var background: BackgroundConfiguration = .init(backgroundColor: .clear,
                                                    border: .init(tintColor: LightColors.Outline.one,
                                                                  borderWidth: 1,
                                                                  cornerRadius: CornerRadius.common))
}

struct PaddedImageViewModel: ViewModel {
    var image: ImageViewModel?
}

class PaddedImageView: FEView<PaddedImageConfiguration, PaddedImageViewModel> {
    private lazy var imageView: FEImageView = {
        let view = FEImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        imageView.setupCustomMargins(all: Margins.extraLarge)
        
        content.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(UIScreen.main.bounds.width * 0.5)
            make.edges.equalToSuperview()
        }
    }
    
    override func configure(with config: PaddedImageConfiguration?) {
        super.configure(with: config)
        
        configure(background: config?.background)
    }
    
    override func setup(with viewModel: PaddedImageViewModel?) {
        super.setup(with: viewModel)
        
        imageView.setup(with: viewModel?.image)
    }
}
