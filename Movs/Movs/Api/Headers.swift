//
//  Headers.swift
//  Movs
//
//  Created by Jonathan Bijos on 28/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

class Headers: NSObject {
    private(set) var values: Params = [:]
    
    func update(_ value: String, forKey key: String) {
        values.updateValue(value, forKey: key)
    }
}
