// 
//  LimitsPopupView.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 20.1.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct LimitsPopupConfiguration: Configurable {
    var title: LabelConfiguration = LabelConfiguration(font: Fonts.Title.six, textColor: LightColors.Text.three, textAlignment: .center)
    var daily: TitleValueConfiguration = Presets.TitleValue.common
    var weekly: TitleValueConfiguration = Presets.TitleValue.common
    var monthly: TitleValueConfiguration = Presets.TitleValue.common
}

struct LimitsPopupViewModel: ViewModel {
    var title: LabelViewModel
    var daily: TitleValueViewModel
    var weekly: TitleValueViewModel
    var monthly: TitleValueViewModel
}

class LimitsPopupView: FEView<LimitsPopupConfiguration, LimitsPopupViewModel> {
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.large.rawValue
        return view
    }()
    
    private lazy var titleView: FELabel = {
        let label = FELabel()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var dailyView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var weeklyView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var monthlyView: TitleValueView = {
        let view = TitleValueView()
        return view
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.Outline.one
        return view
    }()
    
    private lazy var lineViewDaily: UIView = {
        let view = UIView()
        view.backgroundColor = LightColors.Outline.one
        return view
    }()
    
    private lazy var lineViewWeekly: UIView = {
        let view = UIView()
        view.backgroundColor = LightColors.Outline.one
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mainStack.addArrangedSubview(titleView)
        
        mainStack.addArrangedSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.minimum.rawValue)
        }
        
        mainStack.addArrangedSubview(dailyView)
        dailyView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.extraSmall.rawValue)
        }
        
        mainStack.addArrangedSubview(lineViewDaily)
        lineViewDaily.snp.makeConstraints { make in
            make.height.equalTo(lineView.snp.height)
        }
        
        mainStack.addArrangedSubview(weeklyView)
        weeklyView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.extraSmall.rawValue)
        }
        
        mainStack.addArrangedSubview(lineViewWeekly)
        lineViewWeekly.snp.makeConstraints { make in
            make.height.equalTo(lineView.snp.height)
        }
        
        mainStack.addArrangedSubview(monthlyView)
        monthlyView.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.extraSmall.rawValue)
        }
    }
    
    override func configure(with config: LimitsPopupConfiguration?) {
        super.configure(with: config)
        
        titleView.configure(with: config?.title)
        dailyView.configure(with: config?.daily)
        weeklyView.configure(with: config?.weekly)
        monthlyView.configure(with: config?.monthly)
    }
    
    override func setup(with viewModel: LimitsPopupViewModel?) {
        super.setup(with: viewModel)
        
        titleView.setup(with: viewModel?.title)
        
        dailyView.setup(with: viewModel?.daily)
        dailyView.isHidden = viewModel?.daily.value == nil
        
        weeklyView.setup(with: viewModel?.weekly)
        weeklyView.isHidden = viewModel?.weekly.value == nil
        
        monthlyView.setup(with: viewModel?.monthly)
        monthlyView.isHidden = viewModel?.monthly.value == nil
    }
}
