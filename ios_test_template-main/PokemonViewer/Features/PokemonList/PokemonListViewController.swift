//
//  PokemonListViewController.swift
//  PokemonViewer
//
//  Created by Dmytro Lyshtva on 25/9/25.
//


import UIKit

final class PokemonListViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let viewModel: PokemonListViewModel
    private let imageLoader: ImageLoader

    private lazy var favBarButton = UIBarButtonItem(
        title: "★ 0", style: .plain, target: self, action: #selector(didTapFavorites))

    init(viewModel: PokemonListViewModel, imageLoader: ImageLoader = .shared) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pokémon"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = favBarButton

        setupTable()
        bind()
        updateFavoritesBadge()

        viewModel.loadInitial()
    }

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.register(PokemonListCell.self, forCellReuseIdentifier: PokemonListCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 76
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 84, bottom: 0, right: 0)
    }

    private func bind() {
        viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
            self?.updateFavoritesBadge()
        }
        viewModel.onError = { [weak self] message in
            self?.presentError(message)
        }

        NotificationCenter.default.addObserver(
            self, selector: #selector(favoritesChanged),
            name: FavoritesStore.changed, object: nil
        )
    }

    @objc private func favoritesChanged() { updateFavoritesBadge() }

    private func updateFavoritesBadge() {
        favBarButton.title = "★ \(FavoritesStore.shared.count)"
    }

    private func presentError(_ message: String) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            self?.viewModel.loadNextPage()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func didTapFavorites() {
        tableView.setContentOffset(.zero, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension PokemonListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.count
    }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: PokemonListCell.reuseID, for: indexPath) as! PokemonListCell
        let item = viewModel.item(at: indexPath)
        cell.configure(with: item, imageLoader: imageLoader)
        cell.onToggleFavorite = { [weak self] in self?.viewModel.toggleFavorite(at: indexPath.row) }
        cell.onDelete = { [weak self] in self?.viewModel.delete(at: indexPath.row) }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PokemonListViewController: UITableViewDelegate {
    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
        let item = viewModel.item(at: indexPath)

        let detailVM = PokemonDetailViewModel(
            id: item.id,
            name: item.name,
            height: item.height,
            weight: item.weight,
            imageURL: item.imageURL,
            favorites: FavoritesStore.shared
        )
        let detailVC = PokemonDetailViewController(viewModel: detailVM, imageLoader: imageLoader)
        navigationController?.pushViewController(detailVC, animated: true)
    }


    func tableView(_ tv: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= viewModel.count - 5 {
            viewModel.loadNextPage()
        }
    }

    func tableView(_ tv: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _,_,done in
            self?.viewModel.delete(at: indexPath.row)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

