//
//  Result.swift
//  Movs
//
//  Created by Jonathan Bijos on 28/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case error(ErrorModel)
}
