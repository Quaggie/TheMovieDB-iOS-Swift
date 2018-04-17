//
//  Filter.swift
//  Movs
//
//  Created by Jonathan Bijos on 02/03/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

class Filter: NSObject {
    var selectedYear: Int?
    var selectedGenre: Genre?
    
    func apply(on movies: inout [Movie]) {
        movies = movies.filter({ (movie) -> Bool in
            // Both filters selected
            if let selectedYear = selectedYear, let selectedGenre = selectedGenre {
                if let date = movie.formattedReleaseDate {
                    let components = Calendar.current.dateComponents([.year], from: date)
                    if let year = components.year {
                        if let genreIds = movie.genreIds {
                            return genreIds.contains(selectedGenre.id) && selectedYear == year
                        }
                    }
                }
            // Only year filter selected
            } else if let selectedYear = selectedYear {
                if let date = movie.formattedReleaseDate {
                    let components = Calendar.current.dateComponents([.year], from: date)
                    if let year = components.year {
                       return selectedYear == year
                    }
                }
            // Only genre filter selected
            } else if let selectedGenre = selectedGenre {
                if let genreIds = movie.genreIds {
                    return genreIds.contains(selectedGenre.id)
                }
            }
            // Default return
            return false
        })
    }
    
    func reset() {
        selectedYear = nil
        selectedGenre = nil
    }
}
