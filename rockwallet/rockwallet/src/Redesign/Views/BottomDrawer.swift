//
//  BottomDrawer.swift
//  breadwallet
//
//  Created by Rok on 07/12/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import Combine
import UIKit
import SnapKit

struct DrawerConfiguration: Configurable {
    var background = BackgroundConfiguration(backgroundColor: LightColors.Background.two)
    var titleConfig = LabelConfiguration(font: Fonts.Subtitle.one,
                                         textColor: LightColors.secondary,
                                         textAlignment: .center)
    var descriptionConfig = LabelConfiguration(font: Fonts.Body.two,
                                               textColor: LightColors.Text.one,
                                               textAlignment: .center)
    var buttons: [ButtonConfiguration] = []
}

struct DrawerViewModel: ViewModel {
    var title: LabelViewModel?
    var description: LabelViewModel?
    var buttons: [ButtonViewModel] = []
    var notice: ButtonViewModel?
    var onView: UIView?
    var bottomInset: CGFloat = 0
}

class BottomDrawer: FEView<DrawerConfiguration, DrawerViewModel>, UIGestureRecognizerDelegate {
    var callbacks: [(() -> Void)] = []
    var isShown: Bool { return containerView.alpha == 1 }
    
    static var bottomToolbarHeight = 84.0
    
    private let dismissActionSubject = PassthroughSubject<Void, Never>()
    var dismissActionPublisher: AnyPublisher<Void, Never> {
        dismissActionSubject.eraseToAnyPublisher()
    }
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.alpha = 0.0
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0.94
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var drawer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = CornerRadius.large.rawValue
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        return view
    }()
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = Margins.huge.rawValue
        return view
    }()
    
    private lazy var grabberImage: FEImageView = {
        let view = FEImageView()
        view.setup(with: .image(Asset.dragControl.image))
        return view
    }()
    
    private lazy var title: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var notice: WrapperView<FEImageView> = {
        let view = WrapperView<FEImageView>()
        view.wrappedView.setupCustomMargins(all: .extraSmall)
        return view
    }()
    
    private lazy var popupDescription: FELabel = {
        let view = FELabel()
        return view
    }()
    
    private lazy var buttonStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = Margins.small.rawValue
        view.distribution = .fillEqually
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        isUserInteractionEnabled = false
        
        (viewModel?.onView ?? UIApplication.shared.activeWindow)?.addSubview(containerView)
        
        containerView.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        content.addSubview(drawer)
        drawer.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        drawer.addSubview(stack)
        
        stack.addArrangedSubview(grabberImage)
        grabberImage.snp.makeConstraints { make in
            make.height.equalTo(Margins.extraSmall.rawValue)
            make.width.equalTo(ViewSizes.extralarge.rawValue)
        }
        
        stack.addArrangedSubview(title)
        title.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.small.rawValue)
        }
        
        stack.addArrangedSubview(notice)
        notice.snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.medium.rawValue)
            make.width.equalTo(164).priority(.high)
        }
        
        stack.addArrangedSubview(popupDescription)
        
        stack.addArrangedSubview(buttonStack)
        buttonStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onDrag(_:)))
        panGesture.delegate = self
        drawer.addGestureRecognizer(panGesture)
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(outsideTapped(_:))))
        grabberImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(outsideTapped(_:))))
    }
    
    override func configure(with config: DrawerConfiguration?) {
        guard let config = config else { return }
        super.configure(with: config)
        
        title.configure(with: config.titleConfig)
        popupDescription.configure(with: config.descriptionConfig)
        
        let noticeConfig = BackgroundConfiguration(backgroundColor: LightColors.purpleMuted,
                                                   tintColor: LightColors.instantPurple,
                                                   border: BorderConfiguration(tintColor: .clear,
                                                                               borderWidth: 0,
                                                                               cornerRadius: .fullRadius))
        notice.configure(background: noticeConfig)
        
        drawer.backgroundColor = config.background.backgroundColor
        content.backgroundColor = nil
    }
    
    override func setup(with viewModel: DrawerViewModel?) {
        guard let viewModel = viewModel, let config = config else { return }
        
        super.setup(with: viewModel)
        
        title.setup(with: viewModel.title)
        title.isHidden = viewModel.title == nil
        
        popupDescription.setup(with: viewModel.description)
        popupDescription.isHidden = viewModel.description == nil
        
        if let noticeModel = viewModel.notice, let image = noticeModel.image, let title = noticeModel.title {
            let image = UIImage.textEmbeded(image: image,
                                            string: title,
                                            isImageBeforeText: true,
                                            tintColor: LightColors.instantPurple)
            notice.wrappedView.setup(with: .image(image))
        }
        
        notice.isHidden = viewModel.notice == nil
        
        (viewModel.onView ?? UIApplication.shared.activeWindow)?.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Margins.huge.rawValue)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(Margins.huge.rawValue)
            
            let inset = viewModel.bottomInset + UIDevice.current.bottomNotch
            make.bottom.equalToSuperview().inset(inset)
        }
        
        buttonStack.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        for ((vm, conf), callback) in zip(zip(viewModel.buttons, config.buttons), callbacks) {
            let button = FEButton()
            button.configure(with: conf)
            button.setup(with: vm)
            button.viewModel?.callback = { [weak self] in
                self?.hide()
                callback()
            }
            buttonStack.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.height.equalTo(ViewSizes.Common.largeCommon.rawValue)
            }
        }

        buttonStack.isHidden = viewModel.buttons.isEmpty
        
        content.layoutIfNeeded()
    }
    
    func show() {
        guard containerView.alpha == 0 else { return }
        
        isUserInteractionEnabled = true
        
        drawer.snp.removeConstraints()
        drawer.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        Self.animate(withDuration: Presets.Animation.average.rawValue) { [weak self] in
            self?.containerView.alpha = 1
            self?.drawer.layoutIfNeeded()
            self?.content.layoutIfNeeded()
            self?.layoutIfNeeded()
        }
    }
    
    func hide() {
        guard containerView.alpha == 1 else { return }
        
        isUserInteractionEnabled = false
        
        drawer.snp.removeConstraints()
        drawer.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        Self.animate(withDuration: Presets.Animation.average.rawValue) { [weak self] in
            self?.containerView.alpha = 0
            self?.drawer.layoutIfNeeded()
            self?.content.layoutIfNeeded()
            self?.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.drawer.transform = .identity
        }
    }
    
    func toggle() {
        if containerView.alpha == 0 {
            return show()
        } else {
            return hide()
        }
    }
    
    @objc private func outsideTapped(_ sender: UITapGestureRecognizer) {
        hide()
        
        dismissActionSubject.send()
    }
    
    @objc private func onDrag(_ sender: UIPanGestureRecognizer) {
        guard let draggedView = sender.view else { return }
        
        let translation = sender.translation(in: draggedView.superview)
        var drawerInitialY: Double = 0
        
        switch sender.state {
        case .began:
            // Store the original position of the view
            drawerInitialY = draggedView.frame.origin.y
            
        case .changed:
            // Prevent dragging the view higher than the initial frame
            let newY = max(drawerInitialY + translation.y, drawerInitialY)
            guard newY > drawerInitialY else {
                Self.animate(withDuration: Presets.Animation.long.rawValue,
                             delay: 0,
                             usingSpringWithDamping: 0.7,
                             initialSpringVelocity: 1,
                             options: .curveEaseOut, animations: {
                    self.drawer.transform = .identity
                })
                return
            }
            
            Self.animate(withDuration: Presets.Animation.long.rawValue,
                         delay: 0,
                         usingSpringWithDamping: 0.7,
                         initialSpringVelocity: 1,
                         options: .curveEaseOut, animations: {
                self.drawer.transform = CGAffineTransform(translationX: 0, y: translation.y)
            })
            
        case .ended:
            // Hide the view if dragged sufficiently, otherwise return to initial state
            if translation.y > 100 {
                hide()
                dismissActionSubject.send()
            } else {
                Self.animate(withDuration: Presets.Animation.long.rawValue,
                             delay: 0,
                             usingSpringWithDamping: 0.7,
                             initialSpringVelocity: 1,
                             options: .curveEaseOut, animations: {
                    self.drawer.transform = .identity
                })
            }
            
        default:
            break
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let recognizer = gestureRecognizer as? UIPanGestureRecognizer {
            // Prevent dragging upwards
            let translation = recognizer.translation(in: drawer)
            return translation.y >= 0
        }
        
        return false
    }
}
