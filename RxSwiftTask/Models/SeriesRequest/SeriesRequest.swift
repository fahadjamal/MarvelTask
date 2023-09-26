//
//  DraftBillRequest.swift

import Foundation

final class SeriesRequest: APIRequest {
    var body: Data?
    var method: RequestType
    var path: String
    var parameters: [String: String]
    init(characterId: Int) {
        self.method = .GET
        self.path = "\(APIConstants.Path.characters)" +
            "/\(characterId)" +
            "\(APIConstants.Path.series)"
        self.parameters = [:]
    }
}
