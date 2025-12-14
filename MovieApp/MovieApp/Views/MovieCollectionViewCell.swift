//
//  MovieCollectionViewCell.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 14.12.2025.
//

import UIKit
import Kingfisher

class MovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var moviePoster: UIImageView!

    private let placeholderImage = UIImage(named: "placeholderPoster")

    override func prepareForReuse() {
        super.prepareForReuse()
        moviePoster.kf.cancelDownloadTask()
        moviePoster.image = placeholderImage
    }

    func configure(movie: Movie) {
        moviePoster.image = placeholderImage

        guard
            let posterURLString = movie.poster_url,
            let url = URL(string: posterURLString)
        else {
            return
        }

        moviePoster.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .transition(.fade(0.25)),
                .cacheOriginalImage
            ]
        )
    }
}
