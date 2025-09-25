//
//  PokemonListViewModel.swift
//  PokemonViewer
//
//  Created by Dmytro Lyshtva on 25/9/25.
//
import Foundation

final class PokemonListViewModel {
    private let service: PokemonsService
    private let favorites: FavoritesStore

    private(set) var items: [PokemonListCellViewModel] = []
    private var isLoading = false
    private var offset = 0
    private let limit = 20
    private var reachedEnd = false

    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?

    init(service: PokemonsService, favorites: FavoritesStore = .shared) {
        self.service = service
        self.favorites = favorites

        NotificationCenter.default.addObserver(
            forName: FavoritesStore.changed, object: nil, queue: .main
        ) { [weak self] note in
            guard let self else { return }
            if let id = note.object as? Int,
               let idx = self.items.firstIndex(where: { $0.id == id }) {
                self.items[idx].isFavorite = self.favorites.isFavorite(id: id)
                self.onUpdate?()
            } else {
                self.onUpdate?()
            }
        }
    }

    func loadInitial() {
        offset = 0
        reachedEnd = false
        items.removeAll()
        onUpdate?()
        loadNextPage()
    }

    func loadNextPage() {
        guard !isLoading, !reachedEnd else { return }
        isLoading = true

        Task {
            do {
                let pokemons = try await service.fetchPokemons(offset: offset, limit: limit)
                if pokemons.isEmpty { reachedEnd = true }

                let newVMs = pokemons.map {
                    PokemonListCellViewModel(
                        id: $0.id,
                        name: $0.name.capitalized,
                        imageURL: URL(string: $0.imageURLString),
                        height: $0.height,
                        weight: $0.weight,
                        isFavorite: favorites.isFavorite(id: $0.id)
                    )
                }
                offset += limit
                items.append(contentsOf: newVMs)
                await MainActor.run { self.onUpdate?() }
            } catch {
                await MainActor.run {
                    self.onError?("Failed to load Pokémon. Please try again.")
                }
            }
            isLoading = false
        }
    }

    func toggleFavorite(at index: Int) {
        guard items.indices.contains(index) else { return }
        favorites.toggle(id: items[index].id)
    }

    func delete(at index: Int) {
        guard items.indices.contains(index) else { return }
        let item = items[index]
        if favorites.isFavorite(id: item.id) {
            favorites.remove(id: item.id)
        }
        items.remove(at: index)
        onUpdate?()
    }


    func item(at indexPath: IndexPath) -> PokemonListCellViewModel {
        items[indexPath.row]
    }

    var count: Int { items.count }
}

