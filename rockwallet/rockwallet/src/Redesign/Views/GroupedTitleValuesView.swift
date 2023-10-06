// 
//  GroupedTitleValueView.swift
//  rockwallet
//
//  Created by Dino Gačević on 06/10/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct GroupedTitleValuesViewModel: ViewModel {
    var models: [TitleValueViewModel]
}

struct GroupedTitleValuesViewConfiguration: Configurable {
    var titleValueConfigurations: [TitleValueConfiguration]? = [Presets.TitleValue.common]
}

class GroupedTitleValuesView: FEView<GroupedTitleValuesViewConfiguration, GroupedTitleValuesViewModel> {
    
    private lazy var roundedView: RoundedView = {
        let roundedView = RoundedView()
        roundedView.cornerRadius = CornerRadius.common.rawValue
        roundedView.backgroundColor = Colors.Background.cards
        return roundedView
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Margins.medium.rawValue
        return stack
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(roundedView)
        roundedView.snp.makeConstraints { make in
            make.edges.equalTo(snp.margins)
        }
        
        roundedView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Margins.large.rawValue)
        }
    }
    
    override func setup(with viewModel: GroupedTitleValuesViewModel?) {
        super.setup(with: viewModel)
        
        guard let models = viewModel?.models else { return }
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        models.enumerated().forEach { index, model in
            let titleValueView = TitleValueView()
            titleValueView.configure(with: Presets.TitleValue.common)
            titleValueView.setup(with: model)
            stack.addArrangedSubview(titleValueView)
            
            guard index < models.count - 1 else { return }
            let separatorView = UIView()
            separatorView.backgroundColor = Colors.Outline.one
            separatorView.snp.makeConstraints { make in
                make.height.equalTo(BorderWidth.minimum.rawValue)
            }
            stack.addArrangedSubview(separatorView)
        }
    }
}
