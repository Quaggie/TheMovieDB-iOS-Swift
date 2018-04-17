//
//  GenreListViewController.swift
//  Movs
//
//  Created by Jonathan Bijos on 02/03/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

protocol GenreListDelegate: AnyObject {
    func onSelect(genre: Genre?)
}

class GenreListViewController: BaseViewController {
    
    let movieApi: MovieService
    var selectedGenre: Genre? {
        didSet {
            tableView.reloadData()
        }
    }
    private var list: [Genre] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var delegate: GenreListDelegate?
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.separatorColor = ColorPalette.black
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        return tv
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
        Genre.getGenres(movieApi: movieApi) { [weak self] (result) in
            guard let welf = self else { return }
            
            switch result {
            case .success(let genres):
                welf.list = genres
            case .error(_):
                let alertController = UIAlertController(title: "Error", message: "Unable to retrieve genre list. Please, try again later", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                    welf.navigationController?.popViewController(animated: true)
                })
                alertController.addAction(okAction)
                welf.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        view.addSubview(tableView)
        tableView.fillSuperviewSafeLayoutGuide()
    }
}

// MARK: UITableViewDelegate
extension GenreListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let genre = list[indexPath.row]
        if let selectedGenre = selectedGenre {
            if selectedGenre == genre {
                self.selectedGenre = nil
            } else {
                self.selectedGenre = genre
            }
        } else {
            selectedGenre = genre
        }
        delegate?.onSelect(genre: selectedGenre)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: UITableViewDataSource
extension GenreListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        let genre = list[indexPath.row]
        cell.textLabel?.text = "\(genre.name)"
        if let selectedGenre = selectedGenre, selectedGenre == genre {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}
