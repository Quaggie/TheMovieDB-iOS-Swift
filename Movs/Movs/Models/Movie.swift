//
//  Movie.swift
//  Movs
//
//  Created by Jonathan Pereira Bijos on 27/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit
import Cache

class Movie: NSObject, Codable {
    var voteCount: Int?
    var id: Int?
    var video: Bool?
    var voteAverage: Float?
    var title: String?
    var posterPath: String?
    var originalTitle: String?
    var genreIds: [Int]?
    var backdropPath: String?
    var adult: Bool?
    var overview: String?
    var releaseDate: String?
    
    var dateAddedToFavorites: Date?
    var isFavorite: Bool?
    
    override init() {
        super.init()
    }
    
    static fileprivate var cachedMovies: [Movie] = []
    
    class func saveCachedMovies(_ movies: [Movie]) {
        guard let storage = Storage.shared() else {
            return
        }
        
        cachedMovies = movies
        try? storage.setObject(movies, forKey: "movies")
    }
    class func getCachedMovies() -> [Movie] {
        if !cachedMovies.isEmpty {
            return cachedMovies
        }
        guard let storage = Storage.shared() else {
            return []
        }
        var movies: [Movie] = []
        if let _movies = try? storage.object(ofType: [Movie].self, forKey: "movies") {
            movies = _movies
        }
        return movies
    }
    
    var formattedReleaseDate: Date? {
        if let releaseDate = releaseDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-DD"
            return dateFormatter.date(from: releaseDate)
        }
        return nil
    }
    
    var releaseYear: String? {
        if let date = formattedReleaseDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY"
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    var posterUrlString: String? {
        if let posterPath = posterPath {
            return "https://image.tmdb.org/t/p/w300\(posterPath)"
        }
        return nil
    }
    
    var backdropUrlString: String? {
        if let backdropPath = backdropPath {
            return "https://image.tmdb.org/t/p/w780\(backdropPath)"
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case voteCount = "vote_count"
        case id
        case video
        case voteAverage = "vote_average"
        case title
        case posterPath = "poster_path"
        case originalTitle = "original_title"
        case genreIds = "genre_ids"
        case backdropPath = "backdrop_path"
        case adult
        case overview
        case releaseDate = "release_date"
        case isFavorite
        case dateAddedToFavorites
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.voteCount = try? container.decode(Int.self, forKey: .voteCount)
        self.id = try? container.decode(Int.self, forKey: .id)
        self.video = try? container.decode(Bool.self, forKey: .video)
        self.voteAverage = try? container.decode(Float.self, forKey: .voteAverage)
        self.title = try? container.decode(String.self, forKey: .title)
        self.posterPath = try? container.decode(String.self, forKey: .posterPath)
        self.originalTitle = try? container.decode(String.self, forKey: .originalTitle)
        self.genreIds = try? container.decode([Int].self, forKey: .genreIds)
        self.backdropPath = try? container.decode(String.self, forKey: .backdropPath)
        self.adult = try? container.decode(Bool.self, forKey: .adult)
        self.overview = try? container.decode(String.self, forKey: .overview)
        self.releaseDate = try? container.decode(String.self, forKey: .releaseDate)
        self.isFavorite = try? container.decode(Bool.self, forKey: .isFavorite)
        self.isFavorite = try? container.decode(Bool.self, forKey: .isFavorite)
        self.dateAddedToFavorites = try? container.decode(Date.self, forKey: .dateAddedToFavorites)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(voteCount, forKey: .voteCount)
        try container.encode(id, forKey: .id)
        try container.encode(video, forKey: .video)
        try container.encode(voteAverage, forKey: .voteAverage)
        try container.encode(title, forKey: .title)
        try container.encode(posterPath, forKey: .posterPath)
        try container.encode(originalTitle, forKey: .originalTitle)
        try container.encode(genreIds, forKey: .genreIds)
        try container.encode(backdropPath, forKey: .backdropPath)
        try container.encode(adult, forKey: .adult)
        try container.encode(overview, forKey: .overview)
        try container.encode(releaseDate, forKey: .releaseDate)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(dateAddedToFavorites, forKey: .dateAddedToFavorites)
    }
}

extension Movie {
    static func ==(lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}
