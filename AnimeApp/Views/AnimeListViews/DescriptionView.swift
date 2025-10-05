import SwiftUI

struct DescriptionView: View {
    let anime_id: Int
    @StateObject var manager = NetWorkManager()
    @State private var showFullSynopsis = false
    @State private var showFullWheretoWatch = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                if let jpgURL = URL(string: manager.animeResponse?.images.jpg.large_image_url ?? "") {
                    AsyncImage(url: jpgURL) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 250)
                    .padding(.horizontal)
                }
                
                if let url = URL(string: manager.animeResponse?.trailer.url ?? "") {
                    HStack {
                        Spacer()
                        Link(destination: url) {
                            Label("Watch Trailer", systemImage: "play.circle.fill")
                                .font(.headline)
                        }
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(manager.animeResponse?.synopsis ?? "No synopsis")
                        .font(.body)
                        .lineLimit(showFullSynopsis ? nil : 5) // trims by default
                        .multilineTextAlignment(.leading)
                    
                    Button(showFullSynopsis ? "Show Less" : "Read More") {
                        withAnimation {
                            showFullSynopsis.toggle()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)
                
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Where to Watch")
                        .font(.headline)
                    
                    if let stream = manager.animeResponse?.streaming {
                        let limitedStream = showFullWheretoWatch ? stream : Array(stream.prefix(4))
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(limitedStream, id: \.name) { service in
                                HStack(alignment: .center, spacing: 6) {
                                    Image(systemName: "tv.fill")
                                        .frame(width: 20)
                                    Text(service.name)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        if stream.count > 4 {
                            Button(showFullWheretoWatch ? "Show Less" : "Show More") {
                                withAnimation {
                                    showFullWheretoWatch.toggle()
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .task {
            await manager.loadSingleResponseData(from: anime_id)
        }
    }
}

#Preview {
    DescriptionView(anime_id: MockResponse.Singleresponse.id)
}
