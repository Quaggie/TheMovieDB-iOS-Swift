//
//  TypeAlias.swift
//  Movs
//
//  Created by Jonathan Bijos on 28/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import Foundation

typealias Params = [String: String]
typealias Response<T: Decodable> = (Result<T>) -> ()
