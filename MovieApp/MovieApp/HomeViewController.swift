//
//  HomeViewController.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 13.12.2025.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var movieCollection: UICollectionView!
    
    let movies = ["Movie1", "Movie2", "Movie3", "Movie4", "Movie5", "Movie6"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieCollection.dataSource = self
        movieCollection.delegate = self

        movieCollection.collectionViewLayout = createCarouselLayout()
        movieCollection.decelerationRate = .fast  // For snapping effect
        movieCollection.backgroundColor = .clear
    }
    
    func createCarouselLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            
            // Item size
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(120), heightDimension: .absolute(180))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Optional: add spacing between items
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
            
            // Group
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(120), heightDimension: .absolute(180))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            
            // Add scaling effect for center item
            section.visibleItemsInvalidationHandler = { (items, offset, environment) in
                let centerX = offset.x + environment.container.contentSize.width / 2
                for item in items {
                    let distance = abs(item.center.x - centerX)
                    let scale = max(1 - (distance / 500), 0.8)  // adjust 0.8 for min scale
                    item.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }
            
            return section
        }
        return layout
    }
}
    

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return movies.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moviePoster", for: indexPath)

       
            return cell
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = movies[indexPath.item]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsVC = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController


        navigationController?.pushViewController(detailsVC, animated: true)
    }


}

