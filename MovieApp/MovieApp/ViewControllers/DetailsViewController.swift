//
//  DetailsViewController.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 13.12.2025.
//

//
//  DetailsViewController.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 13.12.2025.
//

import UIKit
import Kingfisher

struct CastMember {
    let name: String
    let image: UIImage
}

class DetailsViewController: UIViewController {

    
    var movie: Movie? = nil
    
    private let topCast: [CastMember] = [
        CastMember(name: "Actor 1", image: UIImage(named: "actor")!),
        CastMember(name: "Actor 2", image: UIImage(named: "actor")!),
        CastMember(name: "Actor 3", image: UIImage(named: "actor")!),
        CastMember(name: "Actor 4", image: UIImage(named: "actor")!),
        CastMember(name: "Actor 5", image: UIImage(named: "actor")!),
        CastMember(name: "Actor 6", image: UIImage(named: "actor")!)
    ]
    
    private var isExpanded = false
    
    
    @IBOutlet weak var movieBackdrop: UIImageView!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var synopsisContent: UILabel!
    @IBOutlet weak var synopsisGradient: GradientView!
    @IBOutlet weak var castStackView: UIStackView!
    @IBOutlet weak var movieInfoContainer: UIView!
    @IBOutlet weak var movieInfoGradient: GradientView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupUI()
        configureMovieDetails()
        configureCast(topCast)
    }
    
    
    private func setupNavigationBar() {
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        navBar.backgroundColor = .clear
        navBar.tintColor = .white
    }
    
    private func setupUI() {
        synopsisContent.numberOfLines = 3
        expandButton.setImage(UIImage(systemName: "arrow.down"), for: .normal)
        
        let bgColor = view.backgroundColor ?? .white
        
        synopsisGradient.setupGradient(
            colors: [.clear, bgColor],
            startPoint: CGPoint(x: 0.5, y: 0),
            endPoint: CGPoint(x: 0.5, y: 1),
            locations: [0.0, 0.3]
        )
        
        movieInfoGradient.setupGradient(
            colors: [bgColor, .clear],
            startPoint: CGPoint(x: 0.5, y: 1),
            endPoint: CGPoint(x: 0.5, y: 0),
            locations: [0.0, 1.0]
        )
    }
    
    private func configureMovieDetails() {
        guard let movie = movie else { return }
        
        // Poster & Backdrop
        if let posterURL = movie.poster_url, let url = URL(string: posterURL) {
            moviePoster.kf.setImage(
                with: url,
                options: [
                    .transition(.fade(0.35)),
                    .cacheOriginalImage
                ]
            )
        }

        if let backdropURL = movie.backdrop_url, let url = URL(string: backdropURL) {
            movieBackdrop.kf.setImage(
                with: url,
                options: [
                    .transition(.fade(0.45)),
                    .cacheOriginalImage
                ]
            )
        }

        
        // Labels
        ratingLabel.text = movie.rating != nil ? "\(movie.rating!)/10" : "-"
        releaseYearLabel.text = releaseYear(from: movie.release_date)
        genreLabel.text = movie.genres?.first ?? "-"
        synopsisContent.text = movie.overview ?? "No synopsis available."
    }
    
    func releaseYear(from dateString: String?) -> String {
        guard let dateString else { return "N/A" }
        return String(dateString.prefix(4))
    }

    
    @IBAction func expandedSynopsis(_ sender: UIButton) {
        isExpanded.toggle()
        synopsisContent.numberOfLines = isExpanded ? 0 : 3
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
        
        let imageName = isExpanded ? "arrow.up" : "arrow.down"
        expandButton.setImage(UIImage(systemName: imageName), for: .normal)
        synopsisGradient.isHidden = isExpanded
    }
    
    
    private func configureCast(_ cast: [CastMember]) {
        var index = 0
        
        for horizontalStack in castStackView.arrangedSubviews {
            guard let hStack = horizontalStack as? UIStackView else { continue }
            
            for view in hStack.arrangedSubviews {
                guard index < cast.count else { return }
                let castMember = cast[index]
                
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.image = castMember.image
                    imageView.layer.cornerRadius = imageView.bounds.width / 2
                    imageView.clipsToBounds = true
                }
                
                if let label = view.viewWithTag(2) as? UILabel {
                    label.text = castMember.name
                }
                
                index += 1
            }
        }
    }
}

