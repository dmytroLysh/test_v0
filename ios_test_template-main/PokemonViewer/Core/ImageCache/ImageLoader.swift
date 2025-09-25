//
//  ImageLoader.swift
//  PokemonViewer
//
//  Created by Dmytro Lyshtva on 25/9/25.
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()
    private let cache = ImageCache.shared
    private var inflight: [URL: [(UIImage?) -> Void]] = [:]
    private let session = URLSession(configuration: .default)

    func load(_ url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cached = cache.image(for: url) {
            DispatchQueue.main.async { completion(cached) }
            return
        }
        inflight[url, default: []].append(completion)
        guard inflight[url]?.count == 1 else { return }

        session.dataTask(with: url) { [weak self] data, _, _ in
            var image: UIImage? = nil
            if let data, let img = UIImage(data: data) {
                image = img
                self?.cache.insert(img, for: url)
            }
            let callbacks = self?.inflight[url] ?? []
            self?.inflight[url] = nil
            DispatchQueue.main.async { callbacks.forEach { $0(image) } }
        }.resume()
    }
}
