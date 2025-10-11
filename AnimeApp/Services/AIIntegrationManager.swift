//
//  AIIntegrationManager.swift
//  AnimeApp
//
//  Created by Omar Mendivil on 10/7/25.
//

import Foundation

@MainActor
final class AIIntegrationManager {
    static let shared = AIIntegrationManager()

    func handleUserQuestion(_ question: String) async throws -> String {
        print("🧠 User asked: \(question)")

        let extracted = try await extractTitleAndUsage(from: question)

        let intent = try await detectIntent(for: question)
        print("🎯 Intent: \(intent.rawValue) | 🎬 Title: \(extracted.title ?? "none") | Usage: \(extracted.usage.rawValue)")

        switch intent {
        case .summary:
            guard extracted.hasTitle, let title = extracted.title else {
                return "Please mention which anime you want summarized."
            }
            return try await handleSummary(for: title)

        case .recommendation:
            if extracted.hasTitle && extracted.usage == .reference {
                return try await handleRecommendation(question, basedOn: extracted.title)
            } else {
                return try await handleRecommendation(question)
            }

        case .comparison:
            return try await handleComparison(question)

        case .characterInfo:
            guard extracted.hasTitle, let title = extracted.title else {
                return "Please mention which anime or character you’re referring to."
            }
            return try await handleCharacter(question, for: title)

        case .studioInfo:
            guard extracted.hasTitle, let title = extracted.title else {
                return "Please mention which anime you’re asking about."
            }
            return try await handleStudio(for: title)

        case .releaseInfo:
            return try await handleReleaseInfo(question)

        case .genreList:
            return try await handleGenreList(question)

        case .creative:
            return try await AINetworkManager.shared.ask(question)

        case .unknown:
            return "I’m not sure how to answer that yet — try rephrasing!"
        }
    }

    enum AIIntent: String, Codable {
        case summary, recommendation, comparison, characterInfo, studioInfo, releaseInfo, genreList, creative, unknown
    }

    private func detectIntent(for question: String) async throws -> AIIntent {
        let prompt = """
        Identify the user's intent for this anime-related question.
        Choose one of:
        ["summary", "recommendation", "comparison", "characterInfo", "studioInfo", "releaseInfo", "genreList", "creative", "unknown"]

        Respond ONLY in valid JSON:
        {"intent": "<value>"}

        Question: "\(question)"
        """

        let json = try await AINetworkManager.shared.ask(prompt)
        struct IntentResponse: Decodable { let intent: AIIntent }
        let cleaned = json
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return try JSONDecoder().decode(IntentResponse.self, from: Data(cleaned.utf8)).intent
    }

    private enum TitleUsage: String, Codable {
        case subject, reference, compare, none
    }

    private func extractTitleAndUsage(from question: String) async throws -> (hasTitle: Bool, title: String?, usage: TitleUsage) {
        let prompt = """
        Identify if the following text mentions one or more anime titles,
        and determine how they are used:
        - "subject" if the user wants info about that anime
        - "reference" if it’s used for recommendation (e.g., "like Naruto")
        - "compare" if multiple titles are being compared
        - "none" if no title mentioned

        Respond ONLY in valid JSON:
        {"hasTitle": true/false, "title": "<anime title or null>", "usage": "<subject/reference/compare/none>"}

        Text: "\(question)"
        """

        let json = try await AINetworkManager.shared.ask(prompt)
        struct ExtractionResponse: Decodable {
            let hasTitle: Bool
            let title: String?
            let usage: TitleUsage
        }

        let cleaned = json
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let decoded = try JSONDecoder().decode(ExtractionResponse.self, from: Data(cleaned.utf8))
        return (decoded.hasTitle, decoded.title, decoded.usage)
    }


    private func handleRecommendation(_ question: String, basedOn title: String? = nil) async throws -> String {
        if let title = title {
            let recs = try await NetWorkManager().fetchRecommendations(for: title)
            let names = recs.prefix(5).map { $0.title_english ?? "Unknown" }.joined(separator: ", ")
            return "Since you like \(title), you might also enjoy: \(names)."
        }

        let genre = try await extractGenre(from: question)
        let year = try await extractYear(from: question)
        let list = try await NetWorkManager().fetchTopAnime(genre: genre, year: year)
        let top = list.prefix(5).map { $0.title_english ?? "Unknown" }.joined(separator: ", ")
        return "Here are some top \(genre) anime\(year != nil ? " from \(year!)" : ""): \(top)"
    }

    private func handleSummary(for title: String) async throws -> String {
        guard let anime = try? await NetWorkManager().fetchAnime(for: title) else {
            return "I couldn’t find information about \(title)."
        }

        let finalPrompt = buildPrompt(
            question: "Summarize \(title)",
            intent: .summary,
            titles: [title],
            animeData: [anime]
        )

        return try await AINetworkManager.shared.ask(finalPrompt)
    }


    private func handleComparison(_ question: String) async throws -> String {
        let titles = try await extractMultipleTitles(from: question)
        guard titles.count == 2 else { return "Please mention two anime to compare." }

        let a = try? await NetWorkManager().fetchAnime(for: titles[0])
        let b = try? await NetWorkManager().fetchAnime(for: titles[1])
        guard let first = a, let second = b else {
            return "Couldn’t fetch enough data for comparison."
        }

        let prompt = buildPrompt(
            question: question,
            intent: .comparison,
            titles: titles,
            animeData: [first, second]
        )

        return try await AINetworkManager.shared.ask(prompt)
    }


    private func handleCharacter(_ question: String, for title: String) async throws -> String {
        return "You asked about characters in \(title). (Character info integration coming soon!)"
    }

    private func handleStudio(for title: String) async throws -> String {
        guard let anime = try? await NetWorkManager().fetchAnime(for: title),
              let studios = anime.studios, !studios.isEmpty else {
            return "Couldn’t find studio information for \(title)."
        }

        let names = studios.map { $0.name }.joined(separator: ", ")
        return "\(title) was produced by \(names)."
    }

    private func handleReleaseInfo(_ question: String) async throws -> String {
        return "I’ll soon be able to tell you upcoming or current season info."
    }

    private func handleGenreList(_ question: String) async throws -> String {
        let genre = try await extractGenre(from: question)
        let list = try await NetWorkManager().fetchTopAnime(genre: genre)
        let top = list.prefix(5).map { $0.title_english ?? "Unknown" }.joined(separator: ", ")
        return "Top \(genre) anime: \(top)"
    }


    private func extractGenre(from question: String) async throws -> String {
        let prompt = """
        Identify the genre mentioned in this question (e.g., comedy, romance, action, isekai).
        Respond only in valid JSON: {"genre": "<value or null>"}
        Question: "\(question)"
        """

        let json = try await AINetworkManager.shared.ask(prompt)
        struct GenreResponse: Decodable { let genre: String? }
        let cleaned = json
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return try JSONDecoder().decode(GenreResponse.self, from: Data(cleaned.utf8)).genre ?? "general"
    }

    private func extractYear(from question: String) async throws -> Int? {
        let prompt = """
        Identify the year mentioned in this question if any.
        Respond only in JSON: {"year": <number or null>}
        Question: "\(question)"
        """

        let json = try await AINetworkManager.shared.ask(prompt)
        struct YearResponse: Decodable { let year: Int? }
        let cleaned = json
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return try JSONDecoder().decode(YearResponse.self, from: Data(cleaned.utf8)).year
    }

    private func extractMultipleTitles(from question: String) async throws -> [String] {
        let prompt = """
        Extract all anime titles mentioned in this text (if any).
        Respond only in valid JSON:
        {"titles": ["Title1", "Title2", ...]}
        Text: "\(question)"
        """

        let json = try await AINetworkManager.shared.ask(prompt)
        struct TitlesResponse: Decodable { let titles: [String] }
        let cleaned = json
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return try JSONDecoder().decode(TitlesResponse.self, from: Data(cleaned.utf8)).titles
    }
    private func buildPrompt(
        question: String,
        intent: AIIntent?,
        titles: [String]? = nil,
        animeData: [AnimeSingleResponse]? = nil,
        genre: String? = nil,
        year: Int? = nil
    ) -> String {

        var prompt = "User asked: \"\(question)\"\n"

        if let intent = intent {
            prompt += "Detected intent: \(intent.rawValue.capitalized)\n"
        }

        if let titles = titles, !titles.isEmpty {
            prompt += "Detected anime titles: \(titles.joined(separator: ", "))\n"
        }

        if let genre = genre {
            prompt += "Genre focus: \(genre.capitalized)\n"
        }
        if let year = year {
            prompt += "Year filter: \(year)\n"
        }

        if let animeData = animeData, !animeData.isEmpty {
            prompt += "\nHere’s the fetched data from Jikan:\n"
            for anime in animeData {
                prompt += """
                • Title: \(anime.title_english ?? "Unknown")
                  Score: \(anime.score ?? 0)
                  Episodes: \(anime.episodes ?? 0)
                  Synopsis: \(anime.synopsis ?? "N/A")
                """
                prompt += "\n"
            }
        } else {
            prompt += "\n(No specific anime data available)\n"
        }

        var instruction = ""
        switch intent {
        case .summary:
            instruction = "Summarize the anime concisely using the data above."
        case .comparison:
            instruction = "Compare the provided anime, focusing on story, popularity, and tone."
        case .recommendation:
            instruction = "Recommend similar anime based on the data and genre/year provided."
        case .characterInfo:
            instruction = "Discuss notable characters or traits from the anime above."
        case .studioInfo:
            instruction = "Explain which studio produced the anime and describe their general style."
        case .releaseInfo:
            instruction = "Provide release or airing information using the year and Jikan data."
        case .genreList:
            instruction = "List top anime for the detected genre and year."
        default:
            instruction = "Answer conversationally and accurately using the data above."
        }

        prompt += "\n\nInstruction:\n\(instruction)"
        return prompt
    }

}
