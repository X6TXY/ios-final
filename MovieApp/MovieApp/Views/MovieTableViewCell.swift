//
//  MovieTableViewCell.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 14.12.2025.
//

import UIKit
import Kingfisher

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var activityTimeLabel: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var actionTitle: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var actionIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        userProfilePicture.image = UIImage(systemName: "person.circle")
        moviePoster.image = UIImage(named: "poster_placeholder")
    }


    func configure(with activity: FriendsActivity) {
        let movie = activity.movie
        let user = activity.user
        let profile = activity.user_profile

        // Movie info
        movieTitle.text = movie.title
        releaseYearLabel.text = releaseYear(from: movie.release_date)
        movieOverview.text = movie.overview ?? "No overview available"

        // User avatar
        if let avatarURL = profile.avatar_url,
           let url = URL(string: avatarURL) {
            userProfilePicture.kf.setImage(
                with: url,
                placeholder: UIImage(systemName: "person.circle"),
                options: [.transition(.fade(0.25))]
            )
        }

        // Movie poster
        if let url = movie.posterURL {
            moviePoster.kf.setImage(
                with: url,
                placeholder: UIImage(named: "poster_placeholder"),
                options: [.transition(.fade(0.25))]
            )
        }

        // Activity
        configureActivity(activity.activity, username: user.username)
    }

    // MARK: - Private

    private func setupUI() {
        userProfilePicture.layer.cornerRadius = userProfilePicture.bounds.width / 2
        userProfilePicture.clipsToBounds = true

        moviePoster.layer.cornerRadius = 8
        moviePoster.clipsToBounds = true

        actionIcon.tintColor = .systemRed
    }

    private func configureActivity(_ activity: Activity, username: String) {
        switch activity {
        case .like:
            actionTitle.text = "Liked by @\(username)"
            actionIcon.image = UIImage(systemName: "heart.fill")
            actionIcon.tintColor = .systemRed

        case .dislike:
            actionTitle.text = "Disliked by @\(username)"
            actionIcon.image = UIImage(systemName: "hand.thumbsdown.fill")
            actionIcon.tintColor = .systemGray

        case .watchlist:
            actionTitle.text = "Watchlisted by @\(username)"
            actionIcon.image = UIImage(systemName: "plus.circle.fill")
            actionIcon.tintColor = .systemBlue
        }
    }

    private func releaseYear(from dateString: String?) -> String {
        guard let dateString else { return "N/A" }
        return String(dateString.prefix(4))
    }
}
