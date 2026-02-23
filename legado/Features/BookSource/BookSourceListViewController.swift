//
//  BookSourceListViewController.swift
//  legado
//
//  书源管理列表（只读），对应 Android BookSourceActivity
//  Step 1.7：显示 name、url 等；无书源时显示空状态
//

import UIKit

final class BookSourceListViewController: UIViewController {

    private let repository = BookSourceRepository()
    private var sources: [BookSource] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "书源管理"
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadData() {
        do {
            sources = try repository.all()
        } catch {
            sources = []
        }
        tableView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        if sources.isEmpty {
            let label = UILabel()
            label.text = "暂无书源"
            label.textAlignment = .center
            label.textColor = .secondaryLabel
            label.font = .preferredFont(forTextStyle: .body)
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }
}

extension BookSourceListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sources.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let source = sources[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = source.bookSourceName
        config.secondaryText = source.bookSourceUrl
        config.secondaryTextProperties.color = .secondaryLabel
        config.secondaryTextProperties.numberOfLines = 2
        cell.contentConfiguration = config
        cell.accessoryType = .none
        return cell
    }
}
