//
//  FeedViewController.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 14.12.2025.
//

import UIKit

class FeedViewController: UIViewController {

    private var activities: [FriendsActivity] = []

    @IBOutlet private weak var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        table.dataSource = self
        table.delegate = self

        loadFeed()
    }

    private func loadFeed() {
        APIClient.shared.getMyActivity { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let items):
                    self.activities = self.mapActivityItemsToFeed(items: items)
                    self.table.reloadData()
                case .failure:
                    self.activities = []
                    self.table.reloadData()
                }
            }
        }
    }

    private func mapActivityItemsToFeed(items: [MovieActivityItem]) -> [FriendsActivity] {
        let currentUser = User(
            id: UserDefaults.standard.string(forKey: "current_user_id") ?? "",
            email: UserDefaults.standard.string(forKey: "current_user_email") ?? "",
            username: UserDefaults.standard.string(forKey: "current_user_username") ?? "me"
        )
        let profile = Profile(
            avatar_url: nil,
            id: "",
            user_id: currentUser.id
        )

        return items.map { item in
            let activity: Activity
            switch item.direction {
            case "dislike":
                activity = .dislike
            default:
                activity = .like
            }

            return FriendsActivity(
                movie: item.movie,
                user: currentUser,
                user_profile: profile,
                activity: activity
            )
        }
    }
}

extension FeedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "activityCell",
            for: indexPath
        ) as? MovieTableViewCell else {
            return UITableViewCell()
        }

        let activity = activities[indexPath.row]
        cell.configure(with: activity)

        return cell
    }
}

extension FeedViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let activity = activities[indexPath.row]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailsVC = storyboard.instantiateViewController(
            withIdentifier: "DetailsViewController"
        ) as? DetailsViewController else { return }

        detailsVC.movie = activity.movie

        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
