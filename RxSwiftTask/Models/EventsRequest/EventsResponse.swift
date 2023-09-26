//
//  DraftBillResponse.swift

import Foundation

// MARK: - ComicListResponse
struct EventsListResponse: Codable {
    var code: Int?
    var data: EventsResponse?
}

// MARK: - DataClass
struct EventsResponse: Codable {
    var offset, limit, total, count: Int?
    var results: [Event]?
}

// MARK: - Result
struct Event: Codable {
    var id: Int?
    var name, description: String?
    var thumbnail: Thumbnail?
    var resourceURI: String?
}
