//
//  DraftBillResponse.swift

import Foundation

// MARK: - ComicListResponse
struct ComicListResponse: Codable {
    var code: Int?
    var data: ComicsResponse?
}

// MARK: - DataClass
struct ComicsResponse: Codable {
    var offset, limit, total, count: Int?
    var results: [Comic]?
}

// MARK: - Result
struct Comic: Codable {
    var id: Int?
    var name, description: String?
    var thumbnail: Thumbnail?
    var resourceURI: String?
}
