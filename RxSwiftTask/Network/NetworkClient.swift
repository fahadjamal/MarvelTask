//
//  NetworkClient.swift

import Foundation
import RxSwift

enum APIError: Error {
    case unknownUrl
}

protocol NetworkClientProtocol {
    var baseUrl: URL? {get}
    func send<T: Codable>(apiRequest: APIRequest) -> Observable<T>
}

class NetworkClient: NetworkClientProtocol {

    var baseUrl: URL?
    private let disposeBag: DisposeBag

    init(baseURL: URL? = URL.init(string: APIConstants.URL.baseUrl)) {
        self.baseUrl = baseURL
        self.disposeBag = DisposeBag()
    }

    func send<T: Codable>(apiRequest: APIRequest) -> Observable<T> {
        return Observable<T>.create { observer in
            guard let url = self.baseUrl else {
                observer.onError(APIError.unknownUrl)
                observer.onCompleted()
                return Disposables.create()
            }
            let request = apiRequest.request(with: url)
            print("request \(request)")
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let httpUrlResponse = response as? HTTPURLResponse else {
                    if let error = error {
                        //Log errors on fabric/firebase
                        observer.onError(error)
                    }
                    return
                }
                do {
                    let model: T = try JSONDecoder().decode(T.self, from: data ?? Data())
                    observer.onNext(model)
                } catch let error {
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
