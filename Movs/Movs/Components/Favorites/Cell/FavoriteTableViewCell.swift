//
//  FavoriteTableViewCell.swift
//  Movs
//
//  Created by Jonathan Bijos on 01/03/18.
//  Copyright © 2018 Jonathan Bijos. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: BaseTableViewCell, CellHeight {
    
    static var height: CGFloat {
        return 110
    }
    
    var movie: Movie? {
        didSet {
            if let title = movie?.title {
                titleLabel.text = title
            }
            if let year = movie?.releaseYear {
                dateLabel.text = year
            }
            if let overview = movie?.overview {
                descriptionLabel.text = overview
            }
            if let posterUrlString = movie?.posterUrlString, let url = URL(string: posterUrlString) {
                imgView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
        }
    }
    
    private let imgView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = ColorPalette.yellow.withAlphaComponent(0.2)
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorPalette.black
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorPalette.black
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorPalette.black
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 3
        return label
    }()

    override func setupViews() {
        super.setupViews()
        
        contentView.addSubview(imgView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(descriptionLabel)
        
        imgView.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: contentView.bottomAnchor, trailing: nil, padding: .zero, size: .init(width: 80, height: 0))
        
        titleLabel.anchor(top: contentView.topAnchor, leading: imgView.trailingAnchor, bottom: nil, trailing: dateLabel.leadingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16), size: .zero)
        
        dateLabel.anchor(top: contentView.topAnchor, leading: nil, bottom: nil, trailing: contentView.trailingAnchor, padding: .init(top: 16, left: 0, bottom: 0, right: 16), size: .zero)
        
        descriptionLabel.anchor(top: titleLabel.bottomAnchor, leading: imgView.trailingAnchor, bottom: contentView.bottomAnchor, trailing: contentView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 16, right: 16), size: .zero)
    }
}
