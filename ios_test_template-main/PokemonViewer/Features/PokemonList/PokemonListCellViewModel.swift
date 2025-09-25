//
//  PokemonListCellViewModel.swift
//  PokemonViewer
//
//  Created by Dmytro Lyshtva on 25/9/25.
//

import Foundation

struct PokemonListCellViewModel: Hashable {
    let id: Int
    let name: String
    let imageURL: URL?
    let height: Int
    let weight: Int
    var isFavorite: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PokemonListCellViewModel, rhs: PokemonListCellViewModel) -> Bool {
        lhs.id == rhs.id
    }
}


