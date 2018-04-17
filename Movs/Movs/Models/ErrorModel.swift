//
//  ErrorModel.swift
//  Movs
//
//  Created by Jonathan Bijos on 28/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

class ErrorModel: NSObject, Codable {
    var statusCode: Int?
    var statusMessage: String?
    var success: Bool?
    
    init(statusMessage: String) {
        self.statusCode = 500
        self.statusMessage = statusMessage
        self.success = false
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMessage = "status_message"
        case success
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.statusCode = try? container.decode(Int.self, forKey: .statusCode)
        self.statusMessage = try? container.decode(String.self, forKey: .statusMessage)
        self.success = try? container.decode(Bool.self, forKey: .success)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(statusCode, forKey: .statusCode)
        try container.encode(statusMessage, forKey: .statusMessage)
        try container.encode(success, forKey: .success)
    }
    
    static var defaultModel: ErrorModel {
        return ErrorModel(statusMessage: "Unable to connect to the server")
    }
}
