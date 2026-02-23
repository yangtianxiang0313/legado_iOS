//
//  ExploreViewController.swift
//  legado
//
//  发现 Tab，对应 Android ExploreFragment
//

import UIKit

final class ExploreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "发现"
        addPlaceholderLabel(text: "发现")
    }

    private func addPlaceholderLabel(text: String) {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
