//
//  ContentView.swift
//  AnimeApp
//
//  Created by Omar Mendivil on 8/25/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
         
            Tab("Anime", systemImage: "magnifyingglass") {
                AnimeListView()
            }
            
            Tab("AI Buddy", systemImage: "apple.intelligence"){
                AIBuddyChatView()
            }
        }
    }
}

#Preview {
    ContentView()
}
