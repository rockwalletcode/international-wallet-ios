//
//  AuthenticatorAppPresenter.swift
//  breadwallet
//
//  Created by Dijana Angelovska on 29.3.23.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

final class AuthenticatorAppPresenter: NSObject, Presenter, AuthenticatorAppActionResponses {
    typealias Models = AuthenticatorAppModels

    weak var viewController: AuthenticatorAppViewController?
    
    // MARK: - AuthenticatorAppActionResponses
    
    func presentData(actionResponse: FetchModels.Get.ActionResponse) {
        guard let item = actionResponse.item as? SetTwoStepAuth else { return }
        
        let sections: [Models.Section] = [
            .importWithLink,
            .divider,
            .instructions,
            .qrCode,
            .enterCodeManually,
            .copyCode
        ]
        
        let code = item.code
        let codeFormatted = code.separated(stride: 4)
        let url = item.url
        
        let sectionRows: [Models.Section: [any Hashable]] = [
            .importWithLink: [
                TitleButtonViewModel(title: .text(L10n.TwoStep.App.Import.title),
                                     button: .init(title: L10n.TwoStep.App.Import.action, isUnderlined: true))
            ],
            .divider: [
                LabelViewModel.text(L10n.CommonString.Or.label.uppercased())
            ],
            .instructions: [
                LabelViewModel.text(L10n.Authentication.instructions)
            ],
            .qrCode: [
                PaddedImageViewModel(image: .image(generateQRCode(from: url)))
            ],
            .enterCodeManually: [
                LabelViewModel.attributedText(prepareEnterCodeText())
            ],
            .copyCode: [
                OrderViewModel(title: "",
                               value: CopyTextIcon.generate(with: codeFormatted,
                                                            isCopyable: true),
                               isCopyable: true)
            ]
        ]
        
        viewController?.displayData(responseDisplay: .init(sections: sections, sectionRows: sectionRows))
    }
    
    func presentNext(actionResponse: AuthenticatorAppModels.Next.ActionResponse) {
        viewController?.displayNext(responseDisplay: .init())
    }
    
    func presentOpenTotpUrl(actionResponse: AuthenticatorAppModels.OpenTotpUrl.ActionResponse) {
        guard let urlString = actionResponse.url, let url = URL(string: urlString) else { return }
        
        viewController?.displayOpenTotpUrl(responseDisplay: .init(url: url))
    }
    
    // MARK: - Additional Helpers
    
    private func generateQRCode(from string: String) -> UIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        
        let data = string.data(using: .utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        let transform = CGAffineTransform(scaleX: 30, y: 30)
        
        guard let qrImage = filter.outputImage?.transformed(by: transform) else { return nil }
        
        return UIImage(ciImage: qrImage)
    }
    
    private func prepareEnterCodeText() -> NSMutableAttributedString {
        let partOneAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: LightColors.Text.three,
            NSAttributedString.Key.backgroundColor: UIColor.clear,
            NSAttributedString.Key.font: Fonts.Subtitle.two]
        let partTwoAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: LightColors.Text.three,
            NSAttributedString.Key.backgroundColor: UIColor.clear,
            NSAttributedString.Key.font: Fonts.Body.two]
        
        let partOne = NSMutableAttributedString(string: L10n.Authentication.unableToScanCode + "\n", attributes: partOneAttributes)
        let partTwo = NSMutableAttributedString(string: L10n.Authentication.enterCodeManually, attributes: partTwoAttributes)
        let combined = NSMutableAttributedString()
        combined.append(partOne)
        combined.append(partTwo)
        
        return combined
    }
}
