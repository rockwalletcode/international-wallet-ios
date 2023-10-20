// 
//  CountdownTimerView.swift
//  rockwallet
//
//  Created by Dino Gačević on 06/10/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct CountdownTimerViewModel: ViewModel {
    let countdownTime: TimeInterval
    let countdownTimeCritical: TimeInterval
}

struct CountdownTimerViewConfiguration: Configurable {
    let timerConfiguration: LabelConfiguration? = .init(font: Fonts.Title.five, textColor: .black, textAlignment: .center)
}

class CountdownTimerView: FEView<CountdownTimerViewConfiguration, CountdownTimerViewModel> {
    
    var countdownFinished: (() -> Void)?
    
    private lazy var containerView = UIView()
    private lazy var countdownLayer = CAShapeLayer()
    private lazy var circleLayer = CAShapeLayer()
    private lazy var timerLabel = FELabel()
    
    var timer: Timer? = Timer()
    
    private var currentTime: TimeInterval = 0 {
        didSet {
            timerLabel.setup(with: .text(currentTime.stringFromTimeInterval()))
            updateCountdown(isCritical: currentTime < viewModel?.countdownTimeCritical ?? 0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupCircleLayer()
        setupCountdownLayer()
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Margins.custom(7))
            make.bottom.equalToSuperview()
            make.width.height.equalTo(ViewSizes.extraExtraHuge.rawValue)
        }
        containerView.addSubview(timerLabel)
        timerLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        setupCircleLayer()
        containerView.layer.addSublayer(circleLayer)
        
        setupCountdownLayer()
        containerView.layer.addSublayer(countdownLayer)
    }
    
    private func setupCircleLayer() {
        let centerPoint = CGPoint(x: containerView.bounds.midX, y: containerView.bounds.midY)
        let radius = min(containerView.bounds.width, containerView.bounds.height) / 2
        
        let circularPath = UIBezierPath(arcCenter: centerPoint,
                                        radius: radius - CornerRadius.small.rawValue,
                                        startAngle: -.pi / 2,
                                        endAngle: 2 * .pi - .pi / 2,
                                        clockwise: true)
        
        circleLayer.path = circularPath.cgPath
        circleLayer.strokeColor = Colors.Disabled.two.cgColor
        circleLayer.lineWidth = Margins.extraSmall.rawValue
        circleLayer.fillColor = UIColor.clear.cgColor
    }
    
    private func setupCountdownLayer() {
        let centerPoint = CGPoint(x: containerView.bounds.midX, y: containerView.bounds.midY)
        let radius = min(containerView.bounds.width, containerView.bounds.height) / 2
        
        let circularPath = UIBezierPath(arcCenter: centerPoint,
                                        radius: radius - 10,
                                        startAngle: -.pi / 2,
                                        endAngle: 2 * .pi - .pi / 2,
                                        clockwise: true)

        countdownLayer.path = circularPath.cgPath
        countdownLayer.strokeColor = Colors.primaryPressed.cgColor
        countdownLayer.lineWidth = 4
        countdownLayer.fillColor = UIColor.clear.cgColor
        countdownLayer.lineCap = .round
    }

    private func updateCountdown(isCritical: Bool = false) {
        guard let countdownTime = viewModel?.countdownTime else { return }
        let fraction = CGFloat(currentTime / countdownTime)
        countdownLayer.strokeEnd = fraction
        countdownLayer.strokeColor = isCritical ? Colors.Error.one.cgColor : Colors.primaryPressed.cgColor
        
        guard isCritical else { return }
        var timerConfig = config?.timerConfiguration
        timerConfig?.textColor = Colors.Error.one
        timerLabel.configure(with: timerConfig)
    }
    
    override func setup(with viewModel: CountdownTimerViewModel?) {
        super.setup(with: viewModel)
        
        currentTime = viewModel?.countdownTime ?? 0
        timerLabel.setup(with: .text(viewModel?.countdownTime.stringFromTimeInterval()))
        
        start()
    }
    
    override func configure(with config: CountdownTimerViewConfiguration?) {
        super.configure(with: config)
        
        timerLabel.configure(with: config?.timerConfiguration)
    }
    
    private func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc private func updateTimer() {
        currentTime -= 1
        if currentTime == 0 {
            invalidateTimer()
            self.countdownFinished?()
            
            // Countdown timer finished
            // You can add any additional handling here
        }
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension TimeInterval {
    func stringFromTimeInterval() -> String {
        let time = NSInteger(self)
        
        let seconds = time % 60
        let minutes = (time / 60) % 60
        
        return String(format: "%0.2d:%0.2d", minutes, seconds)
    }
}
