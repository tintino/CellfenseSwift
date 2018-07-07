//
//  SKAudioNodeExtension.swift
//  CellfenseSwift
//
//  Created by Martin Gonzalez vega on 06/07/2018.
//  Copyright © 2018 quitarts. All rights reserved.
//

import Foundation
import SpriteKit

extension SKAudioNode {
    func play() {
        run(SKAction.play())
    }

    func stop() {
        run(SKAction.stop())
    }
}
