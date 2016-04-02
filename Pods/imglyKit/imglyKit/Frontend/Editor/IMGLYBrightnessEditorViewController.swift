//
//  IMGLYBrightnessEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 10/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public class IMGLYBrightnessEditorViewController: IMGLYSliderEditorViewController {

    // MARK: - UIViewController
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        navigationItem.title = NSLocalizedString("brightness-editor.title", tableName: nil, bundle: bundle, value: "", comment: "")
    }
    
    // MARK: - SliderEditorViewController
    
    override public var minimumValue: Float {
        return -1
    }
    
    override public var maximumValue: Float {
        return 1
    }
    
    override public var initialValue: Float {
        return fixedFilterStack.brightnessFilter.brightness
    }
    
    override public func valueChanged(value: Float) {
        fixedFilterStack.brightnessFilter.brightness = slider.value
    }
    
}
