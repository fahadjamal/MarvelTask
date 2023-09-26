//
//  DetailViewModal.swift
//  RxSwiftTask

import Foundation
import RxSwift
import RxCocoa

class DetailViewModal {
    let characterDetailTVCID = "CharacterDetailTVC"
    let mediaItemTVCID = "MediaItemTVC"
    let webLinkTVCID = "WebLinkTVC"
    private var characterData: Character!
    private let disposeBag: DisposeBag = DisposeBag()
    var dataSource: [MultipleSectionModel]!
    private let schedulers: AppSchedulers!
    private let repository: NetworkRepositoryProtocol!

    var rxDataSource = BehaviorRelay<[MultipleSectionModel]>(value: [])
    let state: PublishSubject<CharactersListState> = PublishSubject<CharactersListState>()

    init(selectedData: Character,
         repository: NetworkRepositoryProtocol,
         schedulers: AppSchedulers) {
        self.characterData = selectedData
        self.repository = repository
        self.schedulers = schedulers
        self.dataSource = []
    }
    func setup() {
        let component = DetailItemViewModel.init(component: self.characterData)
        self.dataSource = [
            .headerSection(title: "", items: [
                .headerSectionItem(component: component)
                ]
            )
        ]

        if let characterId = self.characterData.id {
            loadMedia(characterId: characterId)
        }
    }
    func loadMedia(characterId: Int) {
        Observable<[AnyObject]>.concat(
            repository
                .fetchComics(characterId: characterId)
                .map {$0 as [AnyObject] },
            repository
                .fetchSeries(characterId: characterId)
                .map { $0 as [AnyObject] },
            repository
                .fetchStories(characterId: characterId)
                .map { $0 as [AnyObject] },
            repository
                .fetchEvents(characterId: characterId)
                .map { $0 as [AnyObject] })
            .subscribe(on: schedulers.background)
            .observe(on: schedulers.main)
            .flatMap({ [weak self] result -> Observable<MultipleSectionModel?> in
                guard let weakSelf = self,
                      result.count > 0 else { return .just(nil) }
                var sectionTitle = ""
                if let _ = result as? [Comic] { sectionTitle = "Comics" }
                if let _ = result as? [Series] { sectionTitle = "Series" }
                if let _ = result as? [Story] { sectionTitle = "Stories" }
                if let _ = result as? [Event] { sectionTitle = "Events" }
                
                let section = MultipleSectionModel.mediaSection(
                    title: sectionTitle,
                    items: [
                        .mediaSectionItem(
                            components: weakSelf.buildMediaComponentsFor(result)
                        )
                    ]
                )
                return .just(section)
            })
            .subscribe(onNext: { [weak self] sectionModel in
                guard let weakSelf = self,
                      let sectionModel = sectionModel
                else { return }
                weakSelf.dataSource.append(sectionModel)
                weakSelf.rxDataSource.accept(weakSelf.dataSource)
            }, onError: { [weak self] error in
                self?.state.onNext(.error(error))
            }, onCompleted: {
                if let URLElements = self.characterData.urls {
                    var sectionItem: [SectionItem] = [SectionItem]()
                    for elementItem in URLElements {
                        sectionItem.append(.webSectionItem(components: self.buildURLComponentsFor(elementItem)))
                    }
                    let sectionModel = MultipleSectionModel.webSection(
                        title: "Related Items",
                        items: sectionItem
                    )
                    self.dataSource.append(sectionModel)
                    self.rxDataSource.accept(self.dataSource)
                }

            }).disposed(by: disposeBag)
    }
    func buildMediaComponentsFor(_ medias: [Any]) -> [MediaComponentProtocol] {
        var components: [MediaComponentProtocol] = []
            medias.forEach { media in
                let component = MediaComponentViewModel.init(media: media)
                components.append(component)
            }
        return components
    }
    func buildURLComponentsFor(_ media: URLElement) -> LinkComponentProtocol {
        let component = LinkItemViewModel.init(component: media)
        return component
    }
}
