//
//  SearchViewModal.swift

import Foundation
import RxSwift
import RxCocoa

class SearchViewModal: CustomSearchViewModel <[Character]> {
    static let cellID = "CharacterComponentTVC"
    let schedulers: AppSchedulers!
    let repository: NetworkRepositoryProtocol!
    private let disposeBag = DisposeBag()
    private var paginator: Pager
    var items = BehaviorRelay<[Character]>(value: [])
    var filtereditems = BehaviorRelay<[Character]>(value: [])
    let showLoadingSpinner = PublishSubject<Bool>()
    let state: PublishSubject<CharactersListState> = PublishSubject<CharactersListState>()
    init(repository: NetworkRepositoryProtocol,
         schedulers: AppSchedulers) {
        self.schedulers = schedulers
        self.repository = repository
        self.paginator = Pager.init(
            offset: 0,
            limit: APIConstants
                .ParamValues
                .pagerDefaultValue
        )
    }
    func getResturantList() -> Observable<[Character]> {
        return Observable.create({ (observer) -> Disposable in
            observer.onNext(self.items.value)
            observer.onCompleted()
            return Disposables.create()
        })
    }
    func getFilteredResturantList() -> Observable<[Character]> {
        return Observable.create({ (observer) -> Disposable in
            observer.onNext(self.filtereditems.value)
            observer.onCompleted()
            return Disposables.create()
        })
    }
    func setup() {
        /// Loading
        state.onNext(.loading)
        fetchContent()
    }
    private func fetchContent() {
        showLoadingSpinner.onNext(true)
        repository
            .fetchCharacters(paginator: paginator)
            .subscribe(on: schedulers.background)
            .observe(on: schedulers.main)
            .subscribe(onNext: { [weak self] result in
                guard let result = result else { return }
                self?.appendCharacters(result)
                self?.showLoadingSpinner.onNext(false)
            }, onError: { [weak self] error in
                self?.state.onNext(.error(error))
                self?.showLoadingSpinner.onNext(false)

            }).disposed(by: disposeBag)
    }
    // MARK: - Paginator
    func loadNextPage() {
        /// Load next page
        state.onNext(.nextPage)
        paginator.nextPage()
        /// Request
        fetchContent()
    }
}

class CustomSearchViewModel<T> {
    // inputs
    private let searchSubject = PublishSubject<String>()
    var searchObserver: AnyObserver<String> {
        return searchSubject.asObserver()
    }
    // outputs
    private let loadingSubject = PublishSubject<Bool>()
    var isLoading: Driver<Bool> {
        return loadingSubject
            .asDriver(onErrorJustReturn: false)
    }

    private let errorSubject = PublishSubject<SearchError?>()
    var error: Driver<SearchError?> {
        return errorSubject
            .asDriver(onErrorJustReturn: SearchError.unkowned)
    }

    private let contentSubject = PublishSubject<[T]>()
    var content: Driver<[T]> {
        return contentSubject
            .asDriver(onErrorJustReturn: [])
    }
}

extension SearchViewModal {
    func appendCharacters(_ newCharacters: [Character]) {
        if paginator.isFirstPage {
            items.accept(newCharacters)
            filtereditems.accept(newCharacters)
        } else {
            let oldDatas = items.value
            items.accept(oldDatas + newCharacters)
            filtereditems.accept(oldDatas + newCharacters)
            state.onNext(.loaded)
        }
    }
}

enum CharactersListState: Equatable {
    case loading
    case loaded
    case nextPage
    case error(_ error: Error)
    static func == (lhs: CharactersListState, rhs: CharactersListState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded, .loaded):
            return true
        case (.nextPage, .nextPage):
            return true
        case (.error, .error):
            return true
        default:
            return false
        }
    }
}
