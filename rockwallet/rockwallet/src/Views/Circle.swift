//
//  Circle.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-24.
//  Copyright © 2016-2019 Breadwinner AG. All rights reserved.
//

import UIKit

class Circle: UIView {
    enum CircleStyle {
        case filled
        case unfilled
    }
    
    private let color: UIColor
    private let style: CircleStyle
    static let defaultSize: CGFloat = ViewSizes.Common.hugeCommon.rawValue

    init(color: UIColor, style: CircleStyle) {
        self.color = color
        self.style = style
        
        super.init(frame: .zero)
        
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setShouldAntialias(true)
        
        switch style {
        case .filled:
            context.addEllipse(in: rect)
            context.setFillColor(color.cgColor)
            context.fillPath()
        case .unfilled:
            context.addEllipse(in: rect.insetBy(dx: BorderWidth.minimum.rawValue, dy: BorderWidth.minimum.rawValue))
            context.setLineWidth(BorderWidth.minimum.rawValue * 2)
            context.setStrokeColor(color.cgColor)
            context.strokePath()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
