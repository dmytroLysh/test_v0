//
//  ListCoordinator.swift
//  PokemonViewer
//
//  Created by Dmytro Lyshtva on 25/9/25.
//

import UIKit

protocol ListCoordinating: AnyObject {
    func start() -> UIViewController
}

final class ListCoordinator: ListCoordinating {
    private let service: PokemonsService
    private let favorites: FavoritesStore
    private let imageLoader: ImageLoader

    init(
        service: PokemonsService = PokemonsServiceImpl(),
        favorites: FavoritesStore = .shared,
        imageLoader: ImageLoader = .shared
    ) {
        self.service = service
        self.favorites = favorites
        self.imageLoader = imageLoader
    }

    func start() -> UIViewController {
        let vm = PokemonListViewModel(service: service, favorites: favorites)
        let vc = PokemonListViewController(viewModel: vm, imageLoader: imageLoader)

        let nav = UINavigationController(rootViewController: vc)
        return nav
    }
}
