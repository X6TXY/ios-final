//
//  ViewController.swift
//  MovieApp
//
//  Created by Baha Toleu on 10.12.2025.
//

import UIKit

final class ViewController: UIViewController {

    private enum Page: String, CaseIterable {
        case auth = "Auth Screen"
    }

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "MovieApp Pages"
        view.backgroundColor = .systemBackground
        configureTable()
        layoutTable()
    }

    private func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func layoutTable() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Page.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let page = Page.allCases[indexPath.row]
        cell.textLabel?.text = page.rawValue
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let page = Page.allCases[indexPath.row]
        switch page {
        case .auth:
            let authVC = AuthViewController()
            if let nav = navigationController {
                nav.pushViewController(authVC, animated: true)
            } else {
                present(UINavigationController(rootViewController: authVC), animated: true)
            }
        }
    }
}
