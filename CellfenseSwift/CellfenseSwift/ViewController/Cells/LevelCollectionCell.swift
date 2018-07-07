//
//  LevelCollectionCell.swift
//  CellfenseSwift
//
//  Created by Martin Gonzalez vega on 23/6/17.
//  Copyright © 2017 quitarts. All rights reserved.
//

import UIKit

class LevelCollectionCell: UICollectionViewCell {

    @IBOutlet weak public var labelName: UILabel!
    @IBOutlet weak var labelLevelNumber: UILabel!

    public var level =  Level()

    func configureCell(withLevel level: Level, number: Int) {
        self.level = level
        labelName.text = level.name
        layer.cornerRadius = 10
        labelLevelNumber.text = String(number)
    }
}
