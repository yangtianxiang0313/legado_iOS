//
//  MainTabBarController.swift
//  legado
//
//  主界面容器，对应 Android MainActivity
//  4 Tab：书架、发现、RSS、我的
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
        setupViewControllers()
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .systemBlue
    }

    private func setupViewControllers() {
        let bookshelf = BookshelfViewController()
        bookshelf.tabBarItem = UITabBarItem(
            title: "书架",
            image: UIImage(systemName: "books.vertical"),
            tag: 0
        )

        let explore = ExploreViewController()
        explore.tabBarItem = UITabBarItem(
            title: "发现",
            image: UIImage(systemName: "magnifyingglass"),
            tag: 1
        )

        let rss = RssViewController()
        rss.tabBarItem = UITabBarItem(
            title: "RSS",
            image: UIImage(systemName: "antenna.radiowaves.left.and.right"),
            tag: 2
        )

        let settings = SettingsViewController()
        settings.tabBarItem = UITabBarItem(
            title: "我的",
            image: UIImage(systemName: "person.circle"),
            tag: 3
        )

        viewControllers = [
            UINavigationController(rootViewController: bookshelf),
            UINavigationController(rootViewController: explore),
            UINavigationController(rootViewController: rss),
            UINavigationController(rootViewController: settings)
        ]
    }
}
