//
//  PopularViewController.swift
//  Movs
//
//  Created by Jonathan Pereira Bijos on 27/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

class PopularViewController: BaseViewController {
    
    private let movieApi: MovieService
    private var state: PopularVCViewState<PopularMoviesResponse> = .loading {
        didSet {
            changeUI(for: state, previousState: oldValue)
        }
    }
    
    private var total: Int = 0
    private var page: Int = 1
    private var movies: [Movie] = []
    private var filteredMovies: [Movie] = []
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.dimsBackgroundDuringPresentation = false
        sc.hidesNavigationBarDuringPresentation = true
        sc.delegate = self
        return sc
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 16
        flowLayout.minimumInteritemSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.backgroundColor = .clear
        cv.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        cv.dataSource = self
        cv.delegate = self
        cv.register(MovieCollectionViewCell.self,
                    forCellWithReuseIdentifier: MovieCollectionViewCell.reuseIdentifier)
        cv.register(MovieCollectionViewFooter.self,
                    forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                    withReuseIdentifier: MovieCollectionViewFooter.identifier)
        return cv
    }()
    
    // Empty view layout
    private let emptyView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .center
        return sv
    }()
    private let emptyImgView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "search_icon").withRenderingMode(.alwaysTemplate))
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No movies found with selected search"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    // Error view layout
    private let errorView = UIView()
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "An error occurred ):"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    private lazy var errorBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Try again", for: .normal)
        btn.addTarget(self, action: #selector(tryAgain), for: .touchUpInside)
        btn.backgroundColor = ColorPalette.yellow
        btn.tintColor = ColorPalette.black
        btn.layer.cornerRadius = 2.0
        btn.layer.borderWidth = 2.0
        btn.layer.borderColor = ColorPalette.black.cgColor
        return btn
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        return ai
    }()
    
    init(movieApi: MovieService) {
        self.movieApi = movieApi
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Defining context for searchController
        definesPresentationContext = true
        getPopularMovies(page: page)
        setupObservers()
    }
    
    override func setupViews() {
        super.setupViews()
        setupNavigationBar()
        setupCollectionView()
        setupEmptyView()
        setupErrorView()
        setupLoadingView()
    }
    
    private func changeUI(for: PopularVCViewState<PopularMoviesResponse>, previousState: PopularVCViewState<PopularMoviesResponse>) {
        switch state {
        case .loading:
            emptyView.isHidden = true
            errorView.isHidden = true
            
            collectionView.collectionViewLayout.invalidateLayout()
            if case .error(_) = previousState {
                collectionView.reloadData()
            }
            
            if total == 0 {
                collectionView.isHidden = true
                activityIndicator.startAnimating()
            } else {
                collectionView.isHidden = false
                activityIndicator.stopAnimating()
            }
        case .finished(let response):
            emptyView.isHidden = true
            errorView.isHidden = true
            activityIndicator.stopAnimating()
            collectionView.isHidden = false
            
            if let total = response.totalPages {
                self.total = total
            }
            if let page = response.page {
                self.page = page
            }
            if let results = response.results {
                if previousState == .empty || previousState == .filtering {
                    collectionView.reloadData()
                    return
                }
                let movies = Movie.getCachedMovies()
                for movie in movies {
                    for result in results where result == movie {
                        result.isFavorite = true
                    }
                }
                collectionView.performBatchUpdates({
                    let max = self.movies.count
                    self.movies.append(contentsOf: results)
                    
                    var items: [IndexPath] = []
                    for (index, _) in results.enumerated() {
                        let indexPath = IndexPath(item: max + index, section: 0)
                        items.append(indexPath)
                    }
                    self.collectionView.insertItems(at: items)
                    self.collectionView.collectionViewLayout.invalidateLayout()
                }, completion: nil)
            }
        case .filtering:
            emptyView.isHidden = true
            errorView.isHidden = true
            activityIndicator.stopAnimating()
            collectionView.isHidden = false
            collectionView.reloadData()
        case .empty:
            emptyView.isHidden = false
            errorView.isHidden = true
            activityIndicator.stopAnimating()
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.isHidden = true
            collectionView.reloadData()
        case .error(_):
            emptyView.isHidden = true
            activityIndicator.stopAnimating()
            
            if total == 0 {
                collectionView.isHidden = true
                errorView.isHidden = false
            } else {
                collectionView.isHidden = false
                errorView.isHidden = true
                collectionView.collectionViewLayout.invalidateLayout()
                collectionView.reloadData()
            }
        }
    }
}

// MARK: Layout
extension PopularViewController {
    private func setupNavigationBar() {
        navigationItem.title = "Movies"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.fillSuperviewSafeLayoutGuide()
    }
    
    private func setupEmptyView() {
        view.addSubview(emptyView)
        emptyView.addArrangedSubview(emptyImgView)
        emptyView.addArrangedSubview(emptyLabel)
        emptyView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: view.frame.height * 0.15))
        emptyView.anchorCenter(to: view)
    }
    
    private func setupErrorView() {
        view.addSubview(errorView)
        errorView.addSubview(errorLabel)
        errorView.addSubview(errorBtn)
        
        errorView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16), size: .init(width: 0, height: view.frame.height * 0.15))
        errorView.anchorCenter(to: view)
        
        errorLabel.anchor(top: errorView.topAnchor, leading: errorView.leadingAnchor, bottom: errorBtn.topAnchor, trailing: errorView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 16, right: 0), size: .zero)
        
        errorBtn.anchor(top: nil, leading: errorView.leadingAnchor, bottom: errorView.bottomAnchor, trailing: errorView.trailingAnchor, padding: .zero, size: .zero)
    }
    
    private func setupLoadingView() {
        view.addSubview(activityIndicator)
        activityIndicator.anchorCenter(to: view)
    }
}

// MARK: Actions
extension PopularViewController {
    private func getMovieFor(indexPath: IndexPath) -> Movie {
        let movie: Movie
        if isFiltering() {
            movie = filteredMovies[indexPath.item]
        } else {
            movie = movies[indexPath.item]
        }
        return movie
    }
    
    @objc private func tryAgain() {
        let nextPage = page + 1
        getPopularMovies(page: nextPage)
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: .onMovieFavorited, object: nil, queue: nil) { (notification) in
            if let movie = notification.userInfo?["movie"] as? Movie {
                for (index, mv) in self.movies.enumerated() {
                    if mv == movie {
                        self.movies[index] = movie
                        self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                        break
                    }
                }
                for (index, mv) in self.filteredMovies.enumerated() {
                    if mv == movie {
                        self.filteredMovies[index] = movie
                        self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                        break
                    }
                }
            }
        }
    }
}


// MARK: Movie service
extension PopularViewController {
    private func getPopularMovies(page: Int) {
        if total > 0, state == .loading {
            return
        }
        if isFiltering() {
            return
        }
        state = .loading
        movieApi.getPopularMovies(page: page) { [weak self] (result) in
            guard let welf = self else { return }
            
            switch result {
            case .success(let response):
                if let totalResults = response.totalResults, totalResults == 0 {
                    welf.state = .empty
                } else {
                    welf.state = .finished(response)
                }
            case .error(let error):
                welf.state = .error(error)
            }
        }
    }
}

// MARK: UICollectionViewDelegate
extension PopularViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = getMovieFor(indexPath: indexPath)
        let movieDetailVC = MovieDetailViewController(movie: movie, movieApi: movieApi)
        movieDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}

// MARK: UICollectionViewDataSource
extension PopularViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFiltering() ? filteredMovies.count : movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.reuseIdentifier, for: indexPath) as! MovieCollectionViewCell
        let movie = getMovieFor(indexPath: indexPath)
        cell.movie = movie
        cell.onToggleFavorite = { isFavorite in
            movie.isFavorite = isFavorite
            movie.dateAddedToFavorites = isFavorite ? Date() : nil
            NotificationCenter.default.post(name: .onMovieFavorited, object: nil, userInfo: ["movie": movie])
        }
        
        if !movies.isEmpty, total > 0, indexPath.item == (movies.count - 3), movies.count < total, !isFiltering() {
            if case .finished(_) = state {
                let nextPage = page + 1
                getPopularMovies(page: nextPage)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader: break
        case UICollectionElementKindSectionFooter:
            if let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: MovieCollectionViewFooter.identifier, for: indexPath) as? MovieCollectionViewFooter {
                if case .error(_) = state {
                    footerView.state = .error
                } else {
                    footerView.state = .loading
                }
                footerView.onTryAgain = {
                    self.tryAgain()
                }
                return footerView
            }
        default: break
        }
        return UICollectionReusableView()
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension PopularViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margins: CGFloat = 24
        let width = (view.frame.width / 2) - margins
        return CGSize(width: width, height: MovieCollectionViewCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if total == 0 || isFiltering() {
            return .zero
        }
        return CGSize(width: view.frame.width, height: MovieCollectionViewFooter.height)
    }
}

// MARK: ScrollDelegate
extension PopularViewController: ScrollDelegate {
    func scrollToTop() {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
}

// MARK: UISearchResultsUpdating
extension PopularViewController: UISearchResultsUpdating {
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredMovies = movies.flatMap { movie in
            guard let title = movie.title,
                title.lowercased().contains(searchText.lowercased()) else {
                    return nil
            }
            return movie
        }
        if filteredMovies.isEmpty {
            if searchBarIsEmpty() {
                filteredMovies = movies
                state = .filtering
            } else {
                state = .empty
            }
        } else {
            state = .filtering
        }
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            filterContentForSearchText(searchController.searchBar.text ?? "")
        }
    }
}

// MARK: UISearchControllerDelegate
extension PopularViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        filteredMovies = movies
        state = .filtering
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        let response = PopularMoviesResponse()
        response.results = movies
        state = .finished(response)
    }
}
