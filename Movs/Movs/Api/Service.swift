//
//  Service.swift
//  Movs
//
//  Created by Jonathan Bijos on 28/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

protocol Service: AnyObject {}

extension Service {
    func prettyPrint<T: Encodable>(model: T) {
        debugPrint("-------")
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        do {
            let jsonData = try jsonEncoder.encode(model)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                debugPrint(jsonString)
            }
        } catch let err {
            debugPrint(err)
        }
        debugPrint("-------")
    }
}
