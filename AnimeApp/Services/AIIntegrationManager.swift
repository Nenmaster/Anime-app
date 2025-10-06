//
//  AIIntegrationManager.swift
//  AnimeApp
//
//  Created by Omar Mendivil on 10/5/25.
//

import Foundation

import Foundation

@MainActor
class AIIntegrationManager {
    static let shared = AIIntegrationManager()

    func extractTitle(from question: String) async throws -> (hasTitle: Bool, title: String?) {
        let prompt = """
        Determine if this text mentions a specific anime title.
        Respond in JSON:
        {"hasTitle": true/false, "title": "<anime title or null>"}
        Text: "\(question)"
        """

        let json = try await AINetworkManager.shared.ask(prompt)

        struct ExtractionResponse: Codable {
            let hasTitle: Bool
            let title: String?
        }

        let data = Data(json.utf8)
        return try JSONDecoder().decode(ExtractionResponse.self, from: data)
    }

    func handleUserQuestion(_ question: String) async throws -> String {
        let extracted = try await extractTitle(from: question)
        var anime: Anime? = nil

        if extracted.hasTitle, let title = extracted.title {
            anime = try? await NetworkManager.shared.fetchAnime(for: title)
        }

        let prompt = buildPrompt(question: question, anime: anime)
        return try await AINetworkManager.shared.ask(prompt)
    }

    private func buildPrompt(question: String, anime: Anime?) -> String {
        var jikanSection = "No anime data found."
        if let anime = anime {
            jikanSection = """
            Title: \(anime.title)
            Studio: \(anime.studios?.first?.name ?? "Unknown")
            Score: \(anime.score ?? 0)
            Synopsis: \(anime.synopsis ?? "N/A")
            """
        }

        return """
        User asked: "\(question)"
        Here’s what we know:
        \(jikanSection)

        Answer conversationally and accurately using the data above.
        """
    }
}

