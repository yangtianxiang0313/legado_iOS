//
//  SettingsViewController.swift
//  legado
//
//  我的 Tab，对应 Android MyFragment
//

import UIKit

final class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "我的"
        addPlaceholderLabel(text: "我的")
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
