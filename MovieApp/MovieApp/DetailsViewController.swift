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
    @IBOutlet weak var synopsisGradient: UIView!
    
    @IBOutlet weak var castStackView: UIStackView!
    
    @IBOutlet weak var movieInfoContainer: UIView!
    @IBOutlet weak var movieInfoGradient: UIView!
    
    private var isExpanded = false
    private var gradientLayer: CAGradientLayer?
    private var movieInfoGradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTabBar()

        synopsisContent.numberOfLines = 3
        expandButton.setImage(UIImage(systemName: "arrow.down"), for: .normal)

        // CREATE gradient layers once
        setupGradient()
        setupMovieInfoGradient()
    }
    
    
    private func setupNavigationBar() {
        if let navBar = navigationController?.navigationBar {
            navBar.setBackgroundImage(UIImage(), for: .default)
            navBar.shadowImage = UIImage()
            navBar.isTranslucent = true
            navBar.backgroundColor = .clear
            navBar.tintColor = .white
        }
    }
    
    private func setupTabBar() {
        if let tabBar = tabBarController?.tabBar {
            tabBar.backgroundImage = UIImage()
            tabBar.shadowImage = UIImage()
            tabBar.isTranslucent = true
            tabBar.backgroundColor = .clear
        }
    }
    
    private func setupGradient() {
        if gradientLayer == nil {
            let gradient = CAGradientLayer()
            gradient.colors = [
                view.backgroundColor?.withAlphaComponent(0.0).cgColor ?? UIColor.clear.cgColor,
                view.backgroundColor?.cgColor ?? UIColor.white.cgColor
            ]
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
            gradient.locations = [0.0, 0.3]
            synopsisGradient.layer.insertSublayer(gradient, at: 0)
            gradientLayer = gradient
            synopsisGradient.isUserInteractionEnabled = false
        }
    }

    private func setupMovieInfoGradient() {
        if movieInfoGradientLayer == nil {
            let gradient = CAGradientLayer()
            gradient.colors = [
                view.backgroundColor?.cgColor ?? UIColor.white.cgColor,
                (view.backgroundColor?.withAlphaComponent(0.0).cgColor) ?? UIColor.clear.cgColor
            ]
            gradient.startPoint = CGPoint(x: 0.5, y: 1)
            gradient.endPoint = CGPoint(x: 0.5, y: 0)
            gradient.locations = [0.0, 1.0]
            movieInfoGradient.layer.insertSublayer(gradient, at: 0)
            movieInfoGradientLayer = gradient
            movieInfoGradient.isUserInteractionEnabled = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // only update frames, do not recreate layers
        gradientLayer?.frame = synopsisGradient.bounds
        movieInfoGradientLayer?.frame = movieInfoGradient.bounds
        
        configureCast(topCast)
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
        
        print("castStackView arrangedSubviews count:", castStackView.arrangedSubviews.count)
        
        for (hIndex, horizontalStack) in castStackView.arrangedSubviews.enumerated() {
            guard let hStack = horizontalStack as? UIStackView else {
                print("Subview \(hIndex) is not a UIStackView, skipping")
                continue
            }
            print("Found horizontal stack \(hIndex), arrangedSubviews:", hStack.arrangedSubviews.count)
            
            for (vIndex, view) in hStack.arrangedSubviews.enumerated() {
                guard index < cast.count else { return }
                let castMember = cast[index]
                
                if let imageView = view.viewWithTag(1) as? UIImageView {
                    imageView.image = castMember.image
                    imageView.layer.cornerRadius = imageView.bounds.width / 2
                    imageView.clipsToBounds = true
                    print("Set image for horizontal stack \(hIndex), view \(vIndex)")
                } else {
                    print("No UIImageView with tag 1 in horizontal stack \(hIndex), view \(vIndex)")
                }
                
                if let label = view.viewWithTag(2) as? UILabel {
                    label.text = castMember.name
                    print("Set label text for horizontal stack \(hIndex), view \(vIndex)")
                } else {
                    print("No UILabel with tag 2 in horizontal stack \(hIndex), view \(vIndex)")
                }
                
                index += 1
            }
        }
        
        print("Finished configuring cast")
    }

}
