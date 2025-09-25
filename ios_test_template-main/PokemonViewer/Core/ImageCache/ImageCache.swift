//
//  ImageCache.swift
//  PokemonViewer
//
//  Created by Dmytro Lyshtva on 25/9/25.
//

import UIKit

final class ImageCache {
    static let shared = ImageCache(maxItems: 20)
    private let maxItems: Int
    private var dict: [URL: UIImage] = [:]
    private var order: [URL] = []

    init(maxItems: Int) { self.maxItems = maxItems }

    func image(for url: URL) -> UIImage? {
        guard let img = dict[url] else { return nil }
        // move to end (most recent)
        if let i = order.firstIndex(of: url) { order.remove(at: i) }
        order.append(url)
        return img
    }

    func insert(_ image: UIImage, for url: URL) {
        dict[url] = image
        if let i = order.firstIndex(of: url) { order.remove(at: i) }
        order.append(url)
        if order.count > maxItems, let evict = order.first {
            order.removeFirst()
            dict.removeValue(forKey: evict)
        }
    }
}

