//
//  AnimeData.swift
//  AnimeApp
//
//  Created by Omar Mendivil on 8/25/25.
//

import Foundation

struct AnimeData : Decodable {
    let data: [AnimeListResponse]
    let pagination: Pages
}

struct AnimeDetailData: Decodable {
    let data: AnimeSingleResponse
}

struct AnimeListResponse: Decodable, Identifiable {
    let mal_id: Int
    var id: Int { mal_id }
    let url: String
    let images: imageContainer
    let trailer: Trailer
    let title_english: String?
    let episodes: Int?
    let status: String?
    let duration: String?
    let rating: String?
    let score: Double?
    let scored_by: Int?
    let rank: Int?
    let favorites: Int?
    let synopsis: String?
}

struct AnimeSingleResponse: Decodable, Identifiable {
    let mal_id: Int
    var id: Int { mal_id }
    let url: String
    let images: imageContainer
    let trailer: Trailer
    let title_english: String?
    let episodes: Int?
    let status: String?
    let duration: String?
    let rating: String?
    let score: Double?
    let scored_by: Int?
    let rank: Int?
    let favorites: Int?
    let synopsis: String?
    let streaming: [StreamingServices]?
}

struct Pages: Decodable {
    let last_visible_page: Int
    let has_next_page: Bool
    let current_page: Int
    let items: PageInfo
}

struct PageInfo : Decodable {
    let count: Int
    let total: Int
    let per_page: Int
}

struct imageContainer: Decodable {
    let jpg: JPG
}

struct JPG: Decodable {
    let image_url: String
    let small_image_url: String
    let large_image_url: String
}

struct Trailer: Decodable {
    let url: String?
}

struct StreamingServices: Decodable {
    let name: String
    let url: String
}


struct MockResponse {
    static let responseList = AnimeListResponse(
        mal_id: 1,
        url: "Test",
        images: imageContainer(jpg: JPG(image_url: "https://storage.googleapis.com/msgsndr/kFACnJzo8ukWPxW6nBtT/media/68c301e442eb1a349cf01442.jpeg", small_image_url: "https://storage.googleapis.com/msgsndr/kFACnJzo8ukWPxW6nBtT/media/68c301e442eb1a349cf01442.jpeg", large_image_url: "https://storage.googleapis.com/msgsndr/kFACnJzo8ukWPxW6nBtT/media/68c301e442eb1a349cf01442.jpeg")),
        trailer: Trailer(url: "test"),
        title_english: "test",
        episodes: 600,
        status: "airing",
        duration: "20 min",
        rating: "5 star",
        score: 10.0,
        scored_by: 500,
        rank: 25,
        favorites: 100,
        synopsis: "Naruto: Shippuden continues the story of Naruto Uzumaki two and a half years after the original series, following him as he returns from training with Jiraiya to become the leader of the Hidden Leaf Village, the Hokage. The series focuses on his growth into a powerful ninja, his ongoing rivalry with Sasuke Uchiha, and his efforts to combat the nefarious Akatsuki organization, which seeks to control the world. The storyline culminates in the Fourth Shinobi World War, a massive conflict against Akatsuki's forces, as Naruto must unite the ninja world to save it from total destruction.",
    )
    
    static let Singleresponse = AnimeSingleResponse(
        mal_id: 1,
        url: "Test",
        images: imageContainer(jpg: JPG(image_url: "https://storage.googleapis.com/msgsndr/kFACnJzo8ukWPxW6nBtT/media/68c301e442eb1a349cf01442.jpeg", small_image_url: "https://storage.googleapis.com/msgsndr/kFACnJzo8ukWPxW6nBtT/media/68c301e442eb1a349cf01442.jpeg", large_image_url: "https://storage.googleapis.com/msgsndr/kFACnJzo8ukWPxW6nBtT/media/68c301e442eb1a349cf01442.jpeg")),
        trailer: Trailer(url: "test"),
        title_english: "test",
        episodes: 600,
        status: "airing",
        duration: "20 min",
        rating: "5 star",
        score: 10.0,
        scored_by: 500,
        rank: 25,
        favorites: 100,
        synopsis: "Naruto: Shippuden continues the story of Naruto Uzumaki two and a half years after the original series, following him as he returns from training with Jiraiya to become the leader of the Hidden Leaf Village, the Hokage. The series focuses on his growth into a powerful ninja, his ongoing rivalry with Sasuke Uchiha, and his efforts to combat the nefarious Akatsuki organization, which seeks to control the world. The storyline culminates in the Fourth Shinobi World War, a massive conflict against Akatsuki's forces, as Naruto must unite the ninja world to save it from total destruction.",
        streaming: [StreamingServices(name: "Netflix", url: "https://www.netflix.com/"),
                    StreamingServices(name: "Hulu", url: "https://www.hulu.com/")
                   ]
    )
}

