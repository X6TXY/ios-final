//
//  FeedViewController.swift
//  MovieApp
//
//  Created by Uldana Shyndali on 14.12.2025.
//

import UIKit


class FeedViewController: UIViewController {

    private let activities: [FriendsActivity] = FriendsActivity.dummies

    @IBOutlet private weak var table: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        table.dataSource = self
        table.delegate = self

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
