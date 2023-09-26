//
//  DetailItemViewModel.swift

import Foundation

// MARK: - Protocol
protocol DetailComponentProtocol {
    var input: DetailItemViewModel.Input {get}
    var output: DetailItemViewModel.Output {get}
}
// MARK: - I/O
extension DetailItemViewModel {
    struct Input {
        let component: Character
    }
    struct Output {
        let imageUrl: String?
        let name: String?
        let description: String?
    }
}

// MARK: - Class
class DetailItemViewModel: DetailComponentProtocol {
    
    /// Protocol variables I/O
    var input: Input
    var output: Output
    
    init(component: Character) {
        self.input = Input.init(component: component)
        self.output = Output.init(
            imageUrl: component.thumbnail?.getImageUrl(),
            name: component.name,
            description: component.description
        )
    }
}
