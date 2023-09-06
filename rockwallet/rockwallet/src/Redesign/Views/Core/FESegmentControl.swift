// 
//  SegmentControl.swift
//  breadwallet
//
//  Created by Rok on 05/07/2022.
//  Copyright © 2022 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct SegmentControlConfiguration: Configurable {
    var font: UIFont = Fonts.button
    var normal: BackgroundConfiguration = .init(backgroundColor: Colors.Background.cards, tintColor: Colors.primary)
    var selected: BackgroundConfiguration = .init(backgroundColor: Colors.primary, tintColor: Colors.Contrast.two)
    var inset: CGPoint = CGPoint(x: 10, y: 10)
}

struct SegmentControlViewModel: ViewModel {
    /// Passing 'nil' leaves the control deselected
    var selectedIndex: Int?
    var segments: [Segment]
    
    struct Segment: Hashable {
        let image: UIImage?
        let title: String?
    }
}

class SegmentControl: FEView<SegmentControlConfiguration, SegmentControlViewModel> {
    var didChangeValue: ((Int) -> Void)?
    private var segmentedControl = FESegmentControl()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.setupCustomMargins(vertical: .zero, horizontal: .zero)
        
        content.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
            make.height.equalTo(ViewSizes.Common.defaultCommon.rawValue)
        }
    }
    
    override func configure(with config: SegmentControlConfiguration?) {
        guard let config = config else { return }
        super.configure(with: config)
        
        segmentedControl.backgroundColor = config.normal.backgroundColor
        segmentedControl.selectedSegmentTintColor = config.selected.backgroundColor
        segmentedControl.config = config
        
        segmentedControl.setTitleTextAttributes([
            .font: config.font,
            .foregroundColor: config.normal.tintColor
        ], for: .normal)
        
        segmentedControl.setTitleTextAttributes([
            .font: config.font,
            .foregroundColor: config.selected.tintColor
        ], for: .selected)
        
        segmentedControl.didChangeValue = { [weak self] value in
            self?.didChangeValue?(value)
        }
    }
    
    override func setup(with viewModel: SegmentControlViewModel?) {
        guard let viewModel = viewModel else { return }
        super.setup(with: viewModel)
        
        UIView.setAnimationsEnabled(false)
        
        segmentedControl.removeAllSegments()
        for (index, element) in (viewModel.segments).enumerated() {
            if let image = element.image, let title = element.title {
                let image = UIImage.textEmbeded(image: image,
                                                string: title,
                                                isImageBeforeText: true)
                segmentedControl.insertSegment(with: image, at: index, animated: true)
            } else if let title = element.title {
                segmentedControl.insertSegment(withTitle: title, at: index, animated: true)
            }
        }
        
        UIView.setAnimationsEnabled(true)
        
        selectSegment(index: viewModel.selectedIndex)
    }
    
    func selectSegment(index: Int?) {
        if let index = index {
            viewModel?.selectedIndex = index
            segmentedControl.selectedSegmentIndex = index
        } else {
            viewModel?.selectedIndex = nil
            segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        }
    }
}

private final class FESegmentControl: UISegmentedControl {
    var didChangeValue: ((Int) -> Void)?
    var config: SegmentControlConfiguration?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = true
        clipsToBounds = true
        
        if subviews.indices.contains(selectedSegmentIndex),
           let foregroundImageView = subviews[numberOfSegments] as? UIImageView {
            foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: config?.inset.x ?? 0, dy: config?.inset.y ?? 0)
            foregroundImageView.image = UIImage.imageForColor(config?.selected.backgroundColor ?? .clear)
            foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")
            foregroundImageView.layer.masksToBounds = true
            foregroundImageView.layer.cornerRadius = foregroundImageView.frame.height / 2
            
            for i in 0..<numberOfSegments {
                let backgroundSegmentView = subviews[i]
                backgroundSegmentView.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTarget(self, action: #selector(indexChanged), for: .valueChanged)
    }
    
    @objc func indexChanged(_ sender: UISegmentedControl) {
        didChangeValue?(selectedSegmentIndex)
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
