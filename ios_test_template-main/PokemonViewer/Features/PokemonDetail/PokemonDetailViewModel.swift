//
//  PokemonDetailViewModel.swift
//  PokemonViewer
//
//  Created by Dmytro Lyshtva on 25/9/25.
//

import Foundation

final class PokemonDetailViewModel {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let imageURL: URL?
    private let favorites: FavoritesStore

    init(id: Int, name: String, height: Int, weight: Int, imageURL: URL?, favorites: FavoritesStore = .shared) {
        self.id = id
        self.name = name
        self.height = height
        self.weight = weight
        self.imageURL = imageURL
        self.favorites = favorites
    }

    var isFavorite: Bool {
        favorites.isFavorite(id: id)
    }

    func toggleFavorite() {
        favorites.toggle(id: id)
    }
}
