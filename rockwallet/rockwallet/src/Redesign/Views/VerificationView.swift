//
//  VerificationView.swift
//  breadwallet
//
//  Created by Rok on 20/05/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

enum Kyc2: String, Equatable {
    case notStarted = "KYC2_NOT_STARTED"
    case expired = "KYC2_EXPIRED"
    case submitted = "KYC2_SUBMITTED"
    case levelTwo = "KYC2"
    case resubmit = "KYC2_RESUBMISSION_REQUESTED"
    case declined = "KYC2_DECLINED"
    case kycInfoProvided = "KYC_INFO_PROVIDED"
    case kycWithSsn = "KYC_WITH_SSN"
    case kycWithoutSsn = "KYC_WITHOUT_SSN"
}

enum VerificationStatus: Hashable {
    case none
    case emailPending
    case email
    case levelOne
    case levelTwo(Kyc2)
    
    var hasKYCLevelTwo: Bool {
        switch self {
        case .levelTwo(.levelTwo), .levelTwo(.kycWithSsn), .levelTwo(.kycWithoutSsn):
            return true
            
        default:
            return false
        }
    }
    
    var hasKYC: Bool {
        switch self {
        case .levelOne, .levelTwo:
            return true
            
        default:
            return false
        }
    }
    
    var value: String {
        switch self {
        case .none: return "DEFAULT"
        case .emailPending: return "EMAIL_VERIFICATION_PENDING"
        case .email: return "EMAIL_VERIFIED"
        case .levelOne: return "KYC1"
        case .levelTwo(let kyc2): return kyc2.rawValue
        }
    }

    init(rawValue: String?) {
        switch rawValue?.uppercased() {
        case "DEFAULT": self = .none
        case "EMAIL_VERIFICATION_PENDING": self = .emailPending
        case "EMAIL_VERIFIED": self = .email
        case "KYC1": self = .levelOne
        
        default:
            let kyc2 = Kyc2.init(rawValue: rawValue?.uppercased() ?? "")
            if let kyc2 = kyc2 {
                self = .levelTwo(kyc2)
            } else {
                self = .none
            }
        }
    }
    
    var title: String {
        switch self {
        case .levelOne, .levelTwo(.levelTwo): return L10n.Account.verified
        case .levelTwo(.declined): return L10n.Account.declined
        case .levelTwo(.resubmit), .levelTwo(.expired): return L10n.Account.resubmit
        default: return L10n.Account.pending
        }
    }
    
    static func > (lhs: VerificationStatus, rhs: VerificationStatus) -> Bool {
        switch (lhs, rhs) {
        case (.levelTwo(let lhs1), .levelTwo(let lhs2)):
            return lhs1 == lhs2
        default:
            return false
        }
    }
    
    var viewModel: InfoViewModel? {
        let profile = UserManager.shared.profile
        let canUseAch = profile?.kycAccessRights.hasAchAccess ?? false
        let swapAllowanceDaily = ExchangeFormatter.current.string(for: profile?.swapAllowanceDaily) ?? ""
        let buyAllowanceWeekly = ExchangeFormatter.current.string(for: profile?.buyAllowanceWeekly) ?? ""
        let sellAllowanceWeekly = ExchangeFormatter.current.string(for: profile?.sellAchAllowanceWeekly) ?? ""
        
        switch self {
        case .none, .email, .levelOne, .levelTwo(.notStarted), .levelTwo(.kycInfoProvided):
            return InfoViewModel(kyc: .levelOne, headerTitle: .text(L10n.VerifyAccount.verifyYourIdentity),
                                 headerTrailing: .init(image: Asset.info.image),
                                 status: VerificationStatus.none,
                                 description: .text(L10n.VerifyAccount.verifyIdentityText),
                                 button: .init(title: L10n.VerifyAccount.verifyMyIdentity, isUnderlined: true),
                                 dismissType: .persistent)
            
        case .emailPending, .levelTwo(.submitted):
            return InfoViewModel(kyc: .levelOne, headerTitle: .text(L10n.Account.accountLimits),
                                 headerTrailing: .init(image: Asset.info.image),
                                 status: VerificationStatus.emailPending,
                                 description: .text(L10n.Account.verifiedAccountMessage),
                                 dismissType: .persistent)
        case .levelTwo(.levelTwo), .levelTwo(.kycWithSsn), .levelTwo(.kycWithoutSsn):
            return InfoViewModel(kyc: .levelTwo,
                                 headerTitle: .text(L10n.Account.accountStatus),
                                 headerTrailing: .init(image: Asset.info.image),
                                 status: VerificationStatus.levelTwo(.levelTwo),
                                 swapLimits: .text(L10n.Swap.swapLimit),
                                 buyLimits: .text(profile?.kycAccessRights.hasAchAccess ?? false ?
                                                  L10n.Account.buyLimitsPerPayment : L10n.Buy.buyLimit),
                                 sellLimits: .text(L10n.Account.sellLimits),
                                 swapLimitsValue: .init(title: .text(L10n.Account.daily),
                                                        value: .text("\(swapAllowanceDaily) \(Constant.usdCurrencyCode)")),
                                 buyDailyLimitsView: .init(title: .text(L10n.Account.weekly),
                                                           value: .text("\(buyAllowanceWeekly) \(Constant.usdCurrencyCode)")),
                                 sellLimitsView: .init(title: .text(L10n.Account.weekly),
                                                       value: .text("\(sellAllowanceWeekly) \(Constant.usdCurrencyCode)")),
                                 dismissType: .persistent,
                                 canUseAch: canUseAch)
        case .levelTwo(.expired), .levelTwo(.resubmit):
            return InfoViewModel(kyc: .levelTwo, headerTitle: .text(L10n.Account.accountLimits),
                                 headerTrailing: .init(image: Asset.info.image),
                                 status: VerificationStatus.levelTwo(.resubmit),
                                 description: .text(L10n.Account.dataIssues),
                                 button: .init(title: L10n.Account.verificationDeclined.uppercased()),
                                 dismissType: .persistent)
        case .levelTwo(.declined):
            return InfoViewModel(kyc: .levelTwo, headerTitle: .text(L10n.Account.accountLimits),
                                 headerTrailing: .init(image: Asset.info.image),
                                 status: VerificationStatus.levelTwo(.declined),
                                 description: .text(L10n.Account.dataIssues),
                                 button: .init(title: L10n.Account.verificationDeclined.uppercased()),
                                 dismissType: .persistent)
        }
    }
}

struct StatusViewConfiguration: Configurable {
    var title: LabelConfiguration?
    var background: BackgroundConfiguration?
}

struct VerificationConfiguration: Configurable {
    var shadow: ShadowConfiguration?
    var background: BackgroundConfiguration?
    var title: LabelConfiguration?
    var status: StatusViewConfiguration?
    var infoButton: ButtonConfiguration?
    var description: LabelConfiguration?
    var benefits: LabelConfiguration?
}

enum KYC: Hashable {
    case levelOne
    case levelTwo
    case veriff
}

struct VerificationViewModel: ViewModel {
    var kyc: KYC
    var title: LabelViewModel?
    var status: VerificationStatus
    var infoButton: ButtonViewModel?
    var description: LabelViewModel?
    var benefits: LabelViewModel?
    var buyBenefits: LabelViewModel?
    var isActive: Bool?
}

class VerificationView: FEView<VerificationConfiguration, VerificationViewModel> {
    
    private lazy var mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.medium.rawValue
        return view
    }()
    
    private lazy var headerStack: UIStackView = {
        let view = UIStackView()
        view.spacing = Margins.large.rawValue
        return view
    }()
    
    private lazy var headerLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var statusView: WrapperView<FELabel> = {
        let view = WrapperView<FELabel>()
        return view
    }()
    
    private lazy var headerInfoButton: FEButton = {
        let view = FEButton()
        return view
    }()
    
    private lazy var descriptionStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = Margins.small.rawValue
        
        return stack
    }()
    
    private lazy var statusImageView: WrapperView<FEImageView> = {
        let view = WrapperView<FEImageView>()
        view.wrappedView.setup(with: .init(.image(Asset.selected.image)))
        view.tintColor = Colors.primary
        return view
    }()
    
    private lazy var descriptionLabel: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var arrowImageView: WrapperView<FEImageView> = {
        let view = WrapperView<FEImageView>()
        view.wrappedView.setup(with: .init(.image(Asset.forward.image)))
        return view
    }()
    
    private lazy var benefitsLabel: WrapperView<FELabel>  = {
        let view = WrapperView<FELabel>()
        return view
    }()
    
    private lazy var buyBenefitsLabel: WrapperView<FELabel>  = {
        let view = WrapperView<FELabel>()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalTo(content.snp.margins)
        }
        content.setupCustomMargins(all: .large)
        
        mainStack.addArrangedSubview(headerStack)
        headerStack.addArrangedSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().priority(.low)
            make.height.equalTo(ViewSizes.large.rawValue)
        }
        
        headerStack.addArrangedSubview(statusView)
        statusView.setupCustomMargins(all: .small)
        statusView.content.setupCustomMargins(vertical: .zero, horizontal: .small)
        
        headerStack.addArrangedSubview(headerInfoButton)
        headerInfoButton.snp.makeConstraints { make in
            make.width.equalTo(headerInfoButton.snp.height)
        }
        
        mainStack.addArrangedSubview(descriptionStackView)
        descriptionStackView.addArrangedSubview(statusImageView)
        descriptionStackView.addArrangedSubview(descriptionLabel)
        descriptionStackView.addArrangedSubview(arrowImageView)
        descriptionLabel.snp.makeConstraints { make in
            make.height.equalTo(Margins.extraLarge.rawValue)
        }
        
        mainStack.addArrangedSubview(benefitsLabel)
        benefitsLabel.snp.makeConstraints { make in
            make.height.equalTo(Margins.huge.rawValue)
            make.width.equalToSuperview().inset(Margins.small.rawValue)
        }
        mainStack.addArrangedSubview(buyBenefitsLabel)
        buyBenefitsLabel.snp.makeConstraints { make in
            make.height.width.equalTo(benefitsLabel)
        }
        setupClearMargins()
    }
    
    override func configure(with config: VerificationConfiguration?) {
        guard let config = config else { return }
        
        super.configure(with: config)
        
        configure(background: config.background)
        configure(shadow: config.shadow)
        
        headerLabel.configure(with: config.title)
        headerInfoButton.configure(with: config.infoButton)
        
        statusView.wrappedView.configure(with: config.status?.title)
        statusView.configure(background: config.status?.background)

        descriptionLabel.configure(with: config.description)
        benefitsLabel.wrappedView.configure(with: config.benefits)
        buyBenefitsLabel.wrappedView.configure(with: config.benefits)
    }
    
    override func setup(with viewModel: VerificationViewModel?) {
        guard let viewModel = viewModel else { return }

        super.setup(with: viewModel)
        
        headerLabel.setup(with: viewModel.title)
        headerInfoButton.setup(with: viewModel.infoButton)
        headerInfoButton.isHidden = viewModel.infoButton == nil
        statusImageView.isHidden = viewModel.infoButton != nil
        arrowImageView.isHidden = viewModel.infoButton != nil
        statusView.wrappedView.setup(with: .text(viewModel.status.title))
        statusView.isHidden = viewModel.status == VerificationStatus.none
        
        // If level 1 was done, but we present level 2, status is hidden
        if viewModel.status == .levelOne,
           viewModel.kyc == .levelTwo {
            statusView.isHidden = true
        }
        
        descriptionLabel.setup(with: viewModel.description)
        descriptionLabel.isHidden = viewModel.description == nil
        
        benefitsLabel.wrappedView.setup(with: viewModel.benefits)
        benefitsLabel.isHidden = viewModel.benefits == nil
        
        buyBenefitsLabel.wrappedView.setup(with: viewModel.buyBenefits)
        buyBenefitsLabel.isHidden = viewModel.buyBenefits == nil
        
        let backgroundConfiguration: BackgroundConfiguration? = Presets.Background.Primary.tertiary.withBorder(border: Presets.Border.accountVerification)
        benefitsLabel.configure(background: backgroundConfiguration)
        buyBenefitsLabel.configure(background: backgroundConfiguration)
        
        let image: String
        
        switch viewModel.status {
        case .none, .email:
            image = Asset.selectedGray.name
            statusView.isHidden = true
            
        case .levelTwo(.declined),
                .levelTwo(.resubmit):
            image = Asset.errorIcon.name
            
        default:
            image = Asset.selected.name
        }
        
        statusImageView.wrappedView.setup(with: .init(.imageName(image)))
        statusImageView.backgroundColor = .clear
        statusImageView.wrappedView.backgroundColor = .clear
        
        guard let isActive = viewModel.isActive else { return }
        arrowImageView.tintColor = isActive ? Colors.Text.two : Colors.Disabled.one
    }
}
