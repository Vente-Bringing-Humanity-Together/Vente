//
//  IMGLYFontSelectorView.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 06/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public protocol IMGLYFontSelectorViewDelegate: class {
    func fontSelectorView(fontSelectorView: IMGLYFontSelectorView, didSelectFontWithName fontName: String)
}

public class IMGLYFontSelectorView: UIScrollView {
    public weak var selectorDelegate: IMGLYFontSelectorViewDelegate?
    
    private let kDistanceBetweenButtons = CGFloat(60)
    private let kFontSize = CGFloat(28)
    private var fontNames = [String]()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {       
        fontNames = IMGLYInstanceFactory.availableFontsList
        configureFontButtons()
    }
    
    private func configureFontButtons() {
        for fontName in fontNames {
            let button = UIButton(type: UIButtonType.Custom)
            button.setTitle(fontName, forState:UIControlState.Normal)
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
            
            if let font = UIFont(name: fontName, size: kFontSize) {
                button.titleLabel?.font = font
                addSubview(button)
                button.addTarget(self, action: "buttonTouchedUpInside:", forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        for var index = 0; index < subviews.count; index++ {
            if let button = subviews[index] as? UIButton {
                button.frame = CGRectMake(0,
                    CGFloat(index) * kDistanceBetweenButtons,
                    frame.size.width,
                    kDistanceBetweenButtons)
            }
        }
        contentSize = CGSizeMake(frame.size.width - 1.0, kDistanceBetweenButtons * CGFloat(subviews.count - 2))
    }
    
    @objc private func buttonTouchedUpInside(button: UIButton) {
        selectorDelegate?.fontSelectorView(self, didSelectFontWithName: button.titleLabel!.text!)
    }
 }
