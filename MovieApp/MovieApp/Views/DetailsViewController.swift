//
//  DetailsViewController.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 13.12.2025.
//

import UIKit

struct CastMember {
    let name: String
    let image: UIImage
}

class DetailsViewController: UIViewController {
    
    let topCast = [
        CastMember(name: "Actor 1", image: UIImage(named: "actor")!),
        CastMember(name: "Actor 2", image: UIImage(named: "actor")!),
        CastMember(name: "Actor 3", image: UIImage(named: "actor")!),
        CastMember(name: "Actor 4", image: UIImage(named: "actor")!),
        CastMember(name: "Actor 5", image: UIImage(named: "actor")!),
        CastMember(name: "Actor 6", image: UIImage(named: "actor")!)
    ]
    
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var synopsisContent: UILabel!
    @IBOutlet weak var synopsisGradient: GradientView!
    @IBOutlet weak var castStackView: UIStackView!
    @IBOutlet weak var movieInfoContainer: UIView!
    @IBOutlet weak var movieInfoGradient: GradientView!
    
    private var isExpanded = false
    private var synopsisGradientLayer: CAGradientLayer?
    private var movieInfoGradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        synopsisContent.numberOfLines = 3
        expandButton.setImage(UIImage(systemName: "arrow.down"), for: .normal)
        
        // Configure cast first so layouts are correct
        configureCast(topCast)
        
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

    private func setupNavigationBar() {
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        navBar.backgroundColor = .clear
        navBar.tintColor = .white
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

    func configureCast(_ cast: [CastMember]) {
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
