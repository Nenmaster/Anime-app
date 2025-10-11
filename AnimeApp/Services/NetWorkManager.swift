//
//  NetWorkManager.swift
//  AnimeApp
//
//  Created by Omar Mendivil on 8/27/25.
//

import Foundation

@MainActor
class NetWorkManager: ObservableObject {
    @Published var animeList: [AnimeListResponse] = []
    @Published var animeResponse: AnimeSingleResponse?
    @Published var page = 1
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func getListData (from url: String) async throws -> [AnimeListResponse] {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(AnimeData.self, from: data)
    
        return decoded.data
    }
    
    func loadListData() async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            let newAnime = try await getListData(from: "https://api.jikan.moe/v4/top/anime?page=\(page)")
            animeList.append(contentsOf: newAnime)
            page += 1
        } catch {
            errorMessage = error.localizedDescription
            page += 1
        }
        
        isLoading = false
    }
    
    func getSingleResponse(from url: String) async throws -> AnimeSingleResponse {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(AnimeDetailData.self, from: data)
        
        return decoded.data
    }
    
    func loadSingleResponseData(from id: Int) async {
        do {
            animeResponse = try await getSingleResponse(from: "https://api.jikan.moe/v4/anime/\(id)/full")
        } catch {
            errorMessage = error.localizedDescription
        }
        
    }
    
    func fetchRecommendations(for title: String) async throws -> [AnimeListResponse] {
        let searchQuery = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? title
        let searchURL = "https://api.jikan.moe/v4/anime?q=\(searchQuery)&limit=1"

        let searchResults = try await getListData(from: searchURL)
        guard let first = searchResults.first else {
            throw URLError(.badServerResponse)
        }

        let recURL = "https://api.jikan.moe/v4/anime/\(first.mal_id)/recommendations"
        guard let url = URL(string: recURL) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        struct RecommendationData: Decodable {
            let data: [Recommendation]
            struct Recommendation: Decodable {
                let entry: AnimeListResponse
            }
        }

        let decoded = try JSONDecoder().decode(RecommendationData.self, from: data)
        return decoded.data.map { $0.entry }
    }

    
    func fetchAnime(for title: String) async throws -> AnimeSingleResponse? {
        let query = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let searchURL = "https://api.jikan.moe/v4/anime?q=\(query)&limit=1"
        
        let searchResults = try await getListData(from: searchURL)
        guard let firstResult = searchResults.first else {
            print("⚠️ No anime found for: \(title)")
            return nil
        }

        let fullURL = "https://api.jikan.moe/v4/anime/\(firstResult.mal_id)/full"
        let detailedAnime = try await getSingleResponse(from: fullURL)
        return detailedAnime
    }
    
    func fetchTopAnime(genre: String? = nil, year: Int? = nil) async throws -> [AnimeListResponse] {
            var baseURL = "https://api.jikan.moe/v4/top/anime"
        
            if let genre = genre, !genre.isEmpty {
                let query = genre.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                baseURL = "https://api.jikan.moe/v4/anime?q=\(query)&order_by=score&sort=desc&limit=10"
            }
        
            if let year = year {
                baseURL = "https://api.jikan.moe/v4/seasons/\(year)"
            }

            let list = try await getListData(from: baseURL)
            return list
        }
}
