//
//  DescriptionView.swift
//  AnimeApp
//
//  Created by Omar Mendivil on 9/11/25.
//

import SwiftUI

struct DescriptionView: View {
    let anime_id: Int
    @StateObject var manager = NetWorkManager()
    
    var body: some View {
        VStack{
            if let jpgURL = URL(string: manager.animeResponse?.images.jpg.large_image_url ?? "No image") {
                AsyncImage(url: jpgURL) { image in
                    image
                        .resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 300)
            }
            HStack{
                if let url = URL(string: manager.animeResponse?.trailer.url ?? "no trailer") {
                    Link(destination: url) {
                      Image(systemName: "play.square.fill")
                        .font(.system(size: 30))  
                    }
                } else {
                    Text("bad url")
                }
            }
            .frame(height: 30)
            VStack{
                Text(manager.animeResponse?.synopsis ?? "No synopsis")
                    .font(Font.system(size: 12))
            }
            .padding()
            VStack(alignment: .leading) {
                Text("Where to Watch")
                    .font(.headline)
                
                if let stream = manager.animeResponse?.streaming {
                   ForEach(stream, id: \.name) { service in
                    Label(service.name, systemImage: "tv.fill")
                   }
                }
            }
        }
        .task{
            await manager.loadSingleResponseData(from: anime_id)
        }
    }
}

#Preview {
    DescriptionView(anime_id: MockResponse.Singleresponse.id)
}
