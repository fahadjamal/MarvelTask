//
//  CharacterDetailDataSource.swift

//
//  on 24/9/21.
//

import Foundation
import RxDataSources

// MARK: RX - Data Sources

enum MultipleSectionModel {
    case headerSection(title: String, items: [SectionItem])
    case mediaSection(title: String, items: [SectionItem])
    case webSection(title: String, items: [SectionItem])
}

enum SectionItem {
    case headerSectionItem(component: DetailComponentProtocol)
    case mediaSectionItem(components: [MediaComponentProtocol])
    case webSectionItem(components: LinkComponentProtocol)
}

extension MultipleSectionModel: SectionModelType {
    typealias Item = SectionItem
    var items: [SectionItem] {
        switch  self {
        case .headerSection(title: _, items: let items):
            return items.map { $0 }
        case .mediaSection(title: _, items: let items):
            return items.map { $0 }
        case .webSection(title: _, items: let items):
            return items.map { $0 }
        }
    }
    init(original: MultipleSectionModel, items: [Item]) {
        switch original {
        case let .headerSection(title: title, items: _):
            self = .headerSection(title: title, items: items)
        case let .mediaSection(title: title, items: _):
            self = .mediaSection(title: title, items: items)
        case let .webSection(title: title, items: _):
            self = .webSection(title: title, items: items)
        }
    }
}

extension MultipleSectionModel {
    var title: String {
        switch self {
        case .headerSection(title: let title, items: _):
            return title
        case .mediaSection(title: let title, items: _):
            return title
        case .webSection(title: let title, items: _):
            return title
        }
    }
}
