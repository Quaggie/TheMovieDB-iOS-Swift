//
//  MovieService.swift
//  Movs
//
//  Created by Jonathan Pereira Bijos on 27/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import Foundation

protocol MovieService: Service {
    func getPopularMovies(page: Int, completion: @escaping Response<PopularMoviesResponse>)
    func getGenres(completion: @escaping Response<[Genre]>)
}
