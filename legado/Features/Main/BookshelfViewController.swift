//
//  BookshelfViewController.swift
//  legado
//
//  书架 Tab，对应 Android BookshelfFragment
//

import UIKit

final class BookshelfViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "书架"
        addPlaceholderLabel(text: "书架")
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
