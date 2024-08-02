//
//  UnsplashPhotosViewModel.swift
//  UnsplashExplorerTable
//
//  Created by tanya on 07/02/2024.
//

import Foundation

class UnsplashPhotosViewModel: ObservableObject {
    @Published var photos = [Photo]()
    
    private let service: PhotosServiceProtocol
    private var page = 1
    
    var nextPage: Int {
        page + 1
    }
    
    init(service: PhotosServiceProtocol) {
        self.service = service
    }
    func clearPhotos() {
        photos.removeAll()
    }
    
    @MainActor
    func loadPhotos(search: String, page: Int) {
        guard !search.isEmpty else { return }
        self.page = page
        Task {
            do {
                let photos = try await service.loadPhotos(search: search, page: page)
                self.photos.append(contentsOf: photos)
            } catch {
                //handle error
            }
        }
    }
}

protocol PhotosServiceProtocol {
    func loadPhotos(search: String, page: Int) async throws -> [Photo]
}

struct PhotosService: PhotosServiceProtocol {
    private let baseUrl = "https://api.unsplash.com"
    private let clientid = "c99a7e7599297260b46b7c9cf36727badeb1d37b1f24aa9ef5d844e3fbed76fe"
    
    func loadPhotos(search: String, page: Int) async throws -> [Photo] {
        let url = try buildURL(search: search, page: page)

        let (data, response) = try await URLSession.shared.data(from: url)
        try validateResponse(response)

        return try JSONDecoder().decode(UnsplashResults.self, from: data).photos
    }

    private func buildURL(search: String, page: Int) throws -> URL {
        guard var urlComponents = URLComponents(string: baseUrl + "/search/photos") else {
            throw URLError(.badURL)
        }

        var queryItems: [URLQueryItem] = []
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        queryItems.append(URLQueryItem(name: "client_id", value: self.clientid))
        queryItems.append(URLQueryItem(name: "query", value: search))

        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else { throw URLError(.badURL) }
        return url
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse) // Or a custom error type
        }
    }
}

struct UnsplashResults: Decodable {
    let total, totalPages: Int
    let photos: [Photo]

    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case photos = "results"
    }
}

struct Photo: Decodable, Identifiable, Hashable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        true
    }

    let id: String
    let description: String?
    let urls: Urls
    let links: ResultLinks
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ResultLinks: Decodable {
    let download: String
}

struct Urls: Decodable {
    let small: String
    var url: URL? {
        URL(string: small)
    }
}
