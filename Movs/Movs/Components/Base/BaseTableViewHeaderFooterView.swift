//
//  BaseTableViewHeaderFooterView.swift
//  Movs
//
//  Created by Jonathan Bijos on 02/03/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

class BaseTableViewHeaderFooterView: UITableViewHeaderFooterView, Identifiable {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        let bgView = UIView(frame: bounds)
        bgView.backgroundColor = .white
        backgroundView = bgView
    }
}
