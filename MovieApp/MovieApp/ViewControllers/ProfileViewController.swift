//
//  ProfileViewController.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 14.12.2025.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController {

    private let movies: [Movie] = [Movie.dummy1, Movie.dummy2, Movie.dummy1, Movie.dummy2]
    private let user: User = .dummy1
    private let profile: Profile = .dummy1

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var gradientLayer: UIView!
    @IBOutlet weak var ovalLayer: UIView!
    
    @IBOutlet weak var likedCollection: CarouselCollectionView!
    @IBOutlet weak var watchlistCollection: CarouselCollectionView!
    @IBOutlet weak var dislikedCollection: CarouselCollectionView!

    @IBOutlet weak var carousselAnimationSwitch: UISwitch!
    
    @IBOutlet weak var clearTabBarSwitch: UISwitch!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar() 
        setupUI()
        setupCarousels()
        
        if UserDefaults.standard.object(forKey: "carouselAnimationEnabled") == nil {
                carousselAnimationSwitch.isOn = true
            } else {
                carousselAnimationSwitch.isOn = UserDefaults.standard.bool(forKey: "carouselAnimationEnabled")
            }
        
        let isTabBarClear = UserDefaults.standard.object(forKey: "tabBarClear") == nil
                ? true
                : UserDefaults.standard.bool(forKey: "tabBarClear")
            clearTabBarSwitch.isOn = isTabBarClear
    }
    
    private func setupNavigationBar() {
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        navBar.backgroundColor = .clear
        navBar.tintColor = .white
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Make oval layer and profile picture perfectly rounded
        profilePicture.layer.cornerRadius = profilePicture.bounds.width / 2
        profilePicture.clipsToBounds = true

        ovalLayer.layer.cornerRadius = ovalLayer.bounds.height / 2
        ovalLayer.clipsToBounds = true
    }

    private func setupUI() {
        username.text = user.username

        if let avatarURL = profile.avatar_url,
           let url = URL(string: avatarURL) {
            profilePicture.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "person.circle"),
                options: [.transition(.fade(0.25))]
            )
        } else {
            profilePicture.image = UIImage(systemName: "person.circle")
        }
    }

    private func setupCarousels() {
        setupCarousel(carousel: likedCollection, movies: movies)
        setupCarousel(carousel: dislikedCollection, movies: movies)
        setupCarousel(carousel: watchlistCollection, movies: movies)
    }

    private func setupCarousel(carousel: CarouselCollectionView, movies: [Movie]) {
        carousel.movies = movies

        carousel.onSelectItem = { [weak self] movie in
            guard let self else { return }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let detailsVC = storyboard.instantiateViewController(
                withIdentifier: "DetailsViewController"
            ) as! DetailsViewController

            detailsVC.movie = movie
            self.navigationController?.pushViewController(detailsVC, animated: true)
        }
    }
    @IBAction func carousselAnimationToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "carouselAnimationEnabled")
            
            let carousels = [likedCollection, watchlistCollection, dislikedCollection]
            for carousel in carousels {
                guard let carousel = carousel else { continue }
                carousel.collectionViewLayout = CarouselCollectionView.createLayout(animationEnabled: sender.isOn)
                carousel.reloadData()
            }
    }
    
    @IBAction func clearTabBarToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "tabBarClear")
      
            if let tabBarController = self.tabBarController as? ClearTabBarController {
                tabBarController.viewDidLoad()  // Re-run setup
            }
    }
}
