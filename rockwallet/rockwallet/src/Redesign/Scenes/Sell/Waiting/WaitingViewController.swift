//
//  WaitingViewController.swift
//  breadwallet
//
//  Created by Dino Gacevic on 25/07/2023.
//
//

import UIKit
import Combine

class WaitingViewController: VIPViewController<ExchangeCoordinator,
                             WaitingInteractor,
                             WaitingPresenter,
                             WaitingStore>,
                             WaitingResponseDisplays {
    typealias Models = WaitingModels
    
    private let errorSubject = PassthroughSubject<String?, Never>()
    var errorPublisher: AnyPublisher<String?, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    private lazy var loader: FEImageView = {
        let imageView = FEImageView()
        imageView.setup(with: .animation(Animations.loader.animation, .loop))
        return imageView
    }()

    // MARK: - Overrides
    
    override var sceneLeftAlignedTitle: String? {
        return L10n.Sell.SsnInput.Title.checkingYourData
    }
    
    override func prepareData() {
        interactor?.updateSsn(viewAction: .init())
    }
    
    override func setupSubviews() {
        view.addSubview(loader)
        loader.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(ViewSizes.extralarge.rawValue)
        }
    }

    // MARK: - User Interaction

    // MARK: - WaitingResponseDisplay
    
    func displayUpdateSsn(responseDisplay: WaitingModels.UpdateSsn.ResponseDisplay) {
        guard let error = responseDisplay.error else {
            Store.trigger(name: .showSell)
            return
        }
        
        errorSubject.send(error)
        self.coordinator?.popViewController()
    }

    // MARK: - Additional Helpers
}
