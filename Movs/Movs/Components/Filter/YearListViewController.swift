//
//  YearListViewController.swift
//  Movs
//
//  Created by Jonathan Bijos on 02/03/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

protocol YearListDelegate: AnyObject {
    func onSelect(year: Int?)
}

class YearListViewController: BaseViewController {
    
    let movieApi: MovieService
    var selectedYear: Int? {
        didSet {
            tableView.reloadData()
        }
    }
    private var list: [Int] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var delegate: YearListDelegate?
    
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
        var years: [Int] = []
        for year in 1900...2018 {
            years.append(year)
        }
        list = years.reversed()
    }
    
    override func setupViews() {
        super.setupViews()
        
        view.addSubview(tableView)
        tableView.fillSuperviewSafeLayoutGuide()
    }
}

// MARK: UITableViewDelegate
extension YearListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let year = list[indexPath.row]
        if let selectedYear = selectedYear {
            if selectedYear == year {
                self.selectedYear = nil
            } else {
                self.selectedYear = year
            }
        } else {
            selectedYear = year
        }
        delegate?.onSelect(year: selectedYear)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: UITableViewDataSource
extension YearListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath)
        let year = list[indexPath.row]
        cell.textLabel?.text = "\(year)"
        if let selectedYear = selectedYear, selectedYear == year {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}
