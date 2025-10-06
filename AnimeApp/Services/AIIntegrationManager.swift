//
//  AIIntegrationManager.swift
//  AnimeApp
//
//  Created by Omar Mendivil on 10/5/25.
//

import Foundation

@MainActor
class AIIntegrationManager {
    static let shared = AIIntegrationManager()

    func extractTitle(from question: String) async throws -> (hasTitle: Bool, title: String?) {
        let prompt = """
        Identify if the following text mentions the name of ANY anime title, even if it’s used for comparison
        Respond **only** in valid JSON:
        {"hasTitle": true/false, "title": "<anime title or null>"}
        Text: "\(question)"
        """

        let json = try await AINetworkManager.shared.ask(prompt)

        struct ExtractionResponse: Codable {
            let hasTitle: Bool
            let title: String?
        }
        
        let cleaned = json
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        print("🧹 Cleaned JSON for decoding:\n\(cleaned)")

        let data = Data(cleaned.utf8)
        let decoded = try JSONDecoder().decode(ExtractionResponse.self, from: data)
        return (decoded.hasTitle, decoded.title)
    }

    func handleUserQuestion(_ question: String) async throws -> String {
       print("🧠 User asked: \(question)")
       
       let extracted = try await extractTitle(from: question)
       var anime: AnimeSingleResponse? = nil

       if extracted.hasTitle, let title = extracted.title {
           print("📡 Detected anime title: \(title). Fetching from Jikan...")
           anime = try? await NetWorkManager().fetchAnime(for: title)
           
           if let anime = anime {
               print("✅ Jikan Data Received → \(anime.title_english ?? "Unknown") | Score: \(anime.score ?? 0) | Episodes: \(anime.episodes ?? 0)")
           } else {
               print("⚠️ No Jikan data found for \(title)")
           }
       } else {
           print("🚫 No title detected in user question. Skipping Jikan fetch.")
       }

       let prompt = buildPrompt(question: question, anime: anime)
       print("📝 Final Prompt Sent to GPT:\n\(prompt)")

       let answer = try await AINetworkManager.shared.ask(prompt)
       print("💬 GPT Response:\n\(answer)")
       return answer
   }

    private func buildPrompt(question: String, anime: AnimeSingleResponse?) -> String {
        var jikanSection = "No anime data found."
        if let anime = anime {
            jikanSection = """
            Title: \(anime.title_english ?? "Unknown")
            Score: \(anime.score ?? 0)
            Episodes: \(anime.episodes ?? 0)
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
