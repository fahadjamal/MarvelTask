//
//  DraftBillRequest.swift

import Foundation

final class CharactersRequest: APIRequest {
    var body: Data?
    var method: RequestType
    var path: String
    var parameters: [String: String]
    init(offset: Int, limit: Int) {
        self.method = .GET
        self.path = "\(APIConstants.Path.characters)"
        self.parameters = [
            APIConstants.ParamKeys.limit: "\(limit)",
            APIConstants.ParamKeys.offset: "\(offset)"
        ]
    }
}
