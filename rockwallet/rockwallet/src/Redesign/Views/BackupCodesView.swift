// 
//  BackupCodesView.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 24.3.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct BackupCodesViewConfiguration: Configurable {
    var backupCode: LabelConfiguration = .init(font: Fonts.Title.five,
                                               textColor: Colors.Text.three,
                                               textAlignment: .center)
}

struct BackupCodesViewModel: ViewModel {
    var backupCodes: [LabelViewModel] = []
}

class BackupCodesView: FEView<BackupCodesViewConfiguration, BackupCodesViewModel> {
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = Margins.small.rawValue
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setup(with viewModel: BackupCodesViewModel?) {
        super.setup(with: viewModel)
        
        setupBackupCodesView()
    }
    
    private func setupBackupCodesView() {
        guard let viewModel = viewModel, let config = config else { return }
        
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for model in viewModel.backupCodes {
            let backupCodeLabel = FELabel()
            backupCodeLabel.configure(with: config.backupCode)
            backupCodeLabel.setup(with: model)
            
            stack.addArrangedSubview(backupCodeLabel)
        }
        
        stack.layoutIfNeeded()
    }
}
