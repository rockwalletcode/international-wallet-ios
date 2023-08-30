//
//  SendViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-11-30.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import UIKit
import LocalAuthentication
import WalletKit

typealias PresentScan = ((@escaping ScanCompletion) -> Void)
typealias FeeEstimationError = WalletKit.Wallet.FeeEstimationError

// swiftlint:disable type_body_length
class SendViewController: BaseSendViewController, Subscriber, ModalPresentable {
    // MARK: - Public
    
    var presentScan: PresentScan?
    var parentView: UIView? //ModalPresentable
    
    init(sender: Sender, initialRequest: PaymentRequest? = nil) {
        let currency = sender.wallet.currency
        
        self.currency = currency
        self.initialRequest = initialRequest
        self.balance = currency.state?.balance ?? Amount.zero(currency)
        self.maximum = self.balance
        
        addressCell = AddressCell(currency: currency)
        amountView = AmountViewController(currency: currency, isPinPadExpandedAtLaunch: false)
        attributeCell = AttributeCell(currency: currency)
        
        super.init(sender: sender)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Private
    
    deinit {
        Store.unsubscribe(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    private let amountView: AmountViewController
    private let addressCell: AddressCell
    private let attributeCell: AttributeCell?
    private let memoCell = DescriptionSendCell(placeholder: L10n.Send.descriptionLabel)
    private let sendButton = BRDButton(title: L10n.Send.sendLabel, type: .secondary)
    private var attributeCellHeight: NSLayoutConstraint?
    private let confirmTransitioningDelegate = PinTransitioningDelegate()
    private let currency: Currency
    private let initialRequest: PaymentRequest?
    private var paymentProtocolRequest: PaymentProtocolRequest?
    private var didIgnoreUsedAddressWarning = false
    private var didIgnoreIdentityNotCertified = false
    private var feeLevel: FeeLevel = .priority { // Default to priority
        didSet {
            updateFees()
        }
    }
    private var balance: Amount
    private var maximum: Amount? {
        didSet {
            sender.maximum = maximum
            amountView.maximum = maximum
            if let max = maximum, isSendingMax {
                amountView.forceUpdateAmount(amount: max)
            }
        }
    }
    
    private var amount: Amount? {
        didSet {
            if oldValue != amount {
                updateFees()
            }
        }
    }
    private var address: String? {
        if resolvedAddress != nil {
            return resolvedAddress?.cryptoAddress
        }
        if let protoRequest = paymentProtocolRequest {
            return protoRequest.primaryTarget?.description
        } else {
            return addressCell.address
        }
    }
    
    private var outputScript: String?
    private var resolvedAddress: ResolvedAddress?
    
    private var currentFeeBasis: TransferFeeBasis?
    private var isSendingMax = false {
        didSet {
            amountView.isSendViewSendingMax = isSendingMax
        }
    }
    
    private var timer: Timer?
    
    private var ethMultiplier: Decimal = 0.60
    
    private func startTimer() {
        guard timer?.isValid != true else { return }
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 15,
                                     target: self,
                                     selector: #selector(updateFees),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.Background.one
        view.addSubview(addressCell)
        view.addSubview(memoCell)
        view.addSubview(sendButton)
        
        sendButton.isEnabled = false
        
        addressCell.constrainTopCorners(height: SendCell.defaultHeight)
        
        var addressGroupBottom: NSLayoutYAxisAnchor
        if currency.attributeDefinition != nil, let tagCell = attributeCell {
            view.addSubview(tagCell)
            attributeCellHeight = tagCell.heightAnchor.constraint(equalToConstant: SendCell.defaultHeight)
            tagCell.constrain([
                tagCell.leadingAnchor.constraint(equalTo: addressCell.leadingAnchor),
                tagCell.topAnchor.constraint(equalTo: addressCell.bottomAnchor),
                tagCell.trailingAnchor.constraint(equalTo: addressCell.trailingAnchor),
                attributeCellHeight])
            addressGroupBottom = tagCell.bottomAnchor
        } else {
            addressGroupBottom = addressCell.bottomAnchor
        }
        
        addChildViewController(amountView, layout: {
            amountView.view.constrain([
                amountView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                amountView.view.topAnchor.constraint(equalTo: addressGroupBottom, constant: Margins.large.rawValue),
                amountView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor) ])
        })
        
        memoCell.constrain([
            memoCell.widthAnchor.constraint(equalTo: amountView.view.widthAnchor),
            memoCell.topAnchor.constraint(equalTo: amountView.view.bottomAnchor),
            memoCell.leadingAnchor.constraint(equalTo: amountView.view.leadingAnchor),
            memoCell.heightAnchor.constraint(equalTo: memoCell.textView.heightAnchor, constant: Margins.extraHuge.rawValue) ])
        
        memoCell.accessoryView.constrain([
            memoCell.accessoryView.constraint(.width) ])
        
        sendButton.constrain([
            sendButton.constraint(.leading, toView: view, constant: Margins.large.rawValue),
            sendButton.constraint(.trailing, toView: view, constant: -Margins.large.rawValue),
            sendButton.constraint(toBottom: memoCell, constant: Margins.extraHuge.rawValue),
            sendButton.constraint(.height, constant: ViewSizes.Common.defaultCommon.rawValue),
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: E.isIPhoneX ? -Margins.custom(5) : -Margins.large.rawValue) ])
        addButtonActions()
        
        Store.subscribe(self,
                        selector: { [weak self] oldState, newState in
            guard let self = self else { return false }
            return oldState[self.currency]?.balance != newState[self.currency]?.balance },
                        callback: { [weak self] in
            guard let self = self else { return }
            if let balance = $0[self.currency]?.balance {
                self.balance = balance
            }
        })
        
        addAddressChangeListener()
        sender.updateNetworkFees()
        
        GoogleAnalytics.logEvent(GoogleAnalytics.Send(currencyId: String(describing: currency.uid), cryptoRequestUrl: address ?? ""))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startTimer()
        
        if let initialRequest = initialRequest {
            handleRequest(initialRequest)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopTimer()
    }
    
    private func addAddressChangeListener() {
        addressCell.textDidChange = { [weak self] text in
            guard let self = self,
                  let text = text,
                  self.currency.isValidAddress(text) else { return }
            
            self.updateFees()
        }
    }
    
    // MARK: - Actions
    
    private func addButtonActions() {
        addressCell.paste.addTarget(self, action: #selector(SendViewController.pasteTapped), for: .touchUpInside)
        addressCell.scan.addTarget(self, action: #selector(SendViewController.scanTapped), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        
        memoCell.didReturn = { textView in
            textView.resignFirstResponder()
        }
        
        memoCell.didBeginEditing = { [weak self] in
            self?.amountView.closePinPad()
        }
        
        addressCell.didBeginEditing = { [weak self] in
            self?.amountView.closePinPad()
        }
        
        addressCell.didEndEditing = { [weak self] in
            self?.checkAndHandleLegacyBCHAddress()
        }
        
        addressCell.didReceivePaymentRequest = { [weak self] request in
            self?.handleRequest(request)
        }
        
        addressCell.didReceiveResolvedAddress = { [weak self] result, type in
            DispatchQueue.main.async {
                self?.handleResolvableResponse(result, type: type, id: self?.addressCell.address ?? "")
            }
        }
        
        amountView.balanceTextForAmount = { [weak self] amount, rate in
            return self?.balanceTextForAmount(amount, rate: rate)
        }
        
        amountView.didUpdateAmount = { [weak self] amount in
            self?.amount = amount
        }
        
        amountView.didUpdateFee = { [weak self] fee in
            self?.feeLevel = fee
        }
        
        amountView.didChangeFirstResponder = { [weak self] isFirstResponder in
            if isFirstResponder {
                self?.memoCell.textView.resignFirstResponder()
                self?.addressCell.textField.resignFirstResponder()
                self?.attributeCell?.textField.resignFirstResponder()
            }
        }
        
        attributeCell?.didBeginEditing = { [weak self] in
            self?.amountView.closePinPad()
        }
        
        amountView.didTapMax = { [weak self] in
            guard var max = self?.maximum else {
                // This is highly unlikely to be reached because the button should be disabled if a maximum doesn't exist
                self?.showErrorMessage(L10n.Send.Error.maxError)
                return
            }
            self?.isSendingMax = true
            
            if max.currency.isEthereum { // Only adjust maximum for ETH
                let adjustTokenValue = max.tokenValue * (self?.ethMultiplier ?? 0.80) // Reduce amount for ETH estimate fee API call
                max = Amount(tokenString: ExchangeFormatter.current.string(for: adjustTokenValue) ?? "0", currency: max.currency)
            }
            self?.amountView.forceUpdateAmount(amount: max)
            self?.updateFeesMax(depth: 0)
        }
    }
    
    @objc private func updateFees() {
        guard let amount else { return }
        guard amount <= balance else {
            _ = handleValidationResult(.insufficientFunds)
            return
        }
        guard let address, !address.isEmpty else {
            _ = handleValidationResult(.invalidAddress)
            return
        }
        
        if let xrpBalanceError = XRPBalanceValidator.validate(balance: balance, amount: amount, currency: currency) {
            showToastMessage(model: .init(description: .text(xrpBalanceError)), configuration: Presets.InfoView.error)
            return
        }
        
        sender.estimateFee(address: address, amount: amount, tier: feeLevel, isStake: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fee):
                    self?.currentFeeBasis = fee
                    self?.sendButton.isEnabled = true
                    
                    guard let feeCurrency = self?.sender.wallet.feeCurrency else { return }
                    guard let feeCurrencyWalletBalance = feeCurrency.wallet?.balance else { return }
                    let feeAmount = Amount(cryptoAmount: fee.fee, currency: feeCurrency)
                    if feeCurrency.isEthereum {
                        if feeAmount > feeCurrencyWalletBalance {
                            self?.showInsufficientGasError()
                        }
                    }
                    
                    if self?.isSendingMax != true {
                        guard let balance = self?.balance else { return }

                        if amount.currency == feeAmount.currency {
                            if amount + feeAmount > balance {
                                _ = self?.handleValidationResult(.insufficientGas)
                            }
                        }
                    }
                    
                case .failure(let error):
                    self?.handleEstimateFeeError(error: error)
                }
                
                self?.amountView.updateBalanceLabel()
            }
        }
    }
    
    @objc private func updateFeesMax(depth: Int) {
        guard let amount, let maximum else { return }
        guard let address, !address.isEmpty else { return _ = handleValidationResult(.invalidAddress) }
        
        sender.estimateFee(address: address, amount: amount, tier: feeLevel, isStake: false) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fee):
                    self?.currentFeeBasis = fee
                    self?.sendButton.isEnabled = true
                    
                    guard let feeCurrency = self?.sender.wallet.feeCurrency else {
                        return
                    }
                    let feeUpdated = Amount(cryptoAmount: fee.fee, currency: feeCurrency)
                    
                    var value = amount
                    if amount.currency == feeUpdated.currency {
                        value = maximum > feeUpdated ? maximum - feeUpdated : maximum
                    }
                    
                    if maximum.currency.isEthereum {
                        self?.amountView.forceUpdateAmount(amount: value)
                    } else {
                        if value != amount && depth < 3 { // Call recursively until the amount + fee = maximum up to 3 iterations
                            self?.amountView.forceUpdateAmount(amount: value)
                            self?.updateFeesMax(depth: depth + 1)
                        }
                    }

                case .failure(let error):
                    // updateFeesMax failed, default to a fixed reduction
                    if maximum.currency.isEthereum {
                        let adjustTokenValue = maximum.tokenValue * 0.80 // Reduce amount for ETH estimate fee API call
                        let max = Amount(tokenString: ExchangeFormatter.current.string(for: adjustTokenValue) ?? "0", currency: maximum.currency)
                        self?.amountView.forceUpdateAmount(amount: max)
                    } else {
                        self?.handleEstimateFeeError(error: error)
                    }
                }
                
                self?.amountView.updateBalanceLabel()
            }
        }
    }
    
    // returns Balance Text, Fee Text and isUserInteractionEnabled for balanceLabel
    private func balanceTextForAmount(_ amount: Amount?, rate: Rate?) -> (NSAttributedString?, NSAttributedString?, Bool) {
        //Use maximum if available, otherwise use balance
        let balanceAmount = Amount(amount: maximum ?? balance, rate: rate, minimumFractionDigits: 0)
        var feeOutput = ""
        if let amount = amount, !amount.isZero, let feeBasis = currentFeeBasis {
            var feeUpdated = feeBasis.fee
            if amount.currency.isEthereum && feeBasis.fee > balanceAmount.cryptoAmount {
                feeUpdated = (feeBasis.fee - amount.cryptoAmount) ?? feeBasis.fee
            }
            let fee = Amount(cryptoAmount: feeUpdated, currency: sender.wallet.feeCurrency)
            let feeAmount = Amount(amount: fee,
                                   rate: (amountView.selectedRate != nil) ? sender.wallet.feeCurrency.state?.currentRate : nil,
                                   maximumFractionDigits: Amount.highPrecisionDigits)
            let feeText = feeAmount.description
            feeOutput = L10n.Send.fee(feeText)
        }
        
        let balanceLabelattributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.Body.two,
            NSAttributedString.Key.foregroundColor: Colors.Text.two
        ]
        
        var balanceAttributes: [NSAttributedString.Key: Any] = [ NSAttributedString.Key.font: Fonts.Subtitle.two ]
        if isSendingMax || maximum == nil {
            balanceAttributes[NSAttributedString.Key.foregroundColor] = Colors.Text.two
        } else {
            balanceAttributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
            balanceAttributes[NSAttributedString.Key.foregroundColor] = Colors.Text.two
        }
        
        let feeAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.Body.two,
            NSAttributedString.Key.foregroundColor: Colors.Text.two
        ]
        
        let balanceOutput = NSMutableAttributedString()
        balanceOutput.append(NSAttributedString(string: isSendingMax ? L10n.Send.sendingMax : L10n.Send.balanceString, attributes: balanceLabelattributes))
        balanceOutput.append(NSAttributedString(string: balanceAmount.description, attributes: balanceAttributes))
        return (balanceOutput, NSAttributedString(string: feeOutput, attributes: feeAttributes), !isSendingMax)
    }
    
    @objc private func pasteTapped() {
        guard let pasteboard = UIPasteboard.general.string, !pasteboard.utf8.isEmpty else {
            return showAlert(title: L10n.Alert.error, message: L10n.Send.emptyPasteboard)
        }
        
        if let resolver = ResolvableFactory.resolver(pasteboard) {
            self.addressCell.setContent(pasteboard)
            self.addressCell.showResolvingSpinner()
            resolver.fetchAddress(forCurrency: currency) { response in
                DispatchQueue.main.async {
                    self.handleResolvableResponse(response, type: resolver.type, id: pasteboard)
                }
            }
            return
        }
        
        guard let request = PaymentRequest(string: pasteboard, currency: currency) else {
            let message = L10n.Send.invalidAddressOnPasteboard(currency.name)
            return showAlert(title: L10n.Send.invalidAddressTitle, message: message)
        }
        self.paymentProtocolRequest = nil
        handleRequest(request)
    }
    
    private func handleResolvableResponse(_ response: Result<String?, Error>,
                                          type: ResolvableType,
                                          id: String) {
        switch response {
        case .success(let addressDetails):
            guard let addressDetails else { return }
            
            let outputScript = addressDetails
            let address = sender.wallet.getAddressFromScript(output: outputScript)
            let tag: String? = nil
            
            self.outputScript = outputScript
            
            guard currency.isValidAddress(address) else {
                let message = L10n.Send.invalidAddressMessage(currency.name)
                showAlert(title: L10n.Send.invalidAddressTitle, message: message)
                resetPaymail()
                return
            }
            
            // Here we have a valid address from Paymail
            // After this event, the addresscell should be in an un-editable state similar to when a payment request is recieved
            self.resolvedAddress = ResolvedAddress(humanReadableAddress: id,
                                                   cryptoAddress: address,
                                                   label: type.label,
                                                   type: type)
            if tag != nil {
                self.hideDestinationTag()
            }
            if let destinationTag = tag {
                attributeCell?.setContent(destinationTag)
            }
            
            addressCell.showResolveableState(type: type, address: address)
            addressCell.hideActionButtons()
            
        case .failure(let error):
            if let error = error as? FEError, !error.errorMessage.isEmpty {
                showErrorMessage(error.errorMessage)
            } else {
                resetPaymail()
            }
            
            addressCell.hideResolveableState()
        }
    }
    
    private func hideDestinationTag() {
        UIView.animate(withDuration: Presets.Animation.short.rawValue, animations: {
            self.attributeCellHeight?.constant = 0.0
            self.attributeCell?.alpha = 0.0
        }, completion: { _ in
            self.attributeCell?.isHidden = true
        })
    }
    
    private func resetPaymail() {
        resolvedAddress = nil
        addressCell.hideResolveableState()
        addressCell.setContent("")
        addressCell.hideResolveableState()
    }
    
    @objc private func scanTapped() {
        memoCell.textView.resignFirstResponder()
        addressCell.textField.resignFirstResponder()
        presentScan? { [weak self] scanResult in
            self?.paymentProtocolRequest = nil
            guard case .paymentRequest(let request, _)? = scanResult, let request = request else { return }
            self?.handleRequest(request)
        }
    }
    
    internal override func validateSendForm() -> Bool {
        //Payment Protocol Requests do their own validation
        guard paymentProtocolRequest == nil else { return true }
        
        guard let address, !address.isEmpty else {
            showAlert(title: L10n.Alert.error, message: L10n.Send.noAddress)
            return false
        }
        
        //Having an invalid address will cause fee estimation to fail,
        //so we need to display this error before the fee estimate error.
        //Without this, the fee estimate error will be shown and the user won't
        //know that the address is invalid.
        guard currency.isValidAddress(address) else {
            let message = L10n.Send.invalidAddressMessage(currency.name)
            showAlert(title: L10n.Send.invalidAddressTitle, message: message)
            return false
        }
        
        guard let amount, !amount.isZero else {
            showAlert(title: L10n.Alert.error, message: L10n.Send.noAmount)
            return false
        }
        
        guard let feeBasis = currentFeeBasis else {
            showAlert(title: L10n.Alert.error, message: L10n.Send.noFeeEstimate)
            return false
        }
        
        var attributeText: String?
        XRPAttributeValidator.validate(from: attributeCell?.attribute,
                                       currency: currency) { [weak self] attribute in
            if attribute == nil {
                self?.showAlert(title: L10n.Alert.error, message: L10n.Send.destinationTag)
            }
            
            attributeText = attribute
        }
        
        return handleValidationResult(sender.createTransaction(outputScript: outputScript,
                                                               address: address,
                                                               amount: amount,
                                                               feeBasis: feeBasis,
                                                               comment: memoCell.textView.text,
                                                               attribute: attributeText,
                                                               secondFactorCode: secondFactorCode,
                                                               secondFactorBackup: secondFactorBackup))
    }
    
    private func handleEstimateFeeError(error: Error) {
        guard let amount, !amount.isZero else { return }
        
        sendButton.isEnabled = false
        
        _ = handleValidationResult(.insufficientGas)
        
    }
    
    internal override func showInsufficientGasError() {
        if currency.isEthereum {
            showAlert(title: L10n.Alert.error, message: L10n.Send.insufficientGas)
        } else if currency.isERC20Token {
            showAlert(message: L10n.ErrorMessages.ethBalanceLowAddEth(currency.code))
        } else if let feeAmount = currentFeeBasis?.fee {
            let title = L10n.Send.insufficientGasTitle(feeAmount.currency.name)
            let message = L10n.Send.insufficientGasMessage(feeAmount.description, feeAmount.currency.name)

            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: L10n.Button.yes, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                Store.trigger(name: .showCurrency(self.sender.wallet.feeCurrency))
            }))

            alertController.addAction(UIAlertAction(title: L10n.Button.no, style: .cancel))

            present(alertController, animated: true, completion: nil)
        }
    }
    
    func convertBCH(address: String) {
        ConvertBchWorker().execute(requestData: ConvertBchRequestData(address: address)) { result in
            switch result {
            case .success(let data):
                self.addressCell.setContent(data?.cashAddress)
                self.hidePopup()
                let model: InfoViewModel = .init(description: .text(L10n.Bch.conversionMessage))
                self.showToastMessage(model: model, configuration: Presets.InfoView.verification)
                
            case .failure(let error):
                let error = error as? NetworkingError
                let model: InfoViewModel = .init(description: .text(error?.errorMessage))
                self.showToastMessage(model: model, configuration: Presets.InfoView.error)
            }
        }
    }
    
    func isLegacyAddress(currency: Currency, address: String) -> Bool {
        return currency.isLegacyBCHAddress(address: address) && Address.createLegacy(string: address, network: currency.network) != nil
    }
    
    private func checkAndHandleLegacyBCHAddress() {
        guard let address else { return }
        if isLegacyAddress(currency: currency, address: address) {
            let model = PopupViewModel(title: .text(L10n.Bch.converterTitle),
                                       body: L10n.Bch.converterDescription,
                                       buttons: [.init(title: L10n.Button.convert),
                                                 .init(title: L10n.LinkWallet.decline)],
                                       closeButton: .init(image: Asset.close.image))
            
            showInfoPopup(with: model, callbacks: [ { [weak self] in
                self?.convertBCH(address: address)
            }, { [weak self] in
                self?.declineConversion()
            }])
        }
    }
    
    func declineConversion() {
        hidePopup()
        addressCell.setContent(nil)
        let model: InfoViewModel = .init(description: .text(L10n.Bch.errorMessage))
        showToastMessage(model: model, configuration: Presets.InfoView.error)
    }
    
    func showToastMessage(model: InfoViewModel, configuration: InfoViewConfiguration) {
        ToastMessageManager.shared.show(model: model,
                                        configuration: configuration)
    }
    
    private func handleValidationResult(_ result: SenderValidationResult, protocolRequest: PaymentProtocolRequest? = nil) -> Bool {
        switch result {
        case .noFees:
            showAlert(title: L10n.Alert.error, message: L10n.Send.noFeesError)
            
        case .invalidAddress:
            let message = L10n.Send.invalidAddressMessage(currency.name)
            showAlert(title: L10n.Send.invalidAddressTitle, message: message)
            
        case .ownAddress:
            showAlert(title: L10n.Alert.error, message: L10n.Send.containsAddress)
            
        case .outputTooSmall(let minOutput), .paymentTooSmall(let minOutput):
            let amountText = "\(minOutput.tokenDescription) (\(minOutput.fiatDescription))"
            let message = L10n.PaymentProtocol.Errors.smallPayment(amountText)
            showAlert(title: L10n.Alert.error, message: message)
            
        case .insufficientFunds:
            showAlert(title: L10n.Alert.error, message: L10n.Send.insufficientFunds)
            
        case .failed:
            showAlert(title: L10n.Alert.error, message: L10n.Send.creatTransactionError)
            
        case .insufficientGas:
            showInsufficientGasError()
            
        case .identityNotCertified(let message):
            showError(title: L10n.Send.identityNotCertified, message: message, ignore: { [unowned self] in
                self.didIgnoreIdentityNotCertified = true
                if let protoReq = protocolRequest {
                    self.didReceivePaymentProtocolRequest(protoReq)
                }
            })
            return false
            
        case .invalidRequest(let errorMessage):
            showAlert(title: L10n.PaymentProtocol.Errors.badPaymentRequest, message: errorMessage)
            return false
            
        case .usedAddress:
            showError(title: L10n.Send.UsedAddress.title,
                      message: "\(L10n.Send.UsedAddress.firstLine)\n\n\(L10n.Send.UsedAddress.secondLIne)",
                      ignore: { [unowned self] in
                self.didIgnoreUsedAddressWarning = true
            })
            return false
            
        case .ok, .noExchangeRate: // Allow sending without exchange rates available (the tx metadata will not be set)
            return true
        }
        
        return false
    }
    
    @objc private func sendTapped() {
        if addressCell.textField.isFirstResponder {
            addressCell.textField.resignFirstResponder()
        }
        
        if attributeCell?.textField.isFirstResponder == true {
            attributeCell?.textField.resignFirstResponder()
        }
        
        guard let amount, let address, let feeBasis = currentFeeBasis else { return }
        
        let feeCurrency = sender.wallet.feeCurrency
        let fee = Amount(cryptoAmount: feeBasis.fee, currency: feeCurrency)
        
        let displayAmount = Amount(amount: amount,
                                   rate: amountView.selectedRate,
                                   maximumFractionDigits: Amount.highPrecisionDigits)
        let feeAmount = Amount(amount: fee,
                               rate: (amountView.selectedRate != nil) ? feeCurrency.state?.currentRate : nil,
                               maximumFractionDigits: Amount.highPrecisionDigits)
        
        let confirm = ConfirmationViewController(amount: displayAmount,
                                                 fee: feeAmount,
                                                 displayFeeLevel: feeLevel,
                                                 address: address,
                                                 currency: currency,
                                                 resolvedAddress: resolvedAddress,
                                                 shouldShowMaskView: false)
        confirm.successCallback = send
        confirm.cancelCallback = sender.reset
        present(confirm, animated: true, completion: nil)
        return
    }
    
    override func onSuccess() {
        self.dismiss(animated: true) {
            Store.trigger(name: .showStatusBar)
            super.onSuccess()
        }
    }
    
    // MARK: - Payment Protocol Requests
    
    private func handleRequest(_ request: PaymentRequest) {
        switch request.type {
        case .local:
            addressCell.setContent(request.toAddress?.description)
            addressCell.isEditable = true
            
            checkAndHandleLegacyBCHAddress()

            if let amount = request.amount {
                amountView.forceUpdateAmount(amount: amount)
            }
            
            if request.label != nil {
                memoCell.content = request.label
            }
            
            if request.destinationTag != nil {
                attributeCell?.setContent(request.destinationTag)
            }
            
        case .remote:
            let loadingView = BRActivityViewController(message: L10n.Send.loadingRequest)
            present(loadingView, animated: true)
            
            request.fetchRemoteRequest(completion: { [weak self] request in
                DispatchQueue.main.async {
                    loadingView.dismiss(animated: true, completion: {
                        if let paymentProtocolRequest = request?.paymentProtocolRequest {
                            self?.didReceivePaymentProtocolRequest(paymentProtocolRequest)
                        } else {
                            self?.showErrorMessage(L10n.Send.remoteRequestError)
                        }
                    })
                }
            })
        }
    }
    
    private func didReceivePaymentProtocolRequest(_ paymentProtocolRequest: PaymentProtocolRequest) {
        self.paymentProtocolRequest = paymentProtocolRequest
        estimateFeeForRequest(paymentProtocolRequest) { self.handleProtoReqFeeEstimation(paymentProtocolRequest, result: $0) }
    }
    
    func estimateFeeForRequest(_ protoReq: PaymentProtocolRequest, completion: @escaping (Result<TransferFeeBasis, FeeEstimationError>) -> Void) {
        let networkFee = protoReq.requiredNetworkFee ?? sender.wallet.feeForLevel(level: feeLevel)
        protoReq.estimateFee(fee: networkFee, completion: completion)
    }
    
    private func handleProtoReqFeeEstimation(_ protoReq: PaymentProtocolRequest, result: Result<TransferFeeBasis, FeeEstimationError>) {
        switch result {
        case .success(let transferFeeBasis):
            DispatchQueue.main.async {
                //We need to keep track of the fee basis here so that we can display the fee amount
                //in the tx confirmation view
                self.currentFeeBasis = transferFeeBasis
                self.validateReq(protoReq: protoReq, feeBasis: transferFeeBasis)
            }
        case .failure(let error):
            self.showErrorMessage("Error estimating fee: \(error)")
        }
    }
    
    private func validateReq(protoReq: PaymentProtocolRequest, feeBasis: TransferFeeBasis) {
        guard let totalAmount = protoReq.totalAmount else { handleZeroAmountPaymentProtocolRequest(protoReq); return }
        let requestAmount = Amount(cryptoAmount: totalAmount, currency: currency, maximumFractionDigits: 8)
        guard !requestAmount.isZero else { handleZeroAmountPaymentProtocolRequest(protoReq); return }
        let result = sender.createTransaction(protocolRequest: protoReq,
                                              ignoreUsedAddress: didIgnoreUsedAddressWarning,
                                              ignoreIdentityNotCertified: didIgnoreIdentityNotCertified,
                                              feeBasis: feeBasis,
                                              comment: protoReq.memo)
        guard handleValidationResult(result, protocolRequest: protoReq) else { return }
        addressCell.setContent(protoReq.displayText)
        memoCell.content = protoReq.memo
        amountView.forceUpdateAmount(amount: requestAmount)
        addressCell.isEditable = false
        addressCell.hideActionButtons()
        amountView.isEditable = false
        sender.displayPaymentProtocolResponse = { [weak self] in
            self?.showAlert(title: L10n.Import.success, message: $0)
        }
    }
    
    private func handleZeroAmountPaymentProtocolRequest(_ protoReq: PaymentProtocolRequest) {
        guard let address = protoReq.primaryTarget?.description else {
            showErrorMessage(L10n.Send.invalidAddressTitle); return
        }
        //After this point, a zero amount Payment protocol request behaves like a
        //regular send except the address cell isn't editable
        addressCell.setContent(address)
        addressCell.isEditable = false
        addressCell.hideActionButtons()
    }
    
    // MARK: - Errors
    
    private func showError(title: String, message: String, ignore: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: L10n.Button.ignore, style: .default, handler: { _ in
            ignore()
        }))
        alertController.addAction(UIAlertAction(title: L10n.Button.cancel, style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Keyboard Notifications

extension SendViewController {
    
    @objc private func keyboardWillShow(notification: Notification) {
        copyKeyboardChangeAnimation(notification: notification)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        copyKeyboardChangeAnimation(notification: notification)
    }
    
    private func copyKeyboardChangeAnimation(notification: Notification) {
        guard let info = KeyboardNotificationInfo(notification.userInfo) else { return }
        UIView.animate(withDuration: info.animationDuration, delay: 0, options: info.animationOptions, animations: {
            guard let parentView = self.parentView else { return }
            parentView.frame.origin.y = info.deltaY
        })
    }
}

// MARK: - ModalDisplayable

extension SendViewController: ModalDisplayable {
    var faqArticleId: String? {
        return ArticleIds.sendTx
    }
    
    var faqCurrency: Currency? {
        return currency
    }
    
    var modalTitle: String {
        return "\(L10n.Send.title) \(currency.name)"
    }
}

// swiftlint:enable type_body_length
