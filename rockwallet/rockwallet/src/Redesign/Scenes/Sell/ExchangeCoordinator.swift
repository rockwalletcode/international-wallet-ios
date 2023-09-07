//
//  ExchangeCoordinator.swift
//  breadwallet
//
//  Created by Rok on 06/12/2022.
//
//

import Frames
import UIKit
import WalletKit

class ExchangeCoordinator: BaseCoordinator, SellRoutes, BuyRoutes, SwapRoutes, OrderPreviewRoutes, BillingAddressRoutes, AssetSelectionDisplayable {
    func showOrderPreview(type: PreviewType? = .buy,
                          coreSystem: CoreSystem?,
                          keyStore: KeyStore?,
                          to: Amount?,
                          from: Decimal?,
                          fromFeeBasis: TransferFeeBasis? = nil,
                          card: PaymentCard?,
                          quote: Quote?,
                          availablePayments: [PaymentCard.PaymentType]?,
                          createTransactionModel: CreateTransactionModels.Transaction.ViewAction? = nil) {
        open(scene: Scenes.OrderPreview) { vc in
            vc.dataStore?.type = type
            vc.dataStore?.coreSystem = coreSystem
            vc.dataStore?.keyStore = keyStore
            vc.dataStore?.from = from
            vc.dataStore?.fromFeeBasis = fromFeeBasis
            vc.dataStore?.to = to
            vc.dataStore?.card = card
            vc.dataStore?.quote = quote
            vc.dataStore?.availablePayments = availablePayments
            vc.dataStore?.createTransactionModel = createTransactionModel
        }
    }
    
    func showTermsAndConditions(url: URL) {
        let webViewController = SimpleWebViewController(url: url)
        webViewController.setup(with: .init(title: L10n.About.terms))
        let navController = RootNavigationController(rootViewController: webViewController)
        webViewController.setAsNonDismissableModal()
        
        navigationController.present(navController, animated: true)
    }
    
    func showTimeout(type: PreviewType?) {
        open(scene: Scenes.Timeout) { vc in
            vc.navigationItem.hidesBackButton = true
            
            vc.didTapMainButton = { [weak self] in
                self?.popToRoot()
            }
        }
    }
    
    func showThreeDSecure(url: URL) {
        let webViewController = SimpleWebViewController(url: url)
        let navController = RootNavigationController(rootViewController: webViewController)
        webViewController.setAsNonDismissableModal()
        webViewController.setup(with: .init(title: L10n.Buy._3DSecure))
        webViewController.didDismiss = { [weak self] in
            (self?.navigationController.topViewController as? DataPresentable)?.prepareData()
            navController.dismiss(animated: true)
        }
        
        navigationController.present(navController, animated: true)
    }
    
    func showSwapInfo(from: String, to: String, exchangeId: String) {
        open(scene: Scenes.SwapInfo) { vc in
            vc.navigationItem.hidesBackButton = true
            vc.dataStore?.id = exchangeId
            vc.dataStore?.item = (from: from, to: to)
            
            vc.didTapMainButton = {
                vc.coordinator?.dismissFlow()
            }
            
            vc.didTapSecondaryButton = {
                (vc.coordinator as? ExchangeCoordinator)?.showExchangeDetails(with: vc.dataStore?.id, type: .swap)
            }
        }
    }
    
    func showBillingAddress(_ store: AddCardStore) {
        open(scene: Scenes.BillingAddress) { vc in
            vc.dataStore?.cardNumber = store.cardNumber
            vc.dataStore?.cvv = store.cardCVV
            vc.dataStore?.expYear = store.cardExpDateYear
            vc.dataStore?.expMonth = store.cardExpDateMonth
        }
    }
    
    func showCardSelector(cards: [PaymentCard], from exchangeType: ExchangeType? = nil, selected: ((PaymentCard?) -> Void)?) {
        guard !cards.isEmpty else {
            open(scene: Scenes.AddCard) { vc in
                vc.dataStore?.fromCardWithdrawal = exchangeType == .sellCard
            }
            return
        }
        
        open(scene: Scenes.CardSelection,
                    presentationStyle: .currentContext) { [weak self] vc in
            vc.dataStore?.isAddingEnabled = true
            vc.dataStore?.isSelectingEnabled = exchangeType == .buyCard || exchangeType == .sellCard
            vc.dataStore?.fromCardWithdrawal = exchangeType == .sellCard
            vc.dataStore?.items = cards
            let backButtonVisible = self?.navigationController.children.last is BillingAddressViewController
            vc.navigationItem.hidesBackButton = backButtonVisible
            
            vc.itemSelected = { item in
                guard let item = item as? PaymentCard else { return }
                if exchangeType == .sellCard, item.verifiedToSell == false {
                    return
                }
                selected?(item)
                
                self?.popToRoot()
            }
            
            vc.paymentCardDeleted = {
                selected?(nil)
            }
        }
    }
    
    func showCountrySelector(countries: [Country], selected: ((Country?) -> Void)?) {
        open(scene: Scenes.ItemSelection,
             presentationStyle: .formSheet) { [weak self] vc in
            vc.dataStore?.items = countries
            vc.dataStore?.sceneTitle = L10n.Account.selectCountry
            vc.itemSelected = { item in
                selected?(item as? Country)
                self?.popViewController()
            }
        }
    }
    
    func showStateSelector(states: [Place], selected: ((Place?) -> Void)?) {
        openModally(coordinator: ExchangeCoordinator.self,
                    scene: Scenes.ItemSelection,
                    presentationStyle: .formSheet) { vc in
            vc?.dataStore?.items = states
            vc?.dataStore?.sceneTitle = L10n.Account.selectState
            vc?.itemSelected = { [weak self] item in
                selected?(item as? Place)
                self?.popViewController()
            }
        }
    }
    
    func showManageAssets(coreSystem: CoreSystem?) {
        guard let coreSystem = coreSystem, let assetCollection = coreSystem.assetCollection else { return }
        
        let vc = ManageWalletsViewController(assetCollection: assetCollection, coreSystem: coreSystem)
        let nc = RootNavigationController(rootViewController: vc)
        navigationController.present(nc, animated: true)
    }
    
    func showPaymentsActionSheet(okButtonTitle: String,
                                 cancelButtonTitle: String,
                                 handler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: okButtonTitle, style: .destructive, handler: { _ in
            handler()
        }))
        alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil))
        
        navigationController.present(alert, animated: true, completion: nil)
    }
}

extension ExchangeCoordinator {
    func showMonthYearPicker(model: [[String]]) {
        guard let viewController = navigationController.children.last(where: { $0 is AddCardViewController }) as? AddCardViewController else { return }
        
        PickerViewViewController.show(on: viewController,
                                      sourceView: viewController.view,
                                      title: nil,
                                      values: model,
                                      selection: .init(primaryRow: 0, secondaryRow: 0)) { _, _, index, _ in
            viewController.interactor?.cardInfoSet(viewAction: .init(expirationDateIndex: index))
        }
    }
}
