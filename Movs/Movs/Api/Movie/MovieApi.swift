//
//  MovieApi.swift
//  Movs
//
//  Created by Jonathan Pereira Bijos on 27/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

class MovieApi: NSObject {
    
}

extension MovieApi: MovieService {
    func getPopularMovies(page: Int, completion: @escaping Response<PopularMoviesResponse>) {
        let request = Request(url: Endpoints.movie.popular.value)
        let params: Params = [
            "api_key": Config.movieApiKey,
            "language": "en-US",
            "page": "\(page)"
        ]
        
        request.get(params: params) { [weak self] (result: Result<PopularMoviesResponse>) in
            guard let welf = self else { return }
            
            switch result {
            case .success(let response):
                welf.prettyPrint(model: response)
                completion(.success(response))
            case .error(let err):
                completion(.error(err))
            }
        }
    }
    
    func getGenres(completion: @escaping Response<[Genre]>) {
        let request = Request(url: Endpoints.genre.all.value)
        let params: Params = [
            "api_key": Config.movieApiKey,
            "language": "en-US"
        ]
        
        request.get(params: params) { [weak self] (result: Result<GenresResponse>) in
            guard let welf = self else { return }
            
            switch result {
            case .success(let response):
                welf.prettyPrint(model: response)
                let genres = response.genres ?? []
                completion(.success(genres))
            case .error(let err):
                completion(.error(err))
            }
        }
    }
}
