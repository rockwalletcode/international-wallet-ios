//
//  PaymentMethodsVIP.swift
//  breadwallet
//
//  Created by Rok on 12/12/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Foundation
import LinkKit

protocol PaymentMethodsViewActions: BaseViewActions, FetchViewActions, AssetViewActions {
    func getPayments(viewAction: PaymentMethodsModels.Get.ViewAction, completion: (() -> Void)?)
    func selectPaymentMethod(viewAction: PaymentMethodsModels.PaymentMethod.ViewAction)
    func getPlaidToken(viewAction: PaymentMethodsModels.Link.ViewAction)
    func setPaymentCard(viewAction: PaymentMethodsModels.SetPaymentCard.ViewAction)
    func achSuccessMessage(viewAction: PaymentMethodsModels.Get.ViewAction)
}

protocol PaymentMethodsActionResponses: BaseActionResponses, FetchActionResponses, AssetActionResponses {
    var achPaymentModel: CardSelectionViewModel? { get set }
    
    func presentPaymentCards(actionResponse: PaymentMethodsModels.PaymentCards.ActionResponse)
    func presentAch(actionResponse: PaymentMethodsModels.Get.ActionResponse)
    func presentPlaidToken(actionResponse: PaymentMethodsModels.Link.ActionResponse)
}

protocol PaymentMethodsResponseDisplays: BaseResponseDisplays, FetchResponseDisplays, AssetResponseDisplays {
    var plaidHandler: PlaidLinkKitHandler? { get set }
    
    func displayPaymentCards(responseDisplay: PaymentMethodsModels.PaymentCards.ResponseDisplay)
    func displayPlaidToken(responseDisplay: PaymentMethodsModels.Link.ResponseDisplay)
}

protocol PaymentMethodsDataStore: BaseDataStore, FetchDataStore, AssetDataStore {
    var selected: PaymentCard? { get set }
    var ach: PaymentCard? { get set }
    var cards: [PaymentCard] { get set }
    var paymentMethod: PaymentCard.PaymentType? { get set }
    var exchangeType: ExchangeType? { get }
}

extension Interactor where Self: PaymentMethodsViewActions,
                           Self.DataStore: PaymentMethodsDataStore,
                           Self.ActionResponses: PaymentMethodsActionResponses {
    func getPayments(viewAction: PaymentMethodsModels.Get.ViewAction, completion: (() -> Void)?) {
        var ach: PaymentCard?
        var cards: [PaymentCard] = []
        
        let worker = (dataStore?.exchangeType == .buyCard || dataStore?.exchangeType == .buyAch) ? PaymentCardsWorker() : SellPaymentCardsWorker()
        
        worker.execute(requestData: PaymentCardsRequestData()) { [weak self] result in
            switch result {
            case .success(let data):
                ach = data?.first(where: { $0.type == .ach })
                cards = data?.filter { $0.type == .card } ?? []
                
                // Card withdrawal only supports visa
                if self?.dataStore?.exchangeType == .sellCard {
                    cards = cards.filter { $0.scheme == .visa }
                }
                
                self?.dataStore?.cards = cards
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
            
            if viewAction.openCards == true {
                self?.presenter?.presentPaymentCards(actionResponse: .init(allPaymentCards: self?.dataStore?.cards ?? [],
                                                                           exchangeType: self?.dataStore?.exchangeType))
            } else {
                guard let paymentMethod = self?.dataStore?.paymentMethod else { return }
                
                switch paymentMethod {
                case .ach:
                    self?.dataStore?.ach = ach
                    self?.dataStore?.cards = []
                    
                    self?.setPaymentCard(viewAction: .init(card: ach, setAmount: viewAction.setAmount))
                    self?.presenter?.presentAch(actionResponse: .init(item: ach))
                    
                case .card:
                    var card = cards.contains(where: { $0.id == self?.dataStore?.selected?.id }) ? self?.dataStore?.selected : cards.first
                    self?.dataStore?.cards = cards
                    self?.dataStore?.ach = nil
                    
                    if self?.dataStore?.exchangeType == .sellCard {
                        card = cards.first(where: { $0.verifiedToSell == true })
                    }
                    
                    self?.setPaymentCard(viewAction: .init(card: card, setAmount: viewAction.setAmount))
                }
                
                completion?()
            }
        }
    }
    
    func selectPaymentMethod(viewAction: PaymentMethodsModels.PaymentMethod.ViewAction) {
        dataStore?.paymentMethod = viewAction.method
        
        getPayments(viewAction: .init(setAmount: false), completion: { [weak self] in
            let item = AssetModels.Item(type: self?.dataStore?.paymentMethod,
                                        achEnabled: UserManager.shared.profile?.kycAccessRights.hasAchAccess ?? false)
            self?.prepareCurrencies(viewAction: item)
            
            guard let supportedCurrencies = self?.dataStore?.supportedCurrencies, !supportedCurrencies.isEmpty else {
                self?.presenter?.presentError(actionResponse: .init(error: ExchangeErrors.selectAssets))
                return
            }
            
            let isSelectedCurencySupported = supportedCurrencies.contains(self?.dataStore?.amount?.currency.code.lowercased() ?? "")
            guard let currency = isSelectedCurencySupported ? self?.dataStore?.amount?.currency : self?.dataStore?.currencies.first else { return }
            self?.dataStore?.amount = .zero(currency)
            
            self?.setAmount(viewAction: .init(currency: currency.code, didFinish: true))
        })
    }
    
    func setPaymentCard(viewAction: PaymentMethodsModels.SetPaymentCard.ViewAction) {
        dataStore?.selected = viewAction.card
        
        guard viewAction.setAmount else { return }
        setAmount(viewAction: .init())
    }
    
    func getPlaidToken(viewAction: PaymentMethodsModels.Link.ViewAction) {
        guard dataStore?.ach == nil || dataStore?.ach?.status != .statusOk else { return }
        
        PlaidLinkTokenWorker().execute(requestData: PlaidLinkTokenRequestData(accountId: dataStore?.ach?.id)) { [weak self] result in
            switch result {
            case .success(let response):
                self?.getPublicPlaidToken(for: response?.linkToken)
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    private func getPublicPlaidToken(for token: String?) {
        guard let linkToken = token else { return }
        
        var linkConfiguration = LinkTokenConfiguration(token: linkToken) { [weak self] result in
            let publicToken = result.publicToken
            let mask = result.metadata.accounts.first?.mask
            self?.setPublicPlaidToken(publicToken, mask: mask)
        }
        
        linkConfiguration.onExit = { [weak self] exit in
            guard let data = self?.mapStructToDictionary(item: exit).description else { return }
            PlaidErrorWorker().execute(requestData: PlaidErrorRequestData(error: data))
        }
        
        linkConfiguration.onEvent = { [weak self] event in
            guard let data = self?.mapStructToDictionary(item: event).description else { return }
            PlaidEventWorker().execute(requestData: PlaidEventRequestData(event: data))
        }
        
        GoogleAnalytics.logEvent(GoogleAnalytics.OpenPlaid(configuration: String(describing: linkConfiguration)))
        
        let result = Plaid.create(linkConfiguration)
        switch result {
        case .failure(let error):
            presenter?.presentError(actionResponse: .init(error: error))
            
        case .success(let handler):
            presenter?.presentPlaidToken(actionResponse: .init(plaidHandler: handler))
            
        }
    }
    
    private func setPublicPlaidToken(_ token: String?, mask: String?) {
        PlaidPublicTokenWorker().execute(requestData: PlaidPublicTokenRequestData(publicToken: token,
                                                                                  mask: mask,
                                                                                  accountId: dataStore?.ach?.id)) { [weak self] result in
            switch result {
            case .success:
                self?.getPayments(viewAction: .init(), completion: { [weak self] in
                    self?.achSuccessMessage(viewAction: .init())
                })
                
            case .failure(let error):
                self?.presenter?.presentError(actionResponse: .init(error: error))
            }
        }
    }
    
    private func mapStructToDictionary<T>(item: T) -> [String: Any] {
        let dictionary = Dictionary(uniqueKeysWithValues:
            Mirror(reflecting: item).children.lazy.map({ (label: String?, value: Any) in
                if let label = label {
                    return (label, value)
                } else {
                    return (Date().timeIntervalSince1970.description, value)
                }
            })
        )
        return dictionary.compactMapValues { $0 }
    }
}

extension Presenter where Self: PaymentMethodsActionResponses,
                          Self.ResponseDisplays: PaymentMethodsResponseDisplays {
    func presentPaymentCards(actionResponse: PaymentMethodsModels.PaymentCards.ActionResponse) {
        viewController?.displayPaymentCards(responseDisplay: .init(allPaymentCards: actionResponse.allPaymentCards,
                                                                   exchangeType: actionResponse.exchangeType))
    }
    
    func presentAch(actionResponse: PaymentMethodsModels.Get.ActionResponse) {
        guard let item = actionResponse.item else {
            achPaymentModel = .init(title: .text(L10n.Sell.achWithdrawal),
                                    subtitle: .text(L10n.Buy.linkBankAccount),
                                    userInteractionEnabled: true)
            return
        }
        
        switch item.status {
        case .statusOk:
            achPaymentModel = .init(title: .text(L10n.Buy.transferFromBank),
                                    subtitle: nil,
                                    logo: .image(Asset.bank.image),
                                    cardNumber: .text(item.displayName),
                                    userInteractionEnabled: false)
            
        default:
            achPaymentModel = .init(title: .text(L10n.Sell.achWithdrawal),
                                    subtitle: .text(L10n.Buy.relinkBankAccount),
                                    userInteractionEnabled: true)
        }
    }
    
    func presentPlaidToken(actionResponse: PaymentMethodsModels.Link.ActionResponse) {
        viewController?.displayPlaidToken(responseDisplay: .init(plaidHandler: actionResponse.plaidHandler))
    }
}

extension Controller where Self: PaymentMethodsResponseDisplays {
    func displayPaymentCards(responseDisplay: PaymentMethodsModels.PaymentCards.ResponseDisplay) {
        view.endEditing(true)
        
        let cards = responseDisplay.allPaymentCards
        let from = responseDisplay.exchangeType
        
        (coordinator as? ExchangeCoordinator)?.showCardSelector(cards: cards, from: from) { [weak self] selectedCard in
            (self?.interactor as? (any PaymentMethodsViewActions))?.setPaymentCard(viewAction: .init(card: selectedCard, setAmount: true))
        }
    }
    
    func displayPlaidToken(responseDisplay: PaymentMethodsModels.Link.ResponseDisplay) {
        plaidHandler = responseDisplay.plaidHandler
        plaidHandler?.open(presentUsing: .viewController(self))
    }
}
