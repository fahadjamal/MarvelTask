//
//  DraftBillResponse.swift

import Foundation

// MARK: - CharactersListResponse
struct StoriesListResponse: Codable {
    var code: Int?
    var data: StoriesResponse?
}

// MARK: - DataClass
struct StoriesResponse: Codable {
    var offset, limit, total, count: Int?
    var results: [Story]?
}

// MARK: - Result
struct Story: Codable {
    var id: Int?
    var name, description: String?
    var thumbnail: Thumbnail?
    var resourceURI: String?
}
