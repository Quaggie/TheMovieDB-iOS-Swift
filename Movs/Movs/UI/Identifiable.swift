//
//  ReusableView.swift
//  Movs
//
//  Created by Jonathan Pereira Bijos on 27/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

protocol Identifiable: AnyObject {}

extension Identifiable where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension Identifiable where Self: UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}

extension Identifiable where Self: BaseTableViewHeaderFooterView {
    static var identifier: String {
        return String(describing: self)
    }
}
