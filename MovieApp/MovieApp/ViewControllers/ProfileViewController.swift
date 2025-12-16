//
//  ProfileViewController.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 14.12.2025.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController {

    private var likedMovies: [Movie] = []
    private var watchlistMovies: [Movie] = []
    private var dislikedMovies: [Movie] = []
    private var user: User? = nil
    private var profile: Profile? = nil

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
        setupCarousels()
        loadUserAndProfile()
        
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
        let userToShow = user ?? User.dummy1
        let profileToShow = profile ?? Profile.dummy1

        username.text = userToShow.username

        if let avatarURL = profileToShow.avatar_url,
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
        setupCarousel(carousel: likedCollection, movies: likedMovies)
        setupCarousel(carousel: dislikedCollection, movies: dislikedMovies)
        setupCarousel(carousel: watchlistCollection, movies: watchlistMovies)
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

    private func loadUserAndProfile() {
        APIClient.shared.getCurrentUser { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let user):
                    self.user = user
                    UserDefaults.standard.set(user.id, forKey: "current_user_id")
                    self.fetchProfileAndMovies(for: user.id)
                case .failure:
                    self.setupUI() // fallback to dummy
                }
            }
        }
    }

    private func fetchProfileAndMovies(for userId: String) {
        let group = DispatchGroup()

        group.enter()
        APIClient.shared.getProfile(userId: userId) { [weak self] profileResult in
            DispatchQueue.main.async {
                self?.profile = try? profileResult.get()
                group.leave()
            }
        }

        group.enter()
        APIClient.shared.getRecommendations { [weak self] moviesResult in
            DispatchQueue.main.async {
                if let movies = try? moviesResult.get() {
                    self?.likedMovies = movies
                    self?.watchlistMovies = movies
                    self?.dislikedMovies = movies
                    group.leave()
                } else {
                    self?.loadFallbackMovies(group: group)
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.setupUI()
            self?.setupCarousels()
        }
    }

    private func loadFallbackMovies(group: DispatchGroup) {
        APIClient.shared.getMovies { [weak self] result in
            DispatchQueue.main.async {
                defer { group.leave() }
                switch result {
                case .success(let movies):
                    self?.likedMovies = movies
                    self?.watchlistMovies = movies
                    self?.dislikedMovies = movies
                case .failure:
                    self?.likedMovies = []
                    self?.watchlistMovies = []
                    self?.dislikedMovies = []
                }
            }
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
