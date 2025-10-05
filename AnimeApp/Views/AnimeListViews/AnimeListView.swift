//
//  AnimeListView.swift
//  AnimeApp
//
//  Created by Omar Mendivil on 9/1/25.
//

import SwiftUI

struct AnimeListView: View {
    @StateObject var manager = NetWorkManager()
    
    var body: some View {
        NavigationView {
            List(manager.animeList) { anime in
                NavigationLink(destination: DescriptionView(anime_id: anime.id)) {
                    AnimeListCellView(anime: anime)
                }
                .onAppear {
                    if anime.id == manager.animeList.last?.id {
                        Task { await manager.loadListData() }
                    }
                }
            }
            .navigationTitle(Text("Anime List"))
            .task {
                await manager.loadListData()
            }
        }
    }
}

#Preview {
    AnimeListView()
}

