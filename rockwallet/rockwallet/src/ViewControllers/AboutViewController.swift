// 
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    private lazy var aboutHeaderView: UIImageView = {
        let logo = UIImageView()
        logo.image = Asset.logoVertical.image
        
        return logo
    }()
    
    private lazy var aboutFooterView: UILabel = {
        let aboutFooterView = UILabel.wrapping(font: Fonts.Body.two, color: Colors.Text.two)
        aboutFooterView.translatesAutoresizingMaskIntoConstraints = false
        
        let aboutFooterStyle = NSMutableParagraphStyle()
        aboutFooterStyle.lineSpacing = 5.0
        aboutFooterStyle.alignment = .center
        let attributes = [NSAttributedString.Key.paragraphStyle: aboutFooterStyle]
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            aboutFooterView.attributedText = NSAttributedString(string: L10n.About.footer(version, build), attributes: attributes)
        }
        
        return aboutFooterView
    }()
    
    private lazy var termsAndPrivacyStack: UIStackView = {
        let view = UIStackView()
        view.spacing = Margins.large.rawValue
        return view
    }()
    
    private lazy var privacy: UIButton = {
        let button = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.underlineStyle: 1,
        NSAttributedString.Key.font: Fonts.Subtitle.two,
        NSAttributedString.Key.foregroundColor: Colors.secondary]
        
        let attributedString = NSMutableAttributedString(string: L10n.About.privacy, attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        
        return button
    }()
    
    private lazy var terms: UIButton = {
        let button = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.underlineStyle: 1,
        NSAttributedString.Key.font: Fonts.Subtitle.two,
        NSAttributedString.Key.foregroundColor: Colors.secondary]
        
        let attributedString = NSMutableAttributedString(string: L10n.About.terms, attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        
        return button
    }()
    
    private lazy var termsPro: UIButton = {
        let button = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.underlineStyle: 1,
        NSAttributedString.Key.font: Fonts.Subtitle.two,
        NSAttributedString.Key.foregroundColor: Colors.secondary]
        
        let attributedString = NSMutableAttributedString(string: L10n.About.termsAndConditionsPro, attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = L10n.About.title
        
        addSubviews()
        addConstraints()
        setActions()
        
        view.backgroundColor = Colors.Background.one
        
        GoogleAnalytics.logEvent(GoogleAnalytics.About())
    }

    private func addSubviews() {
        view.addSubview(aboutHeaderView)
        view.addSubview(termsAndPrivacyStack)
        termsAndPrivacyStack.addArrangedSubview(terms)
        termsAndPrivacyStack.addArrangedSubview(privacy)
        view.addSubview(termsPro)
        view.addSubview(aboutFooterView)
    }

    private func addConstraints() {
        aboutHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(ViewSizes.extraExtraHuge.rawValue * 2)
            make.centerX.equalToSuperview()
            make.width.equalTo(213)
        }
        
        termsAndPrivacyStack.snp.makeConstraints { make in
            make.top.equalTo(aboutHeaderView.snp.bottom).offset(Margins.extraLarge.rawValue)
            make.centerX.equalToSuperview()
        }
        
        termsPro.snp.makeConstraints { make in
            make.top.equalTo(termsAndPrivacyStack.snp.bottom).offset(Margins.small.rawValue)
            make.leading.trailing.equalToSuperview().inset(Margins.medium.rawValue)
        }
        
        aboutFooterView.snp.makeConstraints { make in
            make.top.equalTo(termsPro.snp.bottom).offset(Margins.medium.rawValue)
            make.leading.trailing.equalToSuperview().inset(Margins.huge.rawValue)
        }
    }
    
    private func setActions() {
        privacy.tap = { [weak self] in
            self?.presentURL(string: Constant.privacyPolicy, title: self?.privacy.titleLabel?.text ?? "")
        }
        
        terms.tap = { [weak self] in
            self?.presentURL(string: Constant.termsAndConditions, title: self?.terms.titleLabel?.text ?? "")
        }
        
        termsPro.tap = { [weak self] in
            self?.presentURL(string: Constant.termsAndConditions, title: self?.terms.titleLabel?.text ?? "")
        }
    }

    private func presentURL(string: String, title: String) {
        guard let url = URL(string: string) else { return }
        let webViewController = SimpleWebViewController(url: url)
        webViewController.setup(with: .init(title: title))
        let navController = RootNavigationController(rootViewController: webViewController)
        webViewController.setAsNonDismissableModal()
        
        navigationController?.present(navController, animated: true)
    }
}
