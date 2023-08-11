// 
//  FELabel.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct LabelConfiguration: TextConfigurable {
    var font: UIFont = Fonts.Body.three
    var textColor: UIColor? = LightColors.primary
    var textAlignment: NSTextAlignment = .left
    var numberOfLines: Int = 0
    var lineBreakMode: NSLineBreakMode = .byWordWrapping
    var isUserInteractionEnabled: Bool = false
}

enum LabelViewModel: ViewModel {
    case text(String?)
    case attributedText(NSAttributedString?)
}

class FELabel: UILabel, ViewProtocol {
    var viewModel: LabelViewModel?
    var config: LabelConfiguration?
    var didTapLink: (() -> Void)?
    
    func configure(with config: LabelConfiguration?) {
        guard let config = config else { return }
        
        self.config = config
        textAlignment = config.textAlignment
        textColor = config.textColor
        numberOfLines = config.numberOfLines
        lineBreakMode = config.lineBreakMode
        font = config.font
        textColor = config.textColor
        isUserInteractionEnabled = config.isUserInteractionEnabled
    }
    
    func setup(with viewModel: LabelViewModel?) {
        guard let viewModel = viewModel else { return }

        self.viewModel = viewModel
        switch viewModel {
        case .text(let value):
            text = value
            
        case .attributedText(let value):
            attributedText = value
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
            addGestureRecognizer(tapGesture)
        }
        
        sizeToFit()
        needsUpdateConstraints()
    }
    
    @objc private func viewTapped() {
        didTapLink?()
    }
}
