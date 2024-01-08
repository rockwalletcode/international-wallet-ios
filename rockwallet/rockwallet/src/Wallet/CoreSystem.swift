//
//  CoreSystem.swift
//  breadwallet
//
//  Created by Ehsan Rezaie on 2019-04-16.
//  Copyright © 2019 Breadwinner AG. All rights reserved.
//

import WalletKit
import UIKit

class CoreSystem: Subscriber {    
    private var system: System?
    private let queue = DispatchQueue(label: (Bundle.main.bundleIdentifier ?? "") + ".CoreSystem", qos: .utility)
    private let listenerQueue = DispatchQueue(label: (Bundle.main.bundleIdentifier ?? "") + ".CoreSystem.listener", qos: .utility)
    private let keyStore: KeyStore
    private var systemClient: SystemClient?
    fileprivate var btcWalletCreationCallback: (() -> Void)?
    
    // MARK: Wallets + Currencies
    
    private(set) var assetCollection: AssetCollection?
    /// All supported currencies
    private(set) var currencies = [CurrencyId: Currency]()
    /// Active wallets
    private(set) var wallets = [CurrencyId: Wallet]()
    // Service that manages sharing data with widget extension
    private(set) var widgetDataShareService: WidgetDataShareService
    
    func wallet(for currency: Currency) -> Wallet? {
        return wallets[currency.uid]
    }
    
    private var createWalletCallback: ((Wallet?) -> Void)?
    
    var account: Account? { return system?.account }
    
    // MARK: Lifecycle
    
    init(keyStore: KeyStore) {
        self.keyStore = keyStore
        self.widgetDataShareService = DefaultWidgetDataShareService()
        Store.subscribe(self, name: .optInSegWit) { [weak self] _ in
            guard let self = self else { return }
            self.queue.async {
                guard let btc = Currencies.shared.btc,
                      let btcWalletManager = self.wallet(for: btc)?.manager else { return }
                btcWalletManager.addressScheme = .btcSegwit
                print("[SYS] Bitcoin SegWit address scheme enabled")
            }
        }
        
        Reachability.addDidChangeCallback { [weak self] isReachable in
            guard let self = self, let system = self.system else { return }
            system.setNetworkReachable(isReachable)
            if isReachable {
                self.connect()
            } else {
                self.pause()
            }
        }
        
        Store.subscribe(self, name: .createAccount(nil, nil)) { [weak self] trigger in
            guard let self = self else { return }
            if case let .createAccount(currency, callback) = trigger {
                if let currency = currency, let callback = callback {
                    self.createAccount(forCurrency: currency, callback: callback)
                }
            }
        }
        
        Store.subscribe(self, name: .sendXPubs) { [weak self] _ in
            guard let account = self?.account else { return }
            
            self?.sendXPubs()
        }
    }
    
    /// Creates and configures the System with the Account and BDB authentication token.
    func create(account: Account, btcWalletCreationCallback: @escaping () -> Void, completion: @escaping () -> Void) {
        self.btcWalletCreationCallback = btcWalletCreationCallback
        
        guard let kvStore = Backend.kvStore, let sessionToken = UserDefaults.sessionToken else { return }
        
        print("[SYS] create | account timestamp: \(account.timestamp)")
        assert(self.system == nil)
        
        systemClient = BlocksetSystemClient(bdbBaseURL: "https://\(Constant.bdbHost)",
                                            bdbDataTaskFunc: { session, request, completion -> URLSessionDataTask in
            var req = request
            req.decorate()
            req.authorize(withToken: sessionToken)
            
            //TODO:CRYPTO does not handle 401, other headers, redirects
            return session.dataTask(with: req, completionHandler: completion)
        }, apiBaseURL: "https://\(Constant.backendHost)", apiDataTaskFunc: { _, req, completion -> URLSessionDataTask in
            return Backend.apiClient.dataTaskWithRequest(req,
                                                         authenticated: Backend.isConnected,
                                                         retryCount: 0,
                                                         responseQueue: self.queue,
                                                         handler: completion)
        })
        
        try? FileManager.default.createDirectory(atPath: Constant.coreDataDirURL.path, withIntermediateDirectories: true, attributes: nil)
        
        getCurrencyMetaData(kvStore: kvStore, client: systemClient, account: account, completion: completion)
    }
    
    /// Gathers xpubs or receive addresses from all wallets and sends them
    func sendXPubs() {
        guard UserManager.shared.profile != nil else { return }
        
        let wallets = self.wallets
        if wallets.isEmpty {
            return
        }
        
        var xPubList: [String: xPubs] = [:]
        let xPubNetworks: Set<NetworkType> = [NetworkType.btc, NetworkType.bsv, NetworkType.bch, NetworkType.ltc, NetworkType.doge]
        var addressesList: [String: String] = [:]
        
        // Collect xPubs and receive addresses
        wallets.values
            .forEach { wallet in
                let network =  wallet.currency.network.uids
                
                if xPubNetworks.contains(wallet.currency.network.type ) {
                    let receiveXpub = keyStore.getXPubFromAccount(code: wallet.currency.code, isChange: false)
                    let changeXpub = keyStore.getXPubFromAccount(code: wallet.currency.code, isChange: true)
                    xPubList[network] = xPubs(receiver: receiveXpub, change: changeXpub)
                } else {
                    addressesList[network] = wallet.receiveAddress
                }
            }
        
        var addresses: [String: Any] = [:]
        var xpubs: [String: Any] = [:]
        
        var sortedAddresses: String?
        var sortedXpubs: String?
        
        if !xPubList.isEmpty {
            for (_, xpub) in xPubList.enumerated() {
                xpubs[xpub.key] = [
                    "change": xpub.value.change,
                    "receive": xpub.value.receiver
                ]
                
                sortedXpubs = xpubs.sorted(by: { $0.key < $1.key }).map { "\($0.key):\(xpub.value.receiver)\(xpub.value.change)" }.joined(separator: ",")
            }
        }
        
        if !addressesList.isEmpty {
            for(_, address) in addressesList.enumerated() {
                addresses[address.key] = address.value
            }
            
            sortedAddresses = addresses.sorted(by: { $0.key < $1.key }).map { "\($0.key):\($0.value)" }.joined(separator: ",")
        }
        
        let data = PostAddressesRequestData(addresses: addresses, xpubs: xpubs, sortedXpubs: sortedXpubs, sortedAddresses: sortedAddresses)
        PostAddressesWorker().execute(requestData: data) { result in
            switch result {
            case .success:
                print("Success")
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getCurrencyMetaData(kvStore: BRReplicatedKVStore, client: SystemClient? = nil, account: Account, completion: @escaping () -> Void) {
        Backend.apiClient.getCurrencyMetaData(type: .fiatCurrencies) { _ in }
        Backend.apiClient.getCurrencyMetaData(type: .currencies) { currencyMetaData in
            self.queue.async {
                self.assetCollection = AssetCollection(kvStore: kvStore,
                                                       allTokens: currencyMetaData,
                                                       changeHandler: self.updateWalletStates)
                if let chosenClient = client ?? self.systemClient {
                    self.system = System.create(client: chosenClient,
                                                listener: self,
                                                account: account,
                                                onMainnet: !E.isTestnet,
                                                path: Constant.coreDataDirURL.path,
                                                listenerQueue: self.listenerQueue)
                }
                
                if let system = self.system {
                    System.wipeAll(atPath: Constant.coreDataDirURL.path, except: [system])
                }
                
                self.system?.configure()
                
                completion()
            }
        }
    }
    
    func refreshWallet(completion: @escaping () -> Void) {
        guard let kvStore = Backend.kvStore,
              let account = system?.account else {
            completion()
            return
        }
        
        Backend.apiClient.updateBundles { [weak self] _ in
            self?.getCurrencyMetaData(kvStore: kvStore,
                                      account: account, completion: {
                DispatchQueue.main.async {
                    completion()
                }
            })
        }
    }
    
    /// Connects all active wallet managers. Used on foreground and when reachability is restored.
    func connect() {
        queue.async {
            print("[SYS] connect")
            guard let system = self.system else { return }
            system.managers
                .filter { self.isWalletManagerNeeded($0) }
                .forEach { $0.connect(using: $0.customPeer) }
        }
    }
    
    func resume() {
        queue.async {
            print("[SYS] resume")
            guard let system = self.system else { return }
            system.resume()
        }
    }
    
    /// Disconnects all wallet managers. Used on background and when reachability is lost.
    func pause() {
        queue.async {
            print("[SYS] pause")
            guard let system = self.system else { return }
            system.pause()
        }
    }
    
    /// Shutdown the system and release resources. Used for account removal.
    func shutdown(completion: (() -> Void)?) {
        queue.async {
            print("[SYS] shutdown / wipe")
            guard let system = self.system else { return }
            
            System.wipe(system: system)
            
            self.wallets.removeAll()
            self.currencies.removeAll()
            self.system = nil
            
            completion?()
        }
    }
    
    /// Fetch network fees from backend
    func updateFees(completion: (() -> Void)? = nil) {
        queue.async {
            guard let system = self.system else { return }
            system.updateNetworkFees { result in
                switch result {
                case .success(let networks):
                    print("[SYS] Fees: updated fees for \(networks.map { $0.name })")
                case .failure(let error):
                    print("[SYS] Fees: failed to update with error: \(error)")
                }
                
                completion?()
            }
        }
    }
    
    /// Re-sync blockchain from specified depth
    func rescan(walletManager: WalletManager, fromDepth depth: WalletManagerSyncDepth) {
        queue.async {
            guard walletManager.isConnected else { return }
            walletManager.syncToDepth(depth: depth)
            DispatchQueue.main.async {
                walletManager.network.currencies
                    .compactMap { self.currencies[$0.uid] }
                    .forEach { Store.perform(action: WalletChange($0).setIsRescanning(true)) }
            }
        }
    }
    
    func walletIsInitialized(_ wallet: Wallet) -> Bool {
        guard let account = system?.account else { return false }
        return system?.accountIsInitialized(account, onNetwork: wallet.currency.network) ?? false
    }
    
    // MARK: - Core Wallet Management
    
    /// Adds Currency models for all currencies supported by the Network and enabled in the asset collection.
    private func addCurrencies(for network: Network) {
        guard let assetCollection = assetCollection else { return }
        for coreCurrency in network.currencies {
            guard currencies[coreCurrency.uid] == nil else { return }
            guard let metaData = assetCollection.allAssets[coreCurrency.uid] else {
                print("[SYS] unknown currency omitted: \(network.currency.code) / \(coreCurrency.uid)")
                continue
            }
            
            guard let units = network.unitsFor(currency: coreCurrency),
                  let baseUnit = network.baseUnitFor(currency: coreCurrency),
                  let defaultUnit = network.defaultUnitFor(currency: coreCurrency),
                  let currency = Currency(core: coreCurrency,
                                          network: network,
                                          metaData: metaData,
                                          units: units,
                                          baseUnit: baseUnit,
                                          defaultUnit: defaultUnit) else {
                assertionFailure("unable to create view model for \(coreCurrency.code)")
                continue
            }
            currencies[coreCurrency.uid] = currency
        }
        print("[SYS] \(network) currencies: \(network.currencies.map { $0.code }.joined(separator: ","))")
    }
    
    /// Creates a wallet manager for the network. Wallets are added asynchronously by Core for all network currencies.
    private func setupWalletManager(for network: Network) {
        guard let system = system, let assetCollection = assetCollection else { return }
        guard let currency = currencies[network.currency.uid] else {
            print("[SYS] \(network) wallet manager not created. \(network.currency.uid) not supported.")
            return
        }
        
        // networks tokens for which wallets are needed
        let requiredTokens = network.currencies.filter { assetCollection.isEnabled($0.uid) }
        
        var addressScheme: AddressScheme
        if currency.isBitcoin {
            addressScheme = UserDefaults.hasOptedInSegwit ? .btcSegwit : .btcLegacy
        } else {
            addressScheme = network.defaultAddressScheme
        }
        
        var mode = self.connectionMode(for: currency)
        if !network.supportsMode(mode) {
            mode = network.defaultMode
        }
        
        var success = false
        
        if system.accountIsInitialized(system.account, onNetwork: network) {
            print("[SYS] creating wallet manager for \(network). active wallets: \(requiredTokens.map { $0.code }.joined(separator: ","))")
            success = system.createWalletManager(network: network,
                                                 mode: mode,
                                                 addressScheme: addressScheme,
                                                 currencies: requiredTokens)
            if !success {
                print("[SYS] failed to create wallet manager. wiping persistent storage to retry...")
                system.wipe(network: network)
                success = system.createWalletManager(network: network,
                                                     mode: mode,
                                                     addressScheme: addressScheme,
                                                     currencies: requiredTokens)
            }
            assert(success, "failed to create \(network) wallet manager")
        } else {
            print("[SYS] initializing wallet manager for \(network). active wallets: \(requiredTokens.map { $0.code }.joined(separator: ","))")
            initialize(network: network, system: system, createIfDoesNotExist: false) { [weak self] data in
                guard let data = data else { self?.setRequiresCreation(currency); return }
                self?.keyStore.updateAccountSerialization(data)
                print("[SYS] hbar initializationData: \(CoreCoder.hex.encode(data: data) ?? "no hex")")
                success = system.createWalletManager(network: network,
                                                     mode: mode,
                                                     addressScheme: addressScheme,
                                                     currencies: requiredTokens)
                assert(success, "failed to create \(network) wallet manager")
            }
        }
    }
    
    private func createAccount(forCurrency currency: Currency, callback: @escaping (Wallet?) -> Void) {
        guard let system = system else { return callback(nil) }
        initialize(network: currency.network, system: system, createIfDoesNotExist: true) { [weak self] data in
            guard let self = self else { return }
            guard let data = data else { return callback(nil) }
            guard let assetCollection = self.assetCollection else { return callback(nil) }
            self.keyStore.updateAccountSerialization(data)
            print("[SYS] hbar initializationData: \(CoreCoder.hex.encode(data: data) ?? "no hex")")
            
            self.createWalletCallback = callback
            let success = system.createWalletManager(network: currency.network,
                                                     mode: self.connectionMode(for: currency),
                                                     addressScheme: currency.network.defaultAddressScheme,
                                                     currencies: currency.network.currencies.filter { assetCollection.isEnabled($0.uid) })
            assert(success, "failed to create \(currency.network) wallet manager")
        }
    }
    
    private func setRequiresCreation(_ currency: Currency) {
        DispatchQueue.main.async {
            Store.perform(action: SetRequiresCreation(currency))
        }
    }
    
    /// Migrates the old sqlite persistent storage data to Core, if present.
    /// Deletes old database after successful migration.
    private func migrateLegacyDatabase(network: Network) {
        guard let currency = currencies[network.currency.uid],
              (currency.isBitcoin || currency.isBitcoinCash) else { return }
        let fm = FileManager.default
        let filename = currency.isBitcoin ? "BreadWallet.sqlite" : "BreadWallet-bch.sqlite"
        let docsUrl = try? fm.url(for: .documentDirectory,
                                  in: .userDomainMask,
                                  appropriateFor: nil,
                                  create: false)
        guard let dbPath = docsUrl?.appendingPathComponent(filename).path,
              fm.fileExists(atPath: dbPath) else { return }
        
        do {
            let db = CoreDatabase()
            try db.openDatabase(path: dbPath)
            defer { db.close() }
            
            let txBlobs = db.loadTransactions()
            let blockBlobs = db.loadBlocks()
            let peerBlobs = db.loadPeers()
            
            print("[SYS] migrating \(network.currency.code) database: \(txBlobs.count) txns / \(blockBlobs.count) blocks / \(peerBlobs.count) peers")
            
        } catch let error {
            print("[SYS] database migration failed: \(error)")
        }
        // delete the old database to avoid future migration attempts
        try? fm.removeItem(atPath: dbPath)
    }
    
    /// Adds a Wallet model for the Core Wallet if it is enabled in the asset collection.
    private func addWallet(_ coreWallet: WalletKit.Wallet) -> Wallet? {
        guard let assetCollection = assetCollection,
              let currency = currencies[coreWallet.currency.uid],
              wallets[coreWallet.currency.uid] == nil else {
            //assertionFailure()
            return nil
        }
        
        guard assetCollection.isEnabled(currency.uid) else {
            print("[SYS] hidden wallet not added: \(currency.code)")
            return nil
        }
        
        let wallet = Wallet(core: coreWallet,
                            currency: currency,
                            system: self)
        wallets[coreWallet.currency.uid] = wallet
        if currency.isHBAR && createWalletCallback != nil {
            createWalletCallback?(wallet)
            createWalletCallback = nil
            DispatchQueue.main.async {
                Store.perform(action: SetCreationSuccess(currency))
            }
        }
        return wallet
    }
    
    /// Triggered by Core wallet deleted event -- normally never triggered
    private func removeWallet(_ coreWallet: WalletKit.Wallet) {
        guard wallets[coreWallet.currency.uid] != nil else { return }
        wallets[coreWallet.currency.uid] = nil
        updateWalletStates()
    }
    
    /// Requests the wallet managers to create wallets for all enabled currencies.
    /// Wallet creation is asynchronous and triggers a wallet `created` event.
    private func requestCoreWalletCreation() {
        guard let managers = system?.managers,
              let assetCollection = assetCollection else { return }
        
        managers.forEach { manager in
            let added = manager.network.currencies
                .filter { assetCollection.isEnabled($0.uid) && wallets[$0.uid] == nil }
                .filter { manager.registerWalletFor(currency: $0) == nil } // nil returned if wallet will be created
            if !added.isEmpty {
                print("[SYS] creating wallets for \(added.map { $0.code }.joined(separator: ","))")
            }
        }
    }
    
    /// Reset the active wallets to match the asset collection by adding/removing wallets
    private func updateActiveWallets() {
        guard let assetCollection = assetCollection else { return }
        let enabledIds = Set(assetCollection.enabledAssets.map { $0.uid })
        let newWallets = enabledIds
            .filter { wallets[$0] == nil }
            .compactMap { coreWallet($0) }
            .compactMap { addWallet($0) }
            .map { ($0.currency.uid, $0) }
        wallets = wallets
            .filter { enabledIds.contains($0.key) } // remove disabled wallets
            .merging(newWallets, uniquingKeysWith: { (_, new) in new }) // add enabled wallets
        
        sendXPubs()
    }
    
    /// Connect wallet managers with any enabled wallets and disconnect those with no enabled wallets.
    private func updateWalletManagerConnections() {
        guard let managers = system?.managers,
              let assetCollection = assetCollection else { return }
        let enabledIds = Set(assetCollection.enabledAssets.map { $0.uid })
        
        var activeManagers = [WalletManager]()
        var inactiveManagers = [WalletManager]()
        
        for manager in managers {
            if Set(manager.network.currencies.map { $0.uid }).isDisjoint(with: enabledIds) {
                inactiveManagers.append(manager)
            } else {
                activeManagers.append(manager)
            }
        }
        
        // These connect() and disconnect() calls can block for up to 20 seconds which
        // blocks updating the display currencies when they change.
        // TODO: remove the async call once the disconnect() bug has been fixed.
        DispatchQueue.global(qos: .utility).async {
            activeManagers.forEach {
                print("[SYS] connecting \($0.network.currency.code) wallet manager")
                $0.connect(using: $0.customPeer)
            }
            
            inactiveManagers.forEach {
                print("[SYS] disconnecting \($0.network.currency.code) wallet manager")
                $0.disconnect()
            }
        }
    }
    
    // MARK: Connection Mode
    
    func isModeSupported(_ mode: WalletConnectionMode, for network: Network) -> Bool {
        return network.supportsMode(mode)
    }
    
    func setConnectionMode(_ mode: WalletConnectionMode, forWalletManager wm: WalletManager) {
        guard wm.network.supportsMode(mode) else { return }
        queue.async {
            wm.disconnect()
            wm.mode = mode
            wm.connect(using: wm.customPeer)
        }
    }
    
    func connectionMode(for currency: Currency) -> WalletConnectionMode {
        //Develop menu connection setting override
        if currency.isBitcoin && UserDefaults.debugConnectionModeOverride.mode != nil {
            return UserDefaults.debugConnectionModeOverride.mode!
        }
        
        guard let networkCurrency = currency.tokenType == .native ? currency : currencies[currency.network.currency.uid] else {
            assertionFailure()
            return .api_only
        }
        guard let kv = Backend.kvStore,
              let walletInfo = WalletInfo(kvStore: kv) else {
            assertionFailure()
            return WalletConnectionSettings.defaultMode(for: currency)
        }
        let settings = WalletConnectionSettings(system: self, kvStore: kv, walletInfo: walletInfo)
        return settings.mode(for: networkCurrency)
    }
    
    // MARK: - AssetCollection / WalletState Management
    
    func resetToDefaultCurrencies() {
        guard let assetCollection = assetCollection else { return }
        assetCollection.resetToDefaultCollection()
        assetCollection.saveChanges() // triggers updateWalletStates
    }
    
    /// Returns true if a wallet for a network native currency is required as a dependency for other active wallets.
    func isWalletRequired(for currencyId: CurrencyId) -> Bool {
        guard let assetCollection = assetCollection,
              let currency = currencies[currencyId],
              currency.tokenType == .native else { return false }
        return !assetCollection.enabledAssets
            .compactMap { self.currencies[$0.uid] }
            .filter { $0.uid != currency.uid && $0.network == currency.network }
            .isEmpty
    }
    
    func walletBalance(currencyId: CurrencyId) -> Amount? {
        if let balance = wallets[currencyId]?.balance {
            return balance
        } else if let coreBalance = coreWallet(currencyId)?.balance, let currency = currencies[currencyId] {
            return Amount(cryptoAmount: coreBalance, currency: currency)
        } else {
            return nil
        }
    }
    
    /// Creates placeholder WalletStates for all enabled currencies which do not have a Wallet yet.
    private var placeholderWalletStates: [CurrencyId: WalletState] {
        guard let assetCollection = assetCollection else { return [:] }
        return assetCollection.enabledAssets
            .filter { self.wallets[$0.uid] == nil }
            .compactMap { self.currencies[$0.uid] }
            .reduce(into: [CurrencyId: WalletState](), { (walletStates, currency) in
                guard let displayOrder = assetCollection.displayOrder(for: currency.metaData) else { return }
                walletStates[currency.uid] = WalletState.initial(currency, displayOrder: displayOrder).mutate(syncState: .connecting)
            })
    }
    
    /// Adds or replaces WalletState for a Wallet.
    private func addWalletState(for wallet: Wallet) {
        guard let displayOrder = assetCollection?.displayOrder(for: wallet.currency.metaData) else { return assertionFailure("wallet not enabled") }
        // reading+writing Store.state must be on main thread
        DispatchQueue.main.async {
            let walletState = self.walletState(for: wallet, displayOrder: displayOrder)
            Store.perform(action: WalletChange(wallet.currency).set(walletState))
            if wallet.currency.isBitcoin {
                //At this point Currencies.btc.wallet != nil
                self.btcWalletCreationCallback?()
            }
        }
    }
    
    /// Sets the wallet states to match changes to the asset collection and Core wallets.
    /// Triggered by AssetCollection.saveChanges on main thread.
    private func updateWalletStates() {
        queue.async {
            guard let assetCollection = self.assetCollection else { return }
            print("[SYS] updating wallets")
            
            self.updateActiveWallets()
            self.updateWalletManagerConnections()
            self.requestCoreWalletCreation()
            
            // reading+writing Store.state must be on main thread
            DispatchQueue.main.async {
                // combine and set active wallet states and placeholder (pending wallet creation) wallet states
                let walletStates: [CurrencyId: WalletState] = assetCollection.enabledAssets
                    .compactMap { self.wallets[$0.uid] }
                    .reduce(into: [CurrencyId: WalletState](), { (walletStates, wallet) in
                        let currency = wallet.currency
                        guard let displayOrder = assetCollection.displayOrder(for: currency.metaData) else { return }
                        walletStates[currency.uid] = self.walletState(for: wallet, displayOrder: displayOrder)
                    })
                    .merging(self.placeholderWalletStates, uniquingKeysWith: { (existing, _) in existing })
                Store.perform(action: ManageWallets.SetWallets(walletStates))
                Backend.updateExchangeRates()
            }
        }
    }
    
    private func coreWallet(_ currencyId: CurrencyId) -> WalletKit.Wallet? {
        return system?.wallets.first(where: { $0.currency.uid == currencyId })
    }
    
    private func walletState(for wallet: Wallet, displayOrder: Int) -> WalletState {
        assert(Thread.isMainThread)
        if let existing = Store.state.wallets[wallet.currency.uid] {
            return existing.mutate(wallet: wallet, displayOrder: displayOrder, syncState: .success, balance: wallet.balance)
        } else {
            return WalletState.initial(wallet.currency, wallet: wallet, displayOrder: displayOrder)
                .mutate(syncState: .success, balance: wallet.balance)
        }
    }
    
    /// Returns true of any of the enabled assets in the asset collection are dependent on the wallet manager
    private func isWalletManagerNeeded(_ manager: WalletManager) -> Bool {
        guard let assetCollection = assetCollection else { return false }
        let enabledCurrencyIds = Set(assetCollection.enabledAssets.map { $0.uid })
        let supportedCurrencyIds = manager.network.currencies.map { $0.uid }
        return !Set(supportedCurrencyIds).isDisjoint(with: enabledCurrencyIds)
    }
    
    // Shows the network activity indicator and prevents
    // the app from being backgrounded while syncing
    private func startActivity() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    private func endActivity() {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: Wallet ID
    
    // walletID identifies a wallet by the ethereum public key
    // 1. compute the sha256(address[0]) -- note address excludes the "0x" prefix
    // 2. take the first 10 bytes of the sha256 and base32 encode it (lowercasing the result)
    // 3. split the result into chunks of 4-character strings and join with a space
    //
    // this provides an easily human-readable (and verbally-recitable) string that can
    // be used to uniquely identify this wallet.
    //
    // the user may then provide this ID for later lookup in associated systems
    private func walletID(address: String) -> String? {
        if let small = address.withoutHexPrefix.data(using: .utf8)?.sha256[0..<10].base32.lowercased() {
            return stride(from: 0, to: small.count, by: 4).map {
                let start = small.index(small.startIndex, offsetBy: $0)
                let end = small.index(start, offsetBy: 4, limitedBy: small.endIndex) ?? small.endIndex
                return String(small[start..<end])
            }.joined(separator: " ")
        }
        return nil
    }
}

// MARK: - SystemListener

// callbacks execute on CoreSystem.queue
extension CoreSystem: SystemListener {
    
    func handleSystemEvent(system: System, event: SystemEvent) {
        print("[SYS] system event: \(event)")
        switch event {
        case .created:
            break
            
        case .networkAdded:
            break
            
            // after all networks are added
        case .discoveredNetworks(let networks):
            guard !E.isRunningTests else { return }
            let filteredNetworks = networks.filter { $0.onMainnet == !E.isTestnet }
            filteredNetworks.forEach { addCurrencies(for: $0) }
            DispatchQueue.main.async {
                Store.perform(action: ManageWallets.AddWallets(self.placeholderWalletStates))
                Backend.updateExchangeRates()
            }
            filteredNetworks.forEach { setupWalletManager(for: $0) }
            
        case .managerAdded(let manager):
            if self.isWalletManagerNeeded(manager) {
                manager.connect(using: manager.customPeer)
            }
            
        case .receiveAddressSync(let manager):
            manager.receiveAddressSync()
            
        case .changed:
            break
            
        case .deleted:
            break
        }
    }
    
    func handleManagerEvent(system: System, manager: WalletKit.WalletManager, event: WalletManagerEvent) {
        print("[SYS] \(manager.network) manager event: \(event)")
        switch event {
        case .created:
            break
        case .changed: // (let oldState, let newState):
            break
        case .deleted:
            break
        case .walletAdded: // (let wallet):
            break
        case .walletChanged: // (let wallet):
            break
        case .walletDeleted: // (let wallet):
            break
            
        case .syncStarted:
            DispatchQueue.main.async {
                // only show the initial sync for API-mode wallets
                let isP2Psync = manager.mode == .p2p_only
                manager.network.currencies.compactMap { self.currencies[$0.uid] }
                    .filter { isP2Psync || (Store.state[$0]?.syncState == .connecting) }
                    .forEach { Store.perform(action: WalletChange($0).setSyncingState(.syncing)) }
                if isP2Psync {
                    self.startActivity()
                }
            }
            
        case .syncProgress(let timestamp, let percentComplete):
            guard manager.mode == .p2p_only else { break }
            DispatchQueue.main.async {
                manager.network.currencies.compactMap { self.currencies[$0.uid] }.forEach {
                    let seconds = UInt32(timestamp?.timeIntervalSince1970 ?? 0)
                    let progress = Float(percentComplete / 100.0)
                    Store.perform(action: WalletChange($0).setProgress(progress: progress, timestamp: seconds))
                }
            }
            
        case .syncEnded(let reason):
            var syncState: SyncState
            var isComplete: Bool = false
            
            switch reason {
            case .complete, .unknown:
                syncState = .success
                isComplete = true
                
            case .requested: // disconnect/background
                syncState = .connecting
                
            case .posix(let errno, let message):
                let messagePayload = "\(message ?? "") (\(errno))"
                print("[SYS] \(manager.network) sync error: \(messagePayload)")
                syncState = .connecting
                // retry by reconnecting
                DispatchQueue.main.asyncAfter(deadline: .now() + Presets.Delay.regular.rawValue) {
                    guard UIApplication.shared.applicationState == .active else { return }
                    self.queue.async {
                        manager.connect(using: manager.customPeer)
                    }
                }
            }
            
            let syncingCount = system.managers
                .filter { $0.mode == .p2p_only }
                .filter { $0.state == .syncing || $0.state == .created }.count
            
            DispatchQueue.main.async {
                manager.network.currencies.compactMap { self.currencies[$0.uid] }.forEach {
                    if isComplete {
                        Store.perform(action: WalletChange($0).setIsRescanning(false))
                        if let balance = self.wallets[$0.uid]?.balance {
                            Store.perform(action: WalletChange($0).setBalance(balance))
                        }
                    }
                    Store.perform(action: WalletChange($0).setSyncingState(syncState))
                }
                
                // If there are no more p2p wallets syncing, hide
                // the network activity indicator and resume
                // the idle timer
                if syncingCount == 0 {
                    self.endActivity()
                }
            }
            
        case .syncRecommended(let depth):
            print("[SYS] \(manager.network) rescan recommended from \(depth)")
            rescan(walletManager: manager, fromDepth: depth)
            
        case .blockUpdated: // (let height):
            manager.wallets.forEach { self.wallets[$0.currency.uid]?.blockUpdated() }
        }
    }
    
    func handleWalletEvent(system: System, manager: WalletKit.WalletManager, wallet: WalletKit.Wallet, event: WalletEvent) {
        print("[SYS] \(manager.network) wallet event: \(wallet.currency.code) \(event)")
        switch event {
        case .created:
            if let wallet = addWallet(wallet) {
                addWalletState(for: wallet)
            }
            // generate wallet ID from Ethereum address
            if wallet.currency.uid == Currencies.shared.eth?.uid,
               let walletID = self.walletID(address: wallet.target.description) {
                DispatchQueue.main.async {
                    Store.perform(action: WalletID.Set(walletID))
                    
                    DispatchQueue.global(qos: .utility).async {
                        self.keyStore.migrateNoKeyBackup(id: walletID)
                    }
                }
            }
            
        case .deleted:
            self.removeWallet(wallet)
            
        default:
            self.wallets[wallet.currency.uid]?.handleWalletEvent(event)
        }
    }
    
    func handleTransferEvent(system: System, manager: WalletKit.WalletManager, wallet: WalletKit.Wallet, transfer: Transfer, event: TransferEvent) {
        guard let wallet = self.wallets[wallet.currency.uid] else { return }
        print("[SYS] \(manager.network) transfer \(event): \(wallet.currency.code) \(transfer.hash?.description.truncateMiddle() ?? "")")
        wallet.handleTransferEvent(event, transfer: transfer)
    }
    
    func handleNetworkEvent(system: System, network: Network, event: NetworkEvent) {
        print("[SYS] network event: \(event) (\(network))")
    }
}

// MARK: - Extensions

extension WalletManager {
    var customPeer: NetworkPeer? {
        guard network.currency.uid == Currencies.shared.btc?.uid,
              let address = UserDefaults.customNodeIP else { return nil }
        let port = UInt16(UserDefaults.customNodePort ?? Constant.standardPort)
        return network.createPeer(address: address, port: port, publicKey: nil)
    }
    
    var isConnected: Bool {
        return state == .connected || state == .syncing
    }
}

extension WalletManagerEvent: CustomStringConvertible {
    public var description: String {
        switch self {
        case .created:
            return "created"
        case .changed(let oldState, let newState):
            return "changed(\(oldState) -> \(newState))"
        case .deleted:
            return "deleted"
        case .walletAdded(let wallet):
            return "walletAdded(\(wallet.currency.code))"
        case .walletChanged(let wallet):
            return "walletChanged(\(wallet.currency.code))"
        case .walletDeleted(let wallet):
            return "walletDeleted(\(wallet.currency.code))"
        case .syncStarted:
            return "syncStarted"
        case .syncProgress(_, let percentComplete):
            return "syncProgress(\(percentComplete))"
        case .syncEnded(let reason):
            return "syncEnded(\(reason))"
        case .syncRecommended(let depth):
            return "syncRecommended(\(depth))"
        case .blockUpdated(let height):
            return "blockUpdated(\(height))"
        }
    }
}

extension Address {
    var sanitizedDescription: String {
        return description
            .removing(prefix: "bitcoincash:")
            .removing(prefix: "bchtest:")
    }
}

//TODO:CRYPTO hook up to notifications?
// MARK: - Sounds
/*
extension WalletManager {
    func ping() {
        guard let url = Bundle.main.url(forResource: "coinflip", withExtension: "aiff") else { return }
        var id: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURL, &id)
        AudioServicesAddSystemSoundCompletion(id, nil, nil, { soundId, _ in
            AudioServicesDisposeSystemSoundID(soundId)
        }, nil)
        AudioServicesPlaySystemSound(id)
    }
    
    func showLocalNotification(message: String) {
        guard UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive else { return }
        guard Store.state.isPushNotificationsEnabled else { return }
    }
}
*/
