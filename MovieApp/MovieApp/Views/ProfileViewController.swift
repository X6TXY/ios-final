//
//  ProfileViewController.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 14.12.2025.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let movies = ["Movie1", "Movie2", "Movie3", "Movie4", "Movie5", "Movie6"]

    @IBOutlet weak var likedCollection: CarouselCollectionView!
    
    @IBOutlet weak var watchlistCollection: CarouselCollectionView!
    
    @IBOutlet weak var dislikedCollection: CarouselCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCaroussel(carousell: likedCollection, movies: movies)
        setupCaroussel(carousell: dislikedCollection, movies: movies)
        setupCaroussel(carousell: watchlistCollection, movies: movies)
    }
    
    func setupCaroussel(carousell : CarouselCollectionView, movies : [String]) {
        carousell.itemsCount = movies.count
        carousell.onSelectItem = { [weak self] index in
            guard let self else { return }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailsVC = storyboard.instantiateViewController(
                withIdentifier: "DetailsViewController"
            ) as! DetailsViewController

            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }

}
