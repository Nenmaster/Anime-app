//
//  AINetworkManager.swift
//  AnimeApp
//
//  Created by Omar Mendivil on 10/5/25.
//

import Foundation

struct AIResponse: Codable {
    let choices: [Choice]
    struct Choice: Codable {
        let message: Message
        struct Message: Codable {
            let role: String
            let content: String
        }
    }
}

@MainActor
class AINetworkManager: ObservableObject {
    @Published var responseText = ""

    private var apiKey: String {
        guard let key = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String else {
            fatalError("Missing OpenAI API key")
        }
        return key
    }

    func askQuestion(_ question: String) async {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }

        let messages: [[String: String]] = [
            ["role": "system", "content": "You are an expert in anime and manga. Respond clearly and concisely."],
            ["role": "user", "content": question]
        ]

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "max_tokens": 300
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let jsonString = String(data: data, encoding: .utf8) {
                      print("🧠 Raw JSON Response:\n\(jsonString)")
                  }
            let decoded = try JSONDecoder().decode(AIResponse.self, from: data)
            if let content = decoded.choices.first?.message.content {
                responseText = content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            responseText = "⚠️ Error: \(error.localizedDescription)"
        }
    }
}
