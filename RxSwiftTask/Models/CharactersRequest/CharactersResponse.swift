//
//  DraftBillResponse.swift

import Foundation

// MARK: - CharactersListResponse
struct CharactersListResponse: Codable {
    var code: Int?
    var data: CharactersResponse?
}

// MARK: - DataClass
struct CharactersResponse: Codable {
    var offset, limit, total, count: Int?
    var results: [Character]?
}

// MARK: - Result
struct Character: Codable {
    var id: Int?
    var name, description: String?
    var thumbnail: Thumbnail?
    var urls: [URLElement]?
}

// MARK: - URLElement
struct URLElement: Codable {
    var type: String?
    var url: String?
}

// MARK: - Thumbnail
struct Thumbnail: Codable {
    var path: String?
    var thumbnailExtension: String?

    enum CodingKeys: String, CodingKey {
        case path
        case thumbnailExtension = "extension"
    }
    func getImageUrl() -> String? {
        (self.path ?? "") +
            "." +
            (self.thumbnailExtension ?? "")
    }
}
