//
//  FavoriteFilterTableViewHeader.swift
//  Movs
//
//  Created by Jonathan Bijos on 02/03/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

class FavoriteFilterTableViewHeader: BaseTableViewHeaderFooterView, CellHeight {
    
    static var height: CGFloat {
        return 60
    }
    
    var hasFilter: Bool = false {
        didSet {
            let title = hasFilter ? "Edit filter" : "Add filter"
            btn.setTitle(title, for: .normal)
        }
    }
    var onFilterPressed: (() -> ())?
    
    private lazy var btn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add filter", for: .normal)
        btn.addTarget(self, action: #selector(onFilterButtonPressed), for: .touchUpInside)
        btn.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        btn.tintColor = ColorPalette.yellow
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return btn
    }()

    override func setupViews() {
        super.setupViews()
        
        contentView.backgroundColor = ColorPalette.black
        contentView.addSubview(btn)
        btn.fillSuperview()
    }
}

// MARK: Actions
extension FavoriteFilterTableViewHeader {
    @objc private func onFilterButtonPressed() {
        onFilterPressed?()
    }
}
