//
//  APIRequest.swift

import Foundation

public enum RequestType: String {
    case GET, POST, PUT, DELETE
}

protocol APIRequest {
    var body: Data? { get }
    var method: RequestType { get }
    var path: String { get }
    var parameters: [String: String] { get }
}

extension APIRequest {
    func request(with baseURL: URL) -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false) else {
                fatalError("Unable to create URL components")
        }
        components.queryItems = parameters.map {
            URLQueryItem(
                name: String($0),
                value: String($1)
                    .addingPercentEncoding(
                        withAllowedCharacters: .urlHostAllowed
                    )
            )
        }
        components.queryItems?.append(contentsOf: defaultQueryItems())
        guard let url = components.url else {
            fatalError("Could not get url")
        }
        var request = URLRequest.init(url: url)
        request.httpMethod = method.rawValue
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        if let body = body {
            request.setValue(
                "\(body.count)",
                forHTTPHeaderField: "Content-Length"
            )
            request.httpBody = body
        }

        return request
    }
}

extension APIRequest {
    func defaultQueryItems() -> [URLQueryItem] {
        let currentTimeStamp = "\(Date().timeIntervalSince1970)"
        let params = [
            APIConstants.ParamKeys.apikey: APIConstants.Keys.publicKey,
            APIConstants.ParamKeys.hash: "\(currentTimeStamp)\(APIConstants.Keys.privateKey)\(APIConstants.Keys.publicKey)".md5(),
            APIConstants.ParamKeys.ts: currentTimeStamp
        ]
        return params.map {
            URLQueryItem(
                name: String($0),
                value: String($1)
                    .addingPercentEncoding(
                        withAllowedCharacters: .urlHostAllowed
                    )
            )
        }
    }
}
