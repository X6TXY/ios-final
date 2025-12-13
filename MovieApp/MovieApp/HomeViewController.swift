//
//  HomeViewController.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 13.12.2025.
//

import UIKit

class HomeViewController: UIViewController {

    let movies = ["Movie1", "Movie2", "Movie3", "Movie4", "Movie5", "Movie6"]

    @IBOutlet weak var movieCollection: CarouselCollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        movieCollection.itemsCount = movies.count

        movieCollection.onSelectItem = { [weak self] index in
            guard let self else { return }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailsVC = storyboard.instantiateViewController(
                withIdentifier: "DetailsViewController"
            ) as! DetailsViewController

            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
}
