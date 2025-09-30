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
            Tab("Anime", systemImage: "tv"){
                
            }
            
            Tab("Search", systemImage: "magnifyingglass") {
                AnimeListView()
            }
            
            Tab("Profile", systemImage: "person.fill"){
                
            }
        }
    }
}

#Preview {
    ContentView()
}
