//
//  PokemonDetailViewController.swift
//  PokemonViewer
//
//  Created by Dmytro Lyshtva on 25/9/25.
//

import UIKit

final class PokemonDetailViewController: UIViewController {
    private let vm: PokemonDetailViewModel
    private let imageLoader: ImageLoader

    // MARK: - UI
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let heightLabel = UILabel()
    private let weightLabel = UILabel()
    private lazy var favoriteButton = UIButton(type: .system)

    // MARK: - Init
    init(viewModel: PokemonDetailViewModel, imageLoader: ImageLoader = .shared) {
        self.vm = viewModel
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        view.backgroundColor = .systemBackground
        buildUI()
        fillData()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(syncFavoriteUI),
                                               name: FavoritesStore.changed,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup UI
    private func buildUI() {
        // imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.secondarySystemBackground

        // labels
        [nameLabel, heightLabel, weightLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        heightLabel.font = .systemFont(ofSize: 16, weight: .regular)
        weightLabel.font = .systemFont(ofSize: 16, weight: .regular)
        heightLabel.textColor = .secondaryLabel
        weightLabel.textColor = .secondaryLabel

        // favoriteButton
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setContentHuggingPriority(.required, for: .horizontal)
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)

        // add subviews
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(heightLabel)
        view.addSubview(weightLabel)
        view.addSubview(favoriteButton)

        // layout
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 24),
            imageView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: guide.widthAnchor, multiplier: 0.6),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: favoriteButton.leadingAnchor, constant: -8),

            favoriteButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),

            heightLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            heightLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            heightLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),

            weightLabel.topAnchor.constraint(equalTo: heightLabel.bottomAnchor, constant: 8),
            weightLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            weightLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
        ])
    }

    // MARK: - Fill data
    private func fillData() {
        nameLabel.text = vm.name
        heightLabel.text = "Height: \(vm.height)"
        weightLabel.text = "Weight: \(vm.weight)"
        updateFavoriteButton()

        if let url = vm.imageURL {
            imageLoader.load(url) { [weak self] image in
                self?.imageView.image = image
            }
        }
    }

    private func updateFavoriteButton() {
        let systemName = vm.isFavorite ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: systemName), for: .normal)
        favoriteButton.setTitle(" Favorite", for: .normal)
    }

    // MARK: - Actions
    @objc private func didTapFavorite() {
        vm.toggleFavorite()
        updateFavoriteButton() // локальний апдейт
    }

    @objc private func syncFavoriteUI() {
        updateFavoriteButton()
    }
}
