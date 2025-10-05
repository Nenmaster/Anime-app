//
//  AnimeListView.swift
//  AnimeApp
//
//  Created by Omar Mendivil on 8/28/25.
//

import SwiftUI

struct AnimeListCellView: View {
    let anime: AnimeListResponse
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            if let jpgUrl = URL(string: anime.images.jpg.large_image_url) {
                AsyncImage(url: jpgUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 100)
            }
            VStack(alignment: .leading) {
                    Text(anime.title_english ?? "No Title")
                    Text(anime.status ?? "No Status")
                if let score = anime.score {
                    Text("Score: \(score)")
                }
                if let rank = anime.rank {
                    Text("Rank: \(rank)")
                }
            }
        }
    }
}


