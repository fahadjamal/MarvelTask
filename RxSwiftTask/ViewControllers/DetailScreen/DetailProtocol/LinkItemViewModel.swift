//
//  MediaComponentViewModel.swift

import Foundation

// MARK: - Protocol
protocol LinkComponentProtocol {
    var input: LinkItemViewModel.Input {get}
    var output: LinkItemViewModel.Output? {get}
}
// MARK: - I/O
extension LinkItemViewModel {
    struct Input {
        let component: URLElement
    }
    struct Output {
        let type: String?
        let url: String?
    }
}

// MARK: - Class
class LinkItemViewModel: LinkComponentProtocol {
    /// Protocol variables I/O
    var input: Input
    var output: Output?
    init(component: URLElement) {
        self.input = Input.init(component: component)
        self.output = Output.init(
            type: component.type,
            url: component.url
        )
    }
}
