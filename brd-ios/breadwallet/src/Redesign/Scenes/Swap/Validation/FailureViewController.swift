// 
//  FailureViewController.swift
//  breadwallet
//
//  Created by Rok on 12/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let Failure = FailureViewController.self
}

class FailureViewController: BaseInfoViewController {
    var veriffKYCManager: VeriffKYCManager?
    
    var buttonTitle: String?
    var availablePayments: [PaymentCard.PaymentType]?
    var reason: BaseInfoModels.FailureReason? {
        didSet {
            prepareData()
        }
    }
    
    override var imageName: String? { return reason?.iconName }
    override var titleText: String? { return reason?.title }
    override var descriptionText: String? { return reason?.description }
    override var buttonViewModels: [ButtonViewModel] {
        let containsDebit = availablePayments?.contains(.card) == true
        let containsBankAccount = availablePayments?.contains(.ach) == true
        if containsDebit || containsBankAccount {
            buttonTitle = containsDebit ? L10n.PaymentConfirmation.tryWithDebit : L10n.PaymentConfirmation.tryWithAch
        }
        
        return [
            .init(title: buttonTitle != nil ? buttonTitle : reason?.firstButtonTitle) { [weak self] in
                self?.shouldDismiss = true
                
                self?.didTapMainButton?()
                
            },
            .init(title: reason?.secondButtonTitle, isUnderlined: true, callback: { [weak self] in
                self?.shouldDismiss = true
                
                self?.didTapSecondaryButton?()
            })
        ]
    }
    
    func handleBiometricStatus(approved: Bool) {
        LoadingView.hideIfNeeded()
        
        guard approved else {
            coordinator?.showFailure(reason: .limitsAuthentication)
            return
        }
        
        coordinator?.showSuccess(reason: .limitsAuthentication)
    }
    
    override var buttonConfigurations: [ButtonConfiguration] {
        return [Presets.Button.primary,
                Presets.Button.noBorders]
    }
    
    override func tableView(_ tableView: UITableView, descriptionLabelCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Align text to left for retry bullet points text
        guard reason == .documentVerificationRetry else {
            return super.tableView(tableView, descriptionLabelCellForRowAt: indexPath)
        }
        
        guard let cell: WrapperTableViewCell<FELabel> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? LabelViewModel else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        cell.setup { view in
            view.configure(with: .init(font: Fonts.Body.two, textColor: LightColors.Text.two, textAlignment: .left))
            view.setup(with: model)
            view.setupCustomMargins(vertical: .extraHuge, horizontal: .extraHuge)
            view.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(Margins.extraHuge.rawValue)
            }
        }
        
        return cell
    }
}
