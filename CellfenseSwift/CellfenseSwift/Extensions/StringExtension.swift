//
//  StringExtension.swift
//  CellfenseSwift
//
//  Created by Martin Gonzalez vega on 2/7/17.
//  Copyright © 2017 quitarts. All rights reserved.
//

import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func localized(withComment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
    }

}
