//
//  IMGLYSubEditorViewController.swift
//  imglyKit
//
//  Created by Sascha Schwabbauer on 08/04/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import UIKit

public typealias IMGLYSubEditorCompletionBlock = (UIImage?, IMGLYFixedFilterStack) -> (Void)
public typealias IMGLYPreviewImageGenerationCompletionBlock = () -> (Void)

public class IMGLYSubEditorViewController: IMGLYEditorViewController {
    
    // MARK: - Properties
    
    public let fixedFilterStack: IMGLYFixedFilterStack
    public var completionHandler: IMGLYSubEditorCompletionBlock?
    
    // MARK: - Initializers
    
    public init(fixedFilterStack: IMGLYFixedFilterStack) {
        self.fixedFilterStack = fixedFilterStack.copy() as! IMGLYFixedFilterStack
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - EditorViewController
    
    public override func tappedDone(sender: UIBarButtonItem?) {
        completionHandler?(previewImageView.image, fixedFilterStack)
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Helpers
    
    public func updatePreviewImageWithCompletion(completionHandler: IMGLYPreviewImageGenerationCompletionBlock?) {
        if let lowResolutionImage = self.lowResolutionImage {
            updating = true
            dispatch_async(PhotoProcessorQueue) {
                let processedImage = IMGLYPhotoProcessor.processWithUIImage(lowResolutionImage, filters: self.fixedFilterStack.activeFilters)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.previewImageView.image = processedImage
                    self.updating = false
                    completionHandler?()
                }
            }
        }
    }
    
    internal func updatePreviewImage() {
        updatePreviewImageWithCompletion(nil)
    }
}