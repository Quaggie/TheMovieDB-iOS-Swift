//
//  MovieCollectionViewFooter.swift
//  Movs
//
//  Created by Jonathan Bijos on 28/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

enum MovieFooterViewState {
    case loading
    case error
}

class MovieCollectionViewFooter: UICollectionReusableView, CellHeight {
    
    static var height: CGFloat {
        return 80
    }
    
    var onTryAgain: (() -> ())?
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        return ai
    }()
    
    private lazy var tryAgainBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Try again", for: .normal)
        btn.backgroundColor = ColorPalette.yellow
        btn.tintColor = ColorPalette.black
        btn.layer.cornerRadius = 2.0
        btn.layer.borderWidth = 2.0
        btn.layer.borderColor = ColorPalette.black.cgColor
        btn.addTarget(self, action: #selector(tryAgain), for: .touchUpInside)
        return btn
    }()
    
    var state: MovieFooterViewState = .loading {
        didSet {
            switch state {
            case .loading:
                debugPrint("Appeared with loading")
                activityIndicator.startAnimating()
                tryAgainBtn.isHidden = true
            case .error:
                debugPrint("Appeared with error")
                activityIndicator.stopAnimating()
                tryAgainBtn.isHidden = false
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Layout
extension MovieCollectionViewFooter {
    private func setupViews () {
        backgroundColor = .clear
        
        addSubview(activityIndicator)
        activityIndicator.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 8, right: 8))
        
        addSubview(tryAgainBtn)
        tryAgainBtn.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 8, right: 8))
    }
}

// MARK: Actions
extension MovieCollectionViewFooter {
    @objc private func tryAgain() {
        onTryAgain?()
    }
}
