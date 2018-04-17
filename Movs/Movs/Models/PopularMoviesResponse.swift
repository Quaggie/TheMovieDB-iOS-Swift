//
//  PopularMoviesResponse.swift
//  Movs
//
//  Created by Jonathan Bijos on 28/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import Foundation

class PopularMoviesResponse: NSObject, Codable {
    var page: Int?
    var totalResults: Int?
    var totalPages: Int?
    var results: [Movie]?
    
    override init() {
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case results
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page = try? container.decode(Int.self, forKey: .page)
        self.totalResults = try? container.decode(Int.self, forKey: .totalResults)
        self.totalPages = try? container.decode(Int.self, forKey: .totalPages)
        self.results = try? container.decode([Movie].self, forKey: .results)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(page, forKey: .page)
        try container.encode(totalResults, forKey: .totalResults)
        try container.encode(totalPages, forKey: .totalPages)
        try container.encode(results, forKey: .results)
    }
}
