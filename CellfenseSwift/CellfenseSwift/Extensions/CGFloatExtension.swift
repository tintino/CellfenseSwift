//
//  IntExtension.swift
//  CellfenseSwift
//
//  Created by Tincho on 16/5/16.
//  Copyright © 2016 quitarts. All rights reserved.
//

import Foundation
import UIKit

/** The value of π as a CGFloat */
let πValue = CGFloat(Double.pi)

extension CGFloat {

    /**
     * Converts an angle in degrees to radians.
     */
    public func degreesToRadians() -> CGFloat {
        return πValue * self / 180.0
    }

    /**
     * Converts an angle in radians to degrees.
     */
    public func radiansToDegrees() -> CGFloat {
        return self * 180.0 / πValue
    }
}
