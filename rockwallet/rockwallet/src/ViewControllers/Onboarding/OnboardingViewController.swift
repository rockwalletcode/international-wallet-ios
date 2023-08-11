//
//  OnboardingViewController.swift
//  breadwallet
//
//  Created by Ray Vander Veen on 2018-10-30.
//  Copyright © 2018-2019 Breadwinner AG. All rights reserved.
//

import UIKit
import AVKit

// swiftlint:disable type_body_length

enum OnboardingExitAction {
    case restoreWallet
    case createWallet
    case restoreCloudBackup
}

typealias DidExitOnboardingWithAction = ((OnboardingExitAction) -> Void)

struct OnboardingPage {
    var heading: String
    var subheading: String
}

/**
 *  Takes the user through a sequence of onboarding screens (product walkthrough)
 *  and allows the user to either create a new wallet or restore an existing wallet.
 */
class OnboardingViewController: UIViewController {
    
    // This callback is passed in by the StartFlowPresenter so that actions within 
    // the onboarding screen can be directed to other functions of the app, such as wallet
    // restoration, PIN creation, etc.
    private var didExitWithAction: DidExitOnboardingWithAction?
    
    private let logoImageView: UIImageView = .init(image: Asset.logoVerticalWhite.image)
    
    private var showingLogo: Bool = false {
        didSet {
            let alpha: CGFloat = showingLogo ? 1 : 0
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: { 
                self.logoImageView.alpha = alpha
            }, completion: nil)
        }
    }
    
    // page content
    var pages: [OnboardingPage] = [OnboardingPage]()
    
    // controls how far the heading/subheading labels animate up from the constraint anchor
    var fadeInOffsetFactors: [CGFloat] = [2.0, 2.0, 3.0, 2.0]
    
    let firstTransitionDelay: TimeInterval = 1.2
    
    // Heading and subheading labels and the constraints used to animate them.
    var headingLabels: [UILabel] = [UILabel]()
    var subheadingLabels: [UILabel] = [UILabel]()    
    var headingConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    var subheadingConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    
    let headingLabelAnimationOffset: CGFloat = 60
    let subheadingLabelAnimationOffset: CGFloat = 30
    let headingSubheadingMargin: CGFloat = 22
    private var iconImageViews = [UIImageView]()
    
    var headingInset: CGFloat = Margins.extraExtraHuge.rawValue
    var subheadingInset: CGFloat {
        return headingInset - 10
    }
    
    // Used to ensure we only animate the landing page on the first appearance.
    var appearanceCount: Int = 0
    
    let pageCount: Int = 3
    
    let globePageIndex = 1
    let coinsPageIndex = 2
    let finalPageIndex = 3
    
    // Whenever we're animating from page to page this is set to true
    // to prevent additional taps on the Next button during the transition.
    
    var pageIndex: Int = 0 {
        didSet {
            // Show/hide the Back and Skip buttons.
            let backAlpha: CGFloat = (pageIndex == 1) ? 1.0 : 0.0
            let delay = (pageIndex == 1) ? firstTransitionDelay : 0.0
            
            UIView.animate(withDuration: 0.3, delay: delay, options: .curveEaseIn, animations: { 
                self.backButton.alpha = backAlpha
            }, completion: nil)
        }
    }
    
    var lastPageIndex: Int { return pageCount - 1 }
    
    // CTA's that appear at the bottom of the screen
    private let createWalletButton = BRDButton(title: "", type: .secondary)
    private let recoverButton = BRDButton(title: "", type: .underlined)
    private let restoreWithiCloudButton = BRDButton(title: L10n.CloudBackup.restoreButton.uppercased(), type: .tertiary)
    
    // Constraints used to show and hide the bottom buttons.
    private var topButtonAnimationConstraint: NSLayoutConstraint?
    private var middleButtonAnimationConstraint: NSLayoutConstraint?
    private var bottomButtonAnimationConstraint: NSLayoutConstraint?
    private var nextButtonAnimationConstraint: NSLayoutConstraint?
    
    private let backButton = UIButton(type: .custom)
    
    private let cloudBackupExists: Bool
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.extraExtraHuge.rawValue
        return view
    }()
    
    private let restoreWalletTitle: UILabel = {
        let label = UILabel.wrapping(font: Fonts.Title.four, color: LightColors.Contrast.two)
        label.text = L10n.Onboarding.restoreYourWallet
        label.textAlignment = .center
        return label
    }()
    
    private let restoreWalletDescription: UILabel = {
        let label = UILabel.wrapping(font: Fonts.Body.one, color: LightColors.Contrast.two)
        label.text = L10n.Onboarding.restoreYourWalletDescription
        label.textAlignment = .center
        return label
    }()
    
    private lazy var illustration: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = Asset.unlockWalletDisabled.image
        return imageView
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.extraExtraHuge.rawValue
        return view
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if appearanceCount == 0 {
            animateLandingPage()
        }
        
        appearanceCount += 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Make sure we set this in case the user taps Restore Wallet, then comes
        // back to the onboarding flow in case the nav bar hidden status is changed.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = LightColors.Contrast.one
        
        setUpLogo()
        setUpPages()
        setupSubviews()
    }
    
    private func setupSubviews() {
        setUpHeadingLabels()
        setUpBottomButtons()
        addBackButton()
        setUpSecondView()
    }
    
    required init(doesCloudBackupExist: Bool, didExitOnboarding: DidExitOnboardingWithAction?) {
        self.cloudBackupExists = doesCloudBackupExist
        super.init(nibName: nil, bundle: nil)
        didExitWithAction = didExitOnboarding
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func exitWith(action exitAction: OnboardingExitAction) {
        didExitWithAction?(exitAction)
    }
    
    private func reset(completion: @escaping () -> Void) {
        
        for (index, constraint) in self.headingConstraints.enumerated() {
            constraint.constant = (index == 0) ? 0 : -(headingLabelAnimationOffset)
        }
        
        self.subheadingConstraints.forEach { $0.constant = headingSubheadingMargin }
        self.headingLabels.forEach { $0.alpha = 0 }
        self.subheadingLabels.forEach { $0.alpha = 0 }
        
        view.layoutIfNeeded()
        
        self.pageIndex = 0
        
        self.createWalletButton.title = createWalletButtonText(pageIndex: 0)
        
        completion()        
    }
    
    private func setUpLogo() {
        logoImageView.alpha = 0
        view.addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(ViewSizes.extralarge.rawValue * 2)
        }
    }
    
    private func setUpPages() {
        pages.append(OnboardingPage(heading: L10n.Onboarding.description,
                                    subheading: ""))
        
        pages.append(OnboardingPage(heading: L10n.OnboardingPageTwo.title,
                                    subheading: ""))
        
        pages.append(OnboardingPage(heading: L10n.OnboardingPageThree.title,
                                    subheading: L10n.OnboardingPageThree.subtitle))
    }
    
    private func makeHeadingLabel(text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        
        label.alpha = 0
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = color
        label.font = font
        label.text = text
        
        return label
    }
    
    private func setUpHeadingLabels() {
        
        for (index, page) in pages.enumerated() {
            
            // create the headings
            let headingLabel = makeHeadingLabel(text: page.heading, 
                                                font: Fonts.Title.six,
                                                color: LightColors.Contrast.two)
            view.addSubview(headingLabel)
            
            let offset: CGFloat = (index == 0) ? 0 : -(self.headingLabelAnimationOffset)
            var animationConstraint = headingLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, 
                                                                            constant: offset)
            var leading = headingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, 
                                                                constant: headingInset)
            var trailing = headingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                                  constant: -(headingInset))
            let top = headingLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor,
                                                        constant: Margins.huge.rawValue * 2)
            
            headingLabel.constrain([leading, trailing, top])
            
            headingConstraints.append(animationConstraint)
            headingLabels.append(headingLabel)
            
            // create the subheadings
            let subheadingLabel = makeHeadingLabel(text: page.subheading, 
                                                   font: Fonts.Subtitle.two,
                                                   color: LightColors.Contrast.two)
            view.addSubview(subheadingLabel)
            
            animationConstraint = subheadingLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, 
                                                                       constant: headingSubheadingMargin)
            leading = subheadingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, 
                                                               constant: subheadingInset)
            trailing = subheadingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, 
                                                                 constant: -(subheadingInset))
            
            subheadingLabel.constrain([animationConstraint, leading, trailing])
            
            subheadingConstraints.append(animationConstraint)
            subheadingLabels.append(subheadingLabel)
        }
    }
    
    private func createWalletButtonText(pageIndex: Int) -> String {
        guard pageIndex == 0 else {
            return L10n.Onboarding.restoreWallet.uppercased()
        }
        return L10n.CloudBackup.createButton
    }
    
    private func recoverButtonText(pageIndex: Int) -> String {
        return L10n.CloudBackup.recoverButton
    }
    
    private func restoreButtonText(pageIndex: Int) -> String {
        if cloudBackupExists {
            return L10n.CloudBackup.restoreButton
        } else {
            return L10n.Onboarding.restoreWallet
        }
    }
    
    let buttonHeight: CGFloat = 48.0
    let buttonsVerticalMargin: CGFloat = 12.0
    let bottomButtonBottomMargin: CGFloat = 10.0
    let nextButtonBottomMargin: CGFloat = 20.0
    
    private var buttonsHiddenYOffset: CGFloat {
        return (buttonHeight + 40.0)
    }
    
    private var bottomButtonVisibleYOffset: CGFloat {
        return -buttonsVerticalMargin
    }
    
    private var middleButtonVisibleYOffset: CGFloat {
        return -(buttonsVerticalMargin*2 + buttonHeight)
    }
    
    private var topButtonVisibleYOffset: CGFloat {
        if cloudBackupExists {
            return middleButtonVisibleYOffset - (buttonsVerticalMargin + buttonHeight)
        } else {
            return middleButtonVisibleYOffset
        }
    }
    
    private var nextButtonVisibleYOffset: CGFloat {
        return -nextButtonBottomMargin
    }
    
    private func setUpSecondView() {
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).inset(-Margins.extraHuge.rawValue)
            make.leading.trailing.equalToSuperview().inset(Margins.extraExtraHuge.rawValue)
        }
        
        stackView.addArrangedSubview(restoreWalletTitle)
        stackView.addArrangedSubview(restoreWalletDescription)
        
        stackView.addArrangedSubview(illustration)
        illustration.snp.makeConstraints { make in
            make.height.width.equalTo(ViewSizes.extraExtraHuge.rawValue)
        }
        
        if !cloudBackupExists {
            restoreWithiCloudButton.removeFromSuperview()
        }
        
        stackView.isHidden = true
        restoreWithiCloudButton.isHidden = true
    }
    
    private func setUpBottomButtons() {
        // Set the buttons up for the first page; the title text will be updated
        // once we reach the last page of the onboarding flow.
        createWalletButton.title = createWalletButtonText(pageIndex: 0)
        recoverButton.title = recoverButtonText(pageIndex: 0)
        
        let buttonLeftRightMargin: CGFloat = Margins.large.rawValue
        let buttonHeight: CGFloat = ViewSizes.Common.largeCommon.rawValue
        
        middleButtonAnimationConstraint = createWalletButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                                                     constant: buttonsHiddenYOffset)
        bottomButtonAnimationConstraint = recoverButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                                                constant: buttonsHiddenYOffset)
        
        view.addSubview(createWalletButton)
        createWalletButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(buttonLeftRightMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(buttonsHiddenYOffset)
            make.height.equalTo(buttonHeight)
        }
        
        view.addSubview(recoverButton)
        recoverButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(createWalletButton.snp.bottom).inset(-Margins.small.rawValue)
            make.leading.trailing.equalToSuperview().inset(buttonLeftRightMargin)
            make.height.equalTo(buttonHeight)
        }
        
        view.addSubview(restoreWithiCloudButton)
        restoreWithiCloudButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(createWalletButton.snp.bottom).inset(-Margins.small.rawValue)
            make.leading.trailing.equalToSuperview().inset(buttonLeftRightMargin)
            make.height.equalTo(buttonHeight)
        }
        
        createWalletButton.tap = { [unowned self] in
            self.createWalletTapped()
        }
        
        recoverButton.tap = { [unowned self] in
            self.restoreButtonTapped()
        }
        
        restoreWithiCloudButton.tap = { [unowned self] in
            self.restoreButtonTapped()
        }
    }
    
    private func addBackButton() {
        let image = Asset.backWhite.image
        
        backButton.alpha = 0
        
        backButton.setImage(image, for: .normal)
        backButton.addTarget(self, action: #selector(backTapped(sender:)), for: .touchUpInside)
        
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(Margins.small.rawValue)
            make.leading.equalToSuperview().inset(Margins.large.rawValue)
            make.height.width.equalTo(ViewSizes.small.rawValue)
        }
    }
    
    private func animateLandingPage() {
        
        let delay = 0.2
        let duration = 0.3//0.5
        
        // animate heading position
        let constraint = headingConstraints[0]
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            constraint.constant = -(self.headingLabelAnimationOffset)
        })            
        
        // animate heading fade-in
        let label = headingLabels[0]
        UIView.animate(withDuration: duration + 0.2, delay: delay * 2.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            label.alpha = 1
        })            
        
        createWalletButton.alpha = 0
        recoverButton.alpha = 0
        logoImageView.isHidden = true
        headingLabels.first?.isHidden = true
        stackView.isHidden = false
        restoreWithiCloudButton.isHidden = false
        
        // fade-in animation for the buttons
        UIView.animate(withDuration: (duration * 1.5), delay: (delay * 2.0), options: UIView.AnimationOptions.curveEaseIn, animations: { 
            self.createWalletButton.alpha = 1
            self.recoverButton.alpha = 1
            self.logoImageView.isHidden = false
            self.headingLabels.first?.isHidden = false
            self.stackView.isHidden = true
            self.restoreWithiCloudButton.isHidden = true
            
            self.createWalletButton.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(self.buttonsHiddenYOffset)
            }
        })
        
        // slide-up animation for the top button
        UIView.animate(withDuration: (duration * 1.5), delay: delay, options: UIView.AnimationOptions.curveEaseInOut, animations: { 
            self.topButtonAnimationConstraint?.constant = self.topButtonVisibleYOffset
            self.view.layoutIfNeeded()
        })
        
        if self.cloudBackupExists {
            middleButtonAnimationConstraint?.constant = (buttonsVerticalMargin * 2.0)
            view.layoutIfNeeded()
            
            // slide-up animation for the middle button
            UIView.animate(withDuration: (duration * 1.5), delay: delay * 1.5, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.middleButtonAnimationConstraint?.constant = self.middleButtonVisibleYOffset
                self.view.layoutIfNeeded()
            })
        }
        
        bottomButtonAnimationConstraint?.constant = (buttonsVerticalMargin * 3.0)
        view.layoutIfNeeded()
        
        // slide-up animation for the bottom button
        UIView.animate(withDuration: (duration * 1.5), delay: (delay * 2.0), options: UIView.AnimationOptions.curveEaseInOut, animations: { 
            // animate the bottom button up to its correct offset relative to the top button
            self.bottomButtonAnimationConstraint?.constant = self.bottomButtonVisibleYOffset
            self.view.layoutIfNeeded()
        })
        
        UIView.animate(withDuration: duration * 2.0, delay: delay * 3.0, options: .curveEaseInOut) {
            self.logoImageView.alpha = 1
        }
    }
    
    // MARK: - User Interaction
    @objc private func backTapped(sender: Any) {
        let headingLabel = headingLabels[pageIndex]
        let subheadingLabel = subheadingLabels[pageIndex]
        let headingConstraint = headingConstraints[pageIndex]
        
        UIView.animate(withDuration: 0.4, animations: {
            // make sure next or top/bottom buttons are animated out
            self.topButtonAnimationConstraint?.constant = self.buttonsHiddenYOffset
            self.nextButtonAnimationConstraint?.constant = self.buttonsHiddenYOffset
            
            headingLabel.alpha = 0
            subheadingLabel.alpha = 0
            headingConstraint.constant -= (self.headingLabelAnimationOffset)
            
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.reset(completion: {
                self.animateLandingPage()
            })
        })
    }
    
    private func restoreWithPhraseButtonTapped() {
        stackView.isHidden = false
        restoreWithiCloudButton.isHidden = false
        logoImageView.isHidden = true
        headingLabels.first?.isHidden = true
        backButton.alpha = 1.0
        recoverButton.alpha = 0.0
        pageIndex = 1
        createWalletButton.title = createWalletButtonText(pageIndex: pageIndex)
        
        if !cloudBackupExists {
            createWalletButton.snp.updateConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Margins.large.rawValue)
            }
        }
    }
    
    private func createWalletTapped() {
        guard pageIndex == 0 else {
            showAlert(message: L10n.CloudBackup.recoverWarning,
                      button: L10n.CloudBackup.recoverButton,
                      completion: { [weak self] in
                self?.exitWith(action: .restoreWallet)
            })
            return
        }
        exitWith(action: .createWallet)
    }
    
    private func restoreButtonTapped() {
        guard pageIndex == 1 else {
            restoreWithPhraseButtonTapped()
            return
        }
        exitWith(action: .restoreCloudBackup)
    }
    
    private func showAlert(message: String, button: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: L10n.Alert.warning,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Button.cancel, style: .cancel, handler: {_ in }))
        alert.addAction(UIAlertAction(title: button, style: .default, handler: {_ in
            completion()
        }))
        present(alert, animated: true, completion: nil)
    }
}
// swiftlint:enable type_body_length
