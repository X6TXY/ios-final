//
//  HomeViewController.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 13.12.2025.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController {

    let movies = [Movie.dummy1, Movie.dummy2, Movie.dummy2, Movie.dummy2]
    let premiere = Movie.dummy3

    @IBOutlet weak var premierPoster: UIImageView!
    @IBOutlet weak var tagsStack: UIStackView!
    @IBOutlet weak var premierOverview: UILabel!
    @IBOutlet weak var premierTitle: UILabel!
    
    @IBOutlet weak var gradientLayer: GradientView!
    @IBOutlet weak var movieCollection: CarouselCollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPremierSection()
        setupCollection()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Fix gradient cropping by setting the frame to the full view width
        gradientLayer.frame = CGRect(
            x: 0,
            y: gradientLayer.frame.origin.y,
            width: view.bounds.width,
            height: gradientLayer.frame.height
        )
        gradientLayer.setupGradient(
            colors: [.clear, view.backgroundColor ?? .white],
            startPoint: CGPoint(x: 0.5, y: 0),
            endPoint: CGPoint(x: 0.5, y: 1),
            locations: [0, 1]
        )
    }

    private func setupPremierSection() {
        // Poster
        if let posterURL = premiere.poster_url, let url = URL(string: posterURL) {
            premierPoster.kf.setImage(
                with: url,
                options: [.transition(.fade(0.35)), .cacheOriginalImage]
            )
        } else {
            premierPoster.image = UIImage(systemName: "film")
        }

        // Title in all caps
        premierTitle.text = premiere.title.uppercased()

        // Overview
        premierOverview.text = premiere.overview ?? "No overview available."

        // Add genres as individual labels, keep last element in stack
        if let genres = premiere.genres {
            for (index, genre) in genres.enumerated() {
                let genreLabel = UILabel()
                genreLabel.text = genre
                genreLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                genreLabel.textColor = .white
                genreLabel.numberOfLines = 1
                genreLabel.textAlignment = .center
                // Insert at start to keep last element intact
                tagsStack.insertArrangedSubview(genreLabel, at: index)
            }
        }
    }

    private func setupCollection() {
        movieCollection.movies = movies
        movieCollection.onSelectItem = { [weak self] movie in
            guard let self else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailsVC = storyboard.instantiateViewController(
                withIdentifier: "DetailsViewController"
            ) as! DetailsViewController
            detailsVC.movie = movie
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}
