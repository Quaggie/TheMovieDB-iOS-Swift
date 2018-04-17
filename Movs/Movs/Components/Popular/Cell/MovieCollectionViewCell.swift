//
//  MovieCollectionViewCell.swift
//  Movs
//
//  Created by Jonathan Pereira Bijos on 27/02/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit
import Kingfisher

class MovieCollectionViewCell: BaseCollectionViewCell, CellHeight {
    
    static var height: CGFloat {
        return 240
    }
    
    var movie: Movie? {
        didSet {
            if let title = movie?.title {
                titleLabel.text = title
            }
            if let posterUrlString = movie?.posterUrlString, let url = URL(string: posterUrlString) {
                imgView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
            if let isFavorite = movie?.isFavorite, isFavorite {
                favoriteBtn.tintColor = UIButton.appearance().tintColor
            } else {
                favoriteBtn.tintColor = UIColor.lightGray
            }
        }
    }
    
    var onToggleFavorite: ((Bool) -> ())?
    
    private let imgView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = ColorPalette.yellow.withAlphaComponent(0.2)
        return iv
    }()
    
    private let textPlaceholderView: UIView = {
        let v = UIView()
        v.backgroundColor = ColorPalette.yellow
        return v
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorPalette.black
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var favoriteBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "favorite_full_icon"), for: .normal)
        btn.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        btn.contentEdgeInsets = .init(top: 8, left: 0, bottom: 8, right: 8)
        btn.setContentCompressionResistancePriority(.required, for: .horizontal)
        btn.setContentHuggingPriority(.required, for: .horizontal)
        btn.tintColor = UIColor.lightGray
        return btn
    }()
    
    override func setupViews() {
        super.setupViews()
        
        contentView.layer.cornerRadius = 3.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3.0)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        
        contentView.addSubview(imgView)
        contentView.addSubview(textPlaceholderView)
        
        imgView.anchor(top: topAnchor, leading: leadingAnchor, bottom: textPlaceholderView.topAnchor, trailing: trailingAnchor, padding: .zero, size: .zero)
        imgView.kf.indicatorType = .activity
        
        textPlaceholderView.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: bounds.height * 0.15))
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        textPlaceholderView.addSubview(blurredEffectView)
        blurredEffectView.fillSuperview()
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        blurredEffectView.contentView.addSubview(vibrancyEffectView)
        
        vibrancyEffectView.contentView.addSubview(titleLabel)
        vibrancyEffectView.contentView.addSubview(favoriteBtn)
        
        vibrancyEffectView.fillSuperview()
        
        titleLabel.anchor(top: vibrancyEffectView.topAnchor, leading: vibrancyEffectView.leadingAnchor, bottom: vibrancyEffectView.bottomAnchor, trailing: favoriteBtn.leadingAnchor, padding: .init(top: 8, left: 8, bottom: 8, right: 8))
        
        favoriteBtn.anchor(top: vibrancyEffectView.topAnchor, leading: nil, bottom: vibrancyEffectView.bottomAnchor, trailing: vibrancyEffectView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
    }
}

// MARK: Actions
extension MovieCollectionViewCell {
    @objc private func toggleFavorite() {
        if let isFavorite = movie?.isFavorite {
            movie?.isFavorite = !isFavorite
            onToggleFavorite?(!isFavorite)
        } else {
            movie?.isFavorite = true
            onToggleFavorite?(true)
        }
    }
}
