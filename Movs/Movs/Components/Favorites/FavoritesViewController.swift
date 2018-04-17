//
//  FavoritesViewController.swift
//  Movs
//
//  Created by Jonathan Pereira Bijos on 27/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

class FavoritesViewController: BaseViewController {

    private var state: FavoritesVCViewState = .noFavorites {
        didSet {
            changeUI(for: state)
        }
    }
    var filter: Filter = Filter() {
        didSet {
            if filter.selectedYear != nil || filter.selectedGenre != nil {
                hasFilter = true
            } else {
                hasFilter = false
            }
        }
    }
    
    private var movies: [Movie] = [] {
        didSet {
            if movies.isEmpty {
                if hasFilter {
                    state = .empty
                } else {
                    state = .noFavorites
                }
            } else {
                state = .finished
            }
        }
    }
    var hasFilter: Bool = false
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.estimatedRowHeight = FavoriteTableViewCell.height
        tv.separatorColor = ColorPalette.black
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundView = UIView()
        tv.register(FavoriteTableViewCell.self, forCellReuseIdentifier: FavoriteTableViewCell.identifier)
        tv.register(FavoriteFilterTableViewHeader.self, forHeaderFooterViewReuseIdentifier: FavoriteFilterTableViewHeader.identifier)
        return tv
    }()
    
    private let noFavoritesLabel: UILabel = {
        let label = UILabel()
        label.text = "No movies have been favorited :("
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No movies found with the selected filter."
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    private lazy var changeFilterBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Click here to change", for: .normal)
        btn.addTarget(self, action: #selector(showFilterVC), for: .touchUpInside)
        return btn
    }()
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFavoriteMovies()
        setupObservers()
    }

    override func setupViews() {
        super.setupViews()
        setupNavigationBar()
        
        view.addSubview(tableView)
        view.addSubview(noFavoritesLabel)
        view.addSubview(emptyLabel)
        view.addSubview(changeFilterBtn)
        
        tableView.fillSuperviewSafeLayoutGuide()
        
        noFavoritesLabel.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16), size: .zero)
        noFavoritesLabel.anchorCenter(to: view)
        
        emptyLabel.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 16), size: .zero)
        emptyLabel.anchorCenter(to: view)
        
        changeFilterBtn.anchor(top: emptyLabel.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 8, left: 16, bottom: 0, right: 16), size: .zero)
    }
    
    private func changeUI(for: FavoritesVCViewState) {
        switch state {
        case .finished:
            emptyLabel.isHidden = true
            noFavoritesLabel.isHidden = true
            changeFilterBtn.isHidden = true
            
            tableView.reloadData()
            tableView.isHidden = false
            if tableView.isEditing {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Okay",
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: #selector(editButtonPressed))
            } else {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: #selector(editButtonPressed))
            }
        case .empty:
            emptyLabel.isHidden = false
            noFavoritesLabel.isHidden = true
            changeFilterBtn.isHidden = false
            
            if tableView.isEditing {
                tableView.setEditing(false, animated: true)
            }
            tableView.reloadData()
            tableView.isHidden = true
            navigationItem.rightBarButtonItem = nil
        case .noFavorites:
            emptyLabel.isHidden = true
            noFavoritesLabel.isHidden = false
            changeFilterBtn.isHidden = true
            
            if tableView.isEditing {
                tableView.setEditing(false, animated: true)
            }
            tableView.reloadData()
            tableView.isHidden = true
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(forName: .onMovieFavorited, object: nil, queue: nil) { (notification) in
            if let movie = notification.userInfo?["movie"] as? Movie {
                var hasMovie = false
                for (index, mv) in self.movies.enumerated() {
                    if mv == movie {
                        self.tableView.beginUpdates()
                        self.movies.remove(at: index)
                        self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
                        self.tableView.endUpdates()
                        hasMovie = true
                        break
                    }
                }
                if !hasMovie {
                    self.movies.append(movie)
                    if self.hasFilter {
                        self.filter.apply(on: &self.movies)
                        self.movies.sort { (prev, curr) -> Bool in
                            guard let prevDate = prev.dateAddedToFavorites,
                                let currDate = curr.dateAddedToFavorites else {
                                    return false
                            }
                            return prevDate.compare(currDate) == .orderedAscending
                        }
                    }
                }
            }
        }
    }
}

// MARK: Layout
extension FavoritesViewController {
    private func setupNavigationBar() {
        navigationItem.title = "Movies"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
    }
}

// MARK: Actions
extension FavoritesViewController {
    @objc private func editButtonPressed() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Okay",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(editButtonPressed))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(editButtonPressed))
        }
    }
    
    @objc private func showFilterVC() {
        let filterVC = FilterViewController(filter: filter)
        filterVC.filterDelegate = self
        let filterVCNav = UINavigationController(rootViewController: filterVC)
        present(filterVCNav, animated: true, completion: nil)
    }
}

// MARK: Movie service
extension FavoritesViewController {
    func getFavoriteMovies() {
        movies = Movie.getCachedMovies()
        if hasFilter {
            filter.apply(on: &movies)
            movies.sort { (prev, curr) -> Bool in
                guard let prevDate = prev.dateAddedToFavorites,
                    let currDate = curr.dateAddedToFavorites else {
                        return false
                }
                return prevDate.compare(currDate) == .orderedAscending
            }
        }
    }
}

// MARK: ScrollDelegate
extension FavoritesViewController: ScrollDelegate {
    func scrollToTop() {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

// MARK: UITableViewDelegate
extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let movieApi = MovieApi()
        let movieDetailVC = MovieDetailViewController(movie: movie, movieApi: movieApi)
        movieDetailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}

// MARK: UITableViewDataSource
extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteTableViewCell.identifier, for: indexPath) as! FavoriteTableViewCell
        let movie = movies[indexPath.row]
        cell.movie = movie
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FavoriteTableViewCell.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: FavoriteFilterTableViewHeader.identifier) as! FavoriteFilterTableViewHeader
        header.hasFilter = hasFilter
        header.onFilterPressed = {
            self.showFilterVC()
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return FavoriteFilterTableViewHeader.height
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Unfavorite") { _,_  in
            let movie = self.movies[indexPath.row]
            movie.isFavorite = false
            movie.dateAddedToFavorites = nil
            NotificationCenter.default.post(name: .onMovieFavorited, object: nil, userInfo: ["movie": movie])
        }
        
        return [deleteAction]
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.reloadData()
    }
}

// MARK: FilterDelegate
extension FavoritesViewController: FilterDelegate {
    func onFilter(with filter: Filter) {
        self.filter = filter
        getFavoriteMovies()
    }
    
    func onRemoveFilter() {
        filter.reset()
        hasFilter = false
        getFavoriteMovies()
    }
}
