// 
//  ImageView.swift
//  breadwallet
//
//  Created by Rok on 10/05/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Lottie
import UIKit

extension LottieAnimation: Hashable {
    public static func == (lhs: LottieAnimation, rhs: LottieAnimation) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension LottieLoopMode: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .playOnce:
            break
        case .loop:
            break
        case .autoReverse:
            break
        case .repeat(let value):
            hasher.combine(value)
        case .repeatBackwards(let value):
            hasher.combine(value)
        }
    }
}

enum ImageViewModel: ViewModel {
    case animation(LottieAnimation?, LottieLoopMode?)
    case imageName(String?)
    case image(UIImage?)
    case photo(UIImage?)
    case url(String?)
}

class FEImageView: FEView<BackgroundConfiguration, ImageViewModel> {
    override var contentMode: UIView.ContentMode {
        get { return imageView.contentMode }
        set { imageView.contentMode = newValue }
    }
    
    // MARK: Lazy UI
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var animationView: LottieAnimationView = {
        let view = LottieAnimationView(frame: .zero)
        view.clipsToBounds = true
        view.backgroundBehavior = .pauseAndRestore
        view.isHidden = true
        return view
    }()
    
    // MARK: - View setup
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        content.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        content.setupClearMargins()
    }
    
    // MARK: ViewModelable
    
    public override func setup(with viewModel: ImageViewModel?) {
        super.setup(with: viewModel)
        
        switch viewModel {
        case .photo(let image):
            imageView.isHidden = false
            imageView.image = image
            layoutViews(image: image)
            
        case .image(let image):
            imageView.isHidden = false
            imageView.image = image
            
        case .imageName(let name):
            imageView.isHidden = false
            imageView.image = .init(named: name ?? "")
            
        case .animation(let animation, let playMode):
            animationView.isHidden = false
            animationView.animation = animation
            animationView.loopMode = playMode ?? .playOnce
            animationView.play()
            
        default:
            prepareForReuse()
            return
        }
        
        imageView.tintColor = config?.tintColor
        animationView.tintColor = config?.tintColor
        
        layoutIfNeeded()
    }
    
    private func layoutViews(image: UIImage?) {
        guard let image = image else { return }
        
        var imageAspectRatio = image.size.height / image.size.width
        if imageAspectRatio >= 1.5 {
            imageAspectRatio = 1.5
        }
        
        imageView.snp.makeConstraints { make in
            make.height.equalTo(self.imageView.snp.width).multipliedBy(imageAspectRatio)
        }
        
        imageView.layoutIfNeeded()
        layoutIfNeeded()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        imageView.isHidden = true
        animationView.isHidden = true
    }
}
