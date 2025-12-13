//
//  CarouselCollectionView.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 13.12.2025.
//

import UIKit

class CarouselCollectionView: UICollectionView {

    var itemsCount: Int = 0 {
        didSet { reloadData() }
    }

    var onSelectItem: ((Int) -> Void)?

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

        collectionViewLayout = Self.createLayout()
        decelerationRate = .fast
        backgroundColor = .clear
    }
}

extension CarouselCollectionView {

    static func createLayout() -> UICollectionViewCompositionalLayout {

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

            section.visibleItemsInvalidationHandler = { items, offset, environment in
                let centerX = offset.x + environment.container.contentSize.width / 2
                for item in items {
                    let distance = abs(item.center.x - centerX)
                    let scale = max(1 - (distance / 500), 0.8)
                    item.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            }

            return section
        }
    }
}

extension CarouselCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemsCount
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        dequeueReusableCell(
            withReuseIdentifier: "moviePoster",
            for: indexPath
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectItem?(indexPath.item)
    }
}
