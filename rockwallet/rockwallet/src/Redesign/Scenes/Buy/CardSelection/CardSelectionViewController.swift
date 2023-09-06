// 
//  CardSelectionViewController.swift
//  breadwallet
//
//  Created by Rok on 02/08/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

extension Scenes {
    static let CardSelection = CardSelectionViewController.self
}

class CardSelectionViewController: ItemSelectionViewController {
    override var sceneTitle: String? { return L10n.Buy.paymentMethods }
    override var isSearchEnabled: Bool { return false }
    override var isModalDismissableEnabled: Bool { return false }
    
    var paymentCardDeleted: (() -> Void)?
    
    override func setupSubviews() {
        super.setupSubviews()
        
        tableView.separatorStyle = .none
        
        itemDeleted = { [weak self] in
            self?.paymentCardDeleted?()
        }
    }
    
    override func tableView(_ tableView: UITableView, itemCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<CardSelectionView> = tableView.dequeueReusableCell(for: indexPath),
              let model = dataSource?.itemIdentifier(for: indexPath) as? PaymentCard
        else {
            return UITableViewCell()
        }
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: .init(title: nil,
                                   subtitle: nil,
                                   logo: model.displayImage,
                                   cardNumber: .text(model.displayName),
                                   expiration: .text(CardDetailsFormatter.formatExpirationDate(month: model.expiryMonth, year: model.expiryYear)),
                                   errorMessage: getCardErrorMessage(model: model)))
            
            view.moreButtonCallback = { [weak self] in
                self?.interactor?.showActionSheetRemovePayment(viewAction: .init(instrumentId: model.id,
                                                                                 last4: model.last4))
            }
            
            view.errorLinkCallback = { [weak self] in                
                if model.paymentMethodStatus.isProblematic {
                    self?.coordinator?.showPaymentMethodSupport()
                } else if model.verifiedToSell == false && model.scheme == .visa {
                    Store.trigger(name: .showBuy)
                } else {
                    return
                }
            }
            
            view.setupCustomMargins(top: .zero, leading: .large, bottom: .zero, trailing: .large)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, addItemCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: WrapperTableViewCell<CardSelectionView> = tableView.dequeueReusableCell(for: indexPath) else {
            return UITableViewCell()
        }
        
        let model = dataSource?.itemIdentifier(for: indexPath) as? PaymentCard
        
        cell.setup { view in
            view.configure(with: .init())
            view.setup(with: .init(title: .text(L10n.Buy.card),
                                   subtitle: nil,
                                   logo: .image(Asset.card.image),
                                   cardNumber: .text(L10n.Buy.addDebitCreditCard),
                                   expiration: nil,
                                   userInteractionEnabled: true))
            
            view.setupCustomMargins(top: .zero, leading: .large, bottom: .zero, trailing: .large)
            
            view.didTapSelectCard = { [weak self] in
                guard let model else {
                    let fromCardWithdrawal = self?.dataStore?.fromCardWithdrawal
                    self?.coordinator?.open(scene: Scenes.AddCard) { vc in
                        vc.dataStore?.fromCardWithdrawal = fromCardWithdrawal ?? false
                    }
                    return
                }

                guard self?.dataStore?.isSelectingEnabled == true, !model.paymentMethodStatus.isProblematic else { return }
                self?.itemSelected?(model)
            }
        }
        
        return cell
    }
    
    // MARK: - Additional Helpers
    
    private func getCardErrorMessage(model: PaymentCard) -> LabelViewModel? {
        if model.paymentMethodStatus.isProblematic {
            let unavailableText = model.paymentMethodStatus.unavailableText
            return .attributedText(unavailableText)
        } else if model.verifiedToSell == false && model.scheme == .visa {
            let unverifiedCardText = NSMutableAttributedString(string: L10n.ErrorMessages.cardRequiresPurchase)
            
            let maxRange = NSRange(location: 0, length: unverifiedCardText.mutableString.length)
            unverifiedCardText.addAttribute(.font, value: Fonts.Body.three, range: maxRange)
            unverifiedCardText.addAttribute(.foregroundColor, value: Colors.Error.one, range: maxRange)
            
            let boldRange = unverifiedCardText.mutableString.range(of: L10n.Buy.buyWithCard.capitalizingFirstLetter())
            unverifiedCardText.addAttribute(.font, value: Fonts.Subtitle.three, range: boldRange)
            unverifiedCardText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: boldRange)
            
            return .attributedText(unverifiedCardText)
        } else {
            return nil
        }
    }
}
