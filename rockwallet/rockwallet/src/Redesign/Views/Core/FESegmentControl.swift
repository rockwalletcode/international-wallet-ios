// 
//  FESegmentControl.swift
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
    var normal: BackgroundConfiguration = .init(backgroundColor: LightColors.Background.cards, tintColor: LightColors.primary)
    var selected: BackgroundConfiguration = .init(backgroundColor: LightColors.primary, tintColor: LightColors.Contrast.two)
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

class FESegmentControl: UISegmentedControl, ViewProtocol {
    var config: SegmentControlConfiguration?
    var viewModel: SegmentControlViewModel?
    
    var didChangeValue: ((Int) -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = true
        clipsToBounds = true
        
        if subviews.indices.contains(selectedSegmentIndex),
            let foregroundImageView = subviews[numberOfSegments] as? UIImageView {
            foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: 10, dy: 10)
            foregroundImageView.image = UIImage.imageForColor(LightColors.primary)
            foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")
            foregroundImageView.layer.masksToBounds = true
            foregroundImageView.layer.cornerRadius = foregroundImageView.frame.height / 2
            
            for i in 0..<numberOfSegments {
                let backgroundSegmentView = subviews[i]
                backgroundSegmentView.isHidden = true
            }
        }
    }
    
    func configure(with config: SegmentControlConfiguration?) {
        guard let config = config else { return }
        
        self.config = config
        
        snp.makeConstraints { make in
            make.height.equalTo(ViewSizes.Common.defaultCommon.rawValue)
        }
        
        backgroundColor = config.normal.backgroundColor
        selectedSegmentTintColor = config.selected.backgroundColor
        
        setTitleTextAttributes([
            .font: config.font,
            .foregroundColor: config.normal.tintColor
        ], for: .normal)
        
        setTitleTextAttributes([
            .font: config.font,
            .foregroundColor: config.selected.tintColor
        ], for: .selected)
        
        valueChanged = { [weak self] in
            guard let selectedSegmentIndex = self?.selectedSegmentIndex, selectedSegmentIndex >= 0 else { return }
            self?.didChangeValue?(selectedSegmentIndex)
        }
    }
    
    func setup(with viewModel: SegmentControlViewModel?) {
        self.viewModel = viewModel
        
        UIView.setAnimationsEnabled(false)
        
        removeAllSegments()
        for (index, element) in (viewModel?.segments ?? []).enumerated() {
            if let image = element.image, let title = element.title {
                let image = UIImage.textEmbeded(image: image,
                                                string: title,
                                                isImageBeforeText: true)
                insertSegment(with: image, at: index, animated: true)
            } else if let title = element.title {
                insertSegment(withTitle: title, at: index, animated: true)
            }
        }
        
        UIView.setAnimationsEnabled(true)
        
        selectSegment(index: viewModel?.selectedIndex)
    }
    
    func selectSegment(index: Int?) {
        if let index = index {
            viewModel?.selectedIndex = index
            selectedSegmentIndex = index
        } else {
            viewModel?.selectedIndex = nil
            selectedSegmentIndex = UISegmentedControl.noSegment
        }
    }
}
