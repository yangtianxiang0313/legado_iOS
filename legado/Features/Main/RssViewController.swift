//
//  RssViewController.swift
//  legado
//
//  RSS Tab，对应 Android RssFragment
//

import UIKit

final class RssViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "RSS"
        addPlaceholderLabel(text: "RSS")
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
