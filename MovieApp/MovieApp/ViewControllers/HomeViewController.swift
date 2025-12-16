//
//  HomeViewController.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 13.12.2025.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController {

    private var movies: [Movie] = []
    private var premiere: Movie?

    @IBOutlet weak var premierPoster: UIImageView!
    @IBOutlet weak var tagsStack: UIStackView!
    @IBOutlet weak var premierOverview: UILabel!
    @IBOutlet weak var premierTitle: UILabel!
    
    @IBOutlet weak var gradientLayer: GradientView!
    @IBOutlet weak var movieCollection: CarouselCollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecommendations()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

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

    private func loadRecommendations() {
        APIClient.shared.getMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let movies):
                    self.movies = movies
                    self.premiere = movies.first
                case .failure:
                    self.movies = []
                    self.premiere = nil
                }
                self.setupPremierSection()
                self.setupCollection()
            }
        }
    }

    private func setupPremierSection() {
        guard let movie = premiere else {
            premierPoster.image = UIImage(systemName: "film")
            premierTitle.text = "No data"
            premierOverview.text = "No overview available."
            tagsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            return
        }

        if let url = movie.posterURL {
            premierPoster.kf.setImage(
                with: url,
                options: [.transition(.fade(0.35)), .cacheOriginalImage]
            )
        } else {
            premierPoster.image = UIImage(systemName: "film")
        }

        premierTitle.text = movie.title.uppercased()
        premierOverview.text = movie.overview ?? "No overview available."

        tagsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let genres = movie.genres {
            for genre in genres {
                let genreLabel = UILabel()
                genreLabel.text = genre
                genreLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
                genreLabel.textColor = .white
                genreLabel.numberOfLines = 1
                genreLabel.textAlignment = .center
                tagsStack.addArrangedSubview(genreLabel)
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
        movieCollection.reloadData()
    }
}
