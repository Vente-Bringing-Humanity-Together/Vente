//
//  IMGLYOrchidFilter.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/03/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

public class IMGLYOrchidFilter: IMGLYResponseFilter {
    init() {
        super.init(responseName: "Orchid")
        self.imgly_displayName = "Orchid"
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override var filterType:IMGLYFilterType {
        get {
            return IMGLYFilterType.Orchid
        }
    }
}
