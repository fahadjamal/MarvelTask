//
//  NetworkRepository.swift

import Foundation
import RxSwift

protocol NetworkRepositoryProtocol {
    var apiClient: NetworkClientProtocol { get }
    /// Characters
    func fetchCharacters(paginator: Pager) -> Observable<[Character]?>
    /// Media
    func fetchComics(characterId: Int) -> Observable<[Comic]>
    func fetchSeries(characterId: Int) -> Observable<[Series]>
    func fetchStories(characterId: Int) -> Observable<[Comic]>
    func fetchEvents(characterId: Int) -> Observable<[Comic]>
}

struct Pager {
    var offset: Int
    let limit: Int
    var isFirstPage: Bool {
        return offset == 0
    }
    mutating func nextPage() {
        self.offset += limit
    }
}

class NetworkRepository: NetworkRepositoryProtocol {
    /// Public
    var apiClient: NetworkClientProtocol
    /// Private
    private let appSchedulers: AppSchedulers
    private let disposeBag: DisposeBag
    init(apiClient: NetworkClientProtocol = NetworkClient(),
         appSchedulers: AppSchedulers) {
        self.apiClient = apiClient
        self.appSchedulers = appSchedulers
        self.disposeBag = DisposeBag()
    }
    // MARK: - Characters
    func fetchCharacters<T: Codable>(paginator: Pager) -> Observable<[T]?> {
        let request = CharactersRequest.init(
            offset: paginator.offset,
            limit: paginator.limit
        )
        let observeResponse: Observable<CharactersListResponse> =
            fetchNetworkRequest(request: request)
        let fetchRequest = observeResponse
            .flatMap { response -> Observable<[T]?> in
                if let result = response.data?.results?
                    .compactMap({$0}) as? [T] {
                    return .just(result)
                }
                return .just(nil)
            }
        /// Try to load DB - Network
        if paginator.isFirstPage {
            return Observable<[T]?>.concat(
                fetchRequest
                    .observe(on: appSchedulers.main)
                    .flatMap { result -> Observable<[T]?> in
                        return .just(result)
                }
            )
        } else {
            /// Load next page
            return fetchRequest
        }
    }
    // MARK: - Comics
    func fetchComics<T: Codable>(characterId: Int) -> Observable<[T]> {
        let request = ComicRequest.init(characterId: characterId)
        let observeResponse: Observable<ComicListResponse> =
            fetchNetworkRequest(request: request)
        return observeResponse
            .flatMap { response -> Observable<[T]> in
                if let result = response.data?.results?
                    .compactMap({$0}) as? [T] {
                    return .just(result)
                }
                return .just([])
        }
    }
    // MARK: - Series
    func fetchSeries<T: Codable>(characterId: Int) -> Observable<[T]> {
        let request = SeriesRequest.init(characterId: characterId)
        let observeResponse: Observable<SeriesListResponse> =
            fetchNetworkRequest(request: request)
        return observeResponse
            .flatMap { response -> Observable<[T]> in
                if let result = response.data?.results?
                    .compactMap({$0}) as? [T] {
                    return .just(result)
                }
                return .just([])
        }
    }
    // MARK: - Stories
    func fetchStories<T: Codable>(characterId: Int) -> Observable<[T]> {
        let request = StoriesRequest.init(characterId: characterId)
        let observeResponse: Observable<StoriesListResponse> =
            fetchNetworkRequest(request: request)
        return observeResponse
            .flatMap { response -> Observable<[T]> in
                if let result = response.data?.results?
                    .compactMap({$0}) as? [T] {
                    return .just(result)
                }
                return .just([])
        }
    }
    // MARK: - Events
    func fetchEvents<T: Codable>(characterId: Int) -> Observable<[T]> {
        let request = EventsRequest.init(characterId: characterId)
        let observeResponse: Observable<EventsListResponse> =
            fetchNetworkRequest(request: request)
        return observeResponse
            .flatMap { response -> Observable<[T]> in
                if let result = response.data?.results?
                    .compactMap({$0}) as? [T] {
                    return .just(result)
                }
                return .just([])
        }
    }
}

// MARK: - Network Access
extension NetworkRepository {
    func fetchNetworkRequest<T: Codable>(request: APIRequest) -> Observable<T> {
        return self.apiClient
            .send(apiRequest: request)
            .retry(1)
            .flatMap { response -> Observable<T> in
                .just(response)
            }
    }
}
