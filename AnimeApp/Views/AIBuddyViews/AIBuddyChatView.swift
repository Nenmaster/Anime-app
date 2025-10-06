//
//  AIBuddyChatView.swift
//  AnimeApp
//
//  Created by Omar Mendivil on 10/5/25.
//

import SwiftUI

struct AIBuddyChatView: View {
    @State private var question = ""
    @State private var isLoading = false
    @State private var responseText = ""

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    if responseText.isEmpty {
                        VStack(spacing: 8) {
                            Text("Ask your Anime AI Buddy")
                                .font(.title2)
                                .bold()
                            Text("Example: 'What are the best action anime this year?'")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(responseText)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                }

                HStack {
                    TextField("Ask about anime...", text: $question)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 8)

                    Button {
                        Task {
                            guard !question.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            isLoading = true
                            do {
                                responseText = try await AIIntegrationManager.shared.handleUserQuestion(question)
                            } catch {
                                responseText = "⚠️ Error: \(error.localizedDescription)"
                            }
                            isLoading = false
                            question = ""
                        }
                    } label: {
                        Image(systemName: isLoading ? "hourglass" : "paperplane.fill")
                            .font(.system(size: 20))
                    }
                    .padding(.trailing, 10)
                    .disabled(isLoading)
                }
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
            .navigationTitle("AI Buddy")
        }
    }
}

#Preview {
    AIBuddyChatView()
}
