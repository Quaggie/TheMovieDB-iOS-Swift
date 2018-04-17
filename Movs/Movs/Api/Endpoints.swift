//
//  Endpoints.swift
//  Movs
//
//  Created by Jonathan Bijos on 28/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

fileprivate protocol Endpoint {
    var endpoint: String { get }
    var value: String { get }
}

enum Endpoints {
    fileprivate static var version: Int = 3
    fileprivate static var baseUrl: String { return "\(Config.baseUrl)/\(Endpoints.version)" }
    
    enum movie: Endpoint {
        internal var endpoint: String { return "movie"}
        case popular
        
        var value: String {
            switch self {
            case .popular: return "\(Endpoints.baseUrl)/\(endpoint)/popular"
            }
        }
    }
    
    enum genre: Endpoint {
        internal var endpoint: String { return "genre" }
        
        case all
        
        var value: String {
            switch self {
            case .all: return "\(Endpoints.baseUrl)/\(endpoint)/movie/list"
            }
        }
    }
}
