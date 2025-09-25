//
//  FavoritesStore.swift
//  PokemonViewer
//
//  Created by Dmytro Lyshtva on 25/9/25.
//

import Foundation

final class FavoritesStore {
    static let shared = FavoritesStore()
    private var storage = Set<Int>()
    private let center = NotificationCenter.default
    static let changed = Notification.Name("FavoritesStore.changed")

    var count: Int { storage.count }

    func isFavorite(id: Int) -> Bool { storage.contains(id) }

    func add(id: Int) {
        let inserted = storage.insert(id).inserted
        if inserted { center.post(name: FavoritesStore.changed, object: id) }
    }

    func remove(id: Int) {
        if storage.remove(id) != nil {
            center.post(name: FavoritesStore.changed, object: id)
        }
    }

    func toggle(id: Int) {
        isFavorite(id: id) ? remove(id: id) : add(id: id)
    }
}


