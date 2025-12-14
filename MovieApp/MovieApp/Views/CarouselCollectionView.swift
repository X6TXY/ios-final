//
//  CarouselCollectionView.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 13.12.2025.
//

import UIKit

class CarouselCollectionView: UICollectionView {

    var movies: [Movie] = [] {
        didSet { reloadData() }
    }

    var onSelectItem: ((Movie) -> Void)?

    /// Computed property for user preference
    private var animationEnabled: Bool {
        if UserDefaults.standard.object(forKey: "carouselAnimationEnabled") == nil {
            // Default: animation ON
            return true
        }
        return UserDefaults.standard.bool(forKey: "carouselAnimationEnabled")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }

    private func setup() {
        dataSource = self
        delegate = self

        collectionViewLayout = Self.createLayout(animationEnabled: animationEnabled)
        decelerationRate = .fast
        backgroundColor = .clear
    }
}

// MARK: - Layout

extension CarouselCollectionView {

    static func createLayout(animationEnabled: Bool) -> UICollectionViewCompositionalLayout {

        UICollectionViewCompositionalLayout { _, environment -> NSCollectionLayoutSection? in

            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(120),
                heightDimension: .absolute(180)
            )

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: itemSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

            if animationEnabled {
                section.visibleItemsInvalidationHandler = { items, offset, environment in
                    let centerX = offset.x + environment.container.contentSize.width / 2
                    for item in items {
                        let distance = abs(item.center.x - centerX)
                        let scale = max(1 - (distance / 500), 0.8)
                        item.transform = CGAffineTransform(scaleX: scale, y: scale)
                    }
                }
            }

            return section
        }
    }
}

// MARK: - DataSource & Delegate

extension CarouselCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        movies.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = dequeueReusableCell(
            withReuseIdentifier: "moviePoster",
            for: indexPath
        ) as! MovieCollectionViewCell

        let movie = movies[indexPath.item]
        cell.configure(movie: movie)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.item]
        onSelectItem?(movie)
    }
}
