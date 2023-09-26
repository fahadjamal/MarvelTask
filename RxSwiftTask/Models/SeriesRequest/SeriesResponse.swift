//
//  DraftBillResponse.swift

import Foundation

// MARK: - CharactersListResponse
struct SeriesListResponse: Codable {
    var code: Int?
    var data: SeriesResponse?
}

// MARK: - DataClass
struct SeriesResponse: Codable {
    var offset, limit, total, count: Int?
    var results: [Series]?
}

// MARK: - Result
struct Series: Codable {
    var id: Int?
    var name, description: String?
    var thumbnail: Thumbnail?
    var resourceURI: String?
}
