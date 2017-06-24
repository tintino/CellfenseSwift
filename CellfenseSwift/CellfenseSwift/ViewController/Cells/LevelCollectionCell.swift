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
    
    public var level =  Level()
    
    func configureCell(level:Level) {
        self.level = level
        
        self.labelName.text = self.level.name
    }
    
    
}
