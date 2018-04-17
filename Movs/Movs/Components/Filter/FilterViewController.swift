//
//  FilterViewController.swift
//  Movs
//
//  Created by Jonathan Bijos on 02/03/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

protocol FilterDelegate: AnyObject {
    func onFilter(with filter: Filter)
    func onRemoveFilter()
}

class FilterViewController: BaseViewController {
    
    let filter: Filter
    var filterDelegate: FilterDelegate?
    
    var rows: [FilterType] = []
    
    var selectedYear: Int? {
        didSet {
            filter.selectedYear = selectedYear
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
    var selectedGenre: Genre? {
        didSet {
            filter.selectedGenre = selectedGenre
            tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        }
    }
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        tv.register(FilterRowTableViewCell.self, forCellReuseIdentifier: FilterRowTableViewCell.identifier)
        return tv
    }()
    
    init(filter: Filter) {
        self.filter = filter
        defer {
            selectedYear = filter.selectedYear
            selectedGenre = filter.selectedGenre
        }
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        rows = [.year, .genre]
        tableView.reloadData()
    }
    
    override func setupViews() {
        super.setupViews()
        
        view.addSubview(tableView)
        tableView.fillSuperviewSafeLayoutGuide()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        let resetBtn = UIBarButtonItem(title: "Reset", style: .done, target: self, action: #selector(reset))
        navigationItem.rightBarButtonItems = [doneBtn, resetBtn]
    }
}

// MARK: Actions
extension FilterViewController {
    @objc private func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func done() {
        filterDelegate?.onFilter(with: filter)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func reset() {
        filter.reset()
        selectedYear = nil
        selectedGenre = nil
    }
}

// MARK: UITableViewDelegate
extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = rows[indexPath.row]
        switch row {
        case .year:
            let movieApi = MovieApi()
            let vc = YearListViewController(movieApi: movieApi)
            vc.delegate = self
            vc.selectedYear = selectedYear
            navigationController?.pushViewController(vc, animated: true)
        case .genre:
            let movieApi = MovieApi()
            let vc = GenreListViewController(movieApi: movieApi)
            vc.delegate = self
            vc.selectedGenre = selectedGenre
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: UITableViewDataSource
extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]
        let cell = FilterRowTableViewCell(filterType: row)
        cell.textLabel?.text = row.rawValue
        
        switch row {
        case .year:
            if let selectedYear = selectedYear {
                cell.detailTextLabel?.text = "\(selectedYear)"
            } else {
                cell.detailTextLabel?.text = nil
            }
        case .genre:
            if let selectedGenre = selectedGenre {
                cell.detailTextLabel?.text = selectedGenre.name
            } else {
                cell.detailTextLabel?.text = nil
            }
        }
        
        return cell
    }
}

// MARK: YearListDelegate
extension FilterViewController: YearListDelegate {
    func onSelect(year: Int?) {
        selectedYear = year
    }
}

// MARK: GenreListDelegate
extension FilterViewController: GenreListDelegate {
    func onSelect(genre: Genre?) {
        selectedGenre = genre
    }
}
