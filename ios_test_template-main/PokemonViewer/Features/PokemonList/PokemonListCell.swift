//
//  PokemonListCell.swift
//  PokemonViewer
//
//  Created by Dmytro Lyshtva on 25/9/25.
//

import UIKit

final class PokemonListCell: UITableViewCell {
    static let reuseID = "PokemonListCell"

    private let thumb = UIImageView()
    private let nameLabel = UILabel()
    private let idLabel = UILabel()
    private let favButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .medium)

    var onToggleFavorite: (() -> Void)?
    var onDelete: (() -> Void)?

    private var currentURL: URL?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func buildUI() {
        selectionStyle = .none

        thumb.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        favButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false

        thumb.contentMode = .scaleAspectFit
        thumb.clipsToBounds = true
        thumb.layer.cornerRadius = 8
        thumb.backgroundColor = UIColor.secondarySystemBackground

        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        idLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        idLabel.textColor = .secondaryLabel

        favButton.setImage(UIImage(systemName: "star"), for: .normal)
        favButton.tintColor = .systemYellow

        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed

        contentView.addSubview(thumb)
        contentView.addSubview(nameLabel)
        contentView.addSubview(idLabel)
        contentView.addSubview(favButton)
        contentView.addSubview(deleteButton)
        contentView.addSubview(spinner)

        NSLayoutConstraint.activate([
            thumb.widthAnchor.constraint(equalToConstant: 56),
            thumb.heightAnchor.constraint(equalToConstant: 56),
            thumb.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumb.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: thumb.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: favButton.leadingAnchor, constant: -8),

            idLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            idLabel.trailingAnchor.constraint(lessThanOrEqualTo: favButton.leadingAnchor, constant: -8),
            idLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),

            favButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            favButton.widthAnchor.constraint(equalToConstant: 32),
            favButton.heightAnchor.constraint(equalToConstant: 32),

            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            deleteButton.widthAnchor.constraint(equalToConstant: 32),
            deleteButton.heightAnchor.constraint(equalToConstant: 32),

            spinner.centerXAnchor.constraint(equalTo: thumb.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: thumb.centerYAnchor),
        ])

        favButton.addTarget(self, action: #selector(tapFav), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(tapDelete), for: .touchUpInside)
    }

    func configure(
        with vm: PokemonListCellViewModel,
        imageLoader: ImageLoader
    ) {
        nameLabel.text = vm.name
        idLabel.text = "#\(vm.id)"
        updateFavoriteIcon(isFavorite: vm.isFavorite)

        currentURL = vm.imageURL
        thumb.image = nil

        if let url = vm.imageURL {
            spinner.startAnimating()
            imageLoader.load(url) { [weak self] image in
                guard let self, self.currentURL == url else { return }
                self.thumb.image = image
                self.spinner.stopAnimating()
            }
        } else {
            spinner.stopAnimating()
        }
    }

    private func updateFavoriteIcon(isFavorite: Bool) {
        let symbolName = isFavorite ? "star.fill" : "star"
        favButton.setImage(UIImage(systemName: symbolName), for: .normal)
    }

    @objc private func tapFav() { onToggleFavorite?() }
    @objc private func tapDelete() { onDelete?() }
}
