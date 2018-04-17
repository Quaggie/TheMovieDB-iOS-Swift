//
//  MovieDetailViewController.swift
//  Movs
//
//  Created by Jonathan Pereira Bijos on 27/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

class MovieDetailViewController: BaseViewController {
    
    private let movie: Movie
    
    private let scrollView = UIScrollView()
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    private let imgView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = ColorPalette.yellow.withAlphaComponent(0.2)
        return iv
    }()
    
    private let genresLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = ColorPalette.black
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        label.lineBreakMode = .byWordWrapping
        label.text = "○ Loading genres..."
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = ColorPalette.black
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = ColorPalette.black
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var favoriteBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add to favorites", for: .normal)
        btn.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        btn.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        btn.setTitleColor(ColorPalette.black, for: .normal)
        btn.backgroundColor = ColorPalette.yellow
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return btn
    }()
    
    init(movie: Movie, movieApi: MovieService) {
        self.movie = movie
        defer {
            navigationItem.title = movie.title
            
            if let posterUrlString = movie.posterUrlString, let url = URL(string: posterUrlString) {
                imgView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
            
            Genre.getGenres(movieApi: movieApi) { [weak self] (result) in
                guard let welf = self else { return }
                
                switch result {
                case .success(let genres):
                    let movieGenres = genres.filter({ (genre) -> Bool in
                        if let genreIds = movie.genreIds {
                            return genreIds.contains(genre.id)
                        }
                        return false
                    }).map({ $0.name }).joined(separator: ", ")
                    if !movieGenres.isEmpty {
                        welf.genresLabel.text = "● GENRE\n\(movieGenres)"
                    }
                case .error(let err):
                    if let msg = err.statusMessage {
                        welf.genresLabel.text = "● GENRE\n\(msg)"
                    } else {
                        welf.genresLabel.text = "● GENRE\nNo genre specified"
                    }
                }
            }
            
            if let rating = movie.voteAverage, let voteCount = movie.voteCount {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 2
                if let formattedRating = formatter.string(from: NSNumber(value: rating)) {
                    ratingLabel.text = "● RATING\n\(formattedRating)/10 from a total of \(voteCount) votes."
                }
            }
            
            if let overview = movie.overview {
                overviewLabel.text = "● DESCRIPTION\n\(overview)"
            }
            
            if let isFavorite = movie.isFavorite, isFavorite {
                favoriteBtn.setTitleColor(ColorPalette.black, for: .normal)
                favoriteBtn.backgroundColor = UIColor.lightGray
                favoriteBtn.setTitle("Remove from favorites", for: .normal)
            } else {
                favoriteBtn.setTitleColor(ColorPalette.black, for: .normal)
                favoriteBtn.backgroundColor = ColorPalette.yellow
                favoriteBtn.setTitle("Add to favorites", for: .normal)
            }
        }
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupViews() {
        super.setupViews()
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(imgView)
        containerView.addSubview(genresLabel)
        containerView.addSubview(ratingLabel)
        containerView.addSubview(overviewLabel)
        view.addSubview(favoriteBtn)
        
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        containerView.fillSuperview()
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    
        imgView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.4).isActive = true
        imgView.anchor(top: containerView.topAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor)
        
        genresLabel.anchor(top: imgView.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .zero)
        
        ratingLabel.anchor(top: genresLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: nil, trailing: containerView.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .zero)
        
        overviewLabel.anchor(top: ratingLabel.bottomAnchor, leading: containerView.leadingAnchor, bottom: containerView.bottomAnchor, trailing: containerView.trailingAnchor, padding: .init(top: 8, left: 8, bottom: 8, right: 8), size: .zero)
        
        favoriteBtn.anchor(top: scrollView.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
    }
}

// MARK: Actions
extension MovieDetailViewController {
    @objc private func toggleFavorite() {
        var favorite: Bool
        if let isFavorite = movie.isFavorite {
            favorite = !isFavorite
        } else {
            favorite = true
        }
        movie.isFavorite = favorite
        movie.dateAddedToFavorites = favorite ? Date() : nil
        NotificationCenter.default.post(name: .onMovieFavorited, object: nil, userInfo: ["movie": movie])
        
        if favorite {
            favoriteBtn.setTitleColor(ColorPalette.black, for: .normal)
            favoriteBtn.backgroundColor = UIColor.lightGray
            favoriteBtn.setTitle("Remove from favorites", for: .normal)
        } else {
            favoriteBtn.setTitleColor(ColorPalette.black, for: .normal)
            favoriteBtn.backgroundColor = ColorPalette.yellow
            favoriteBtn.setTitle("Add to favorites", for: .normal)
        }
    }
}
