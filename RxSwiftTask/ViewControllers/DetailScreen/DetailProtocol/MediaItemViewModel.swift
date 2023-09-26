//
//  MediaComponentViewModel.swift

import Foundation

// MARK: - Protocol
protocol MediaComponentProtocol {
    var input: MediaComponentViewModel.Input {get}
    var output: MediaComponentViewModel.Output? {get}
}
// MARK: - I/O
extension MediaComponentViewModel {
    struct Input {
        let media: Any
    }
    struct Output {
        let imageUrl: String?
        let title: String?
    }
}

// MARK: - Class
class MediaComponentViewModel: MediaComponentProtocol {
    /// Protocol variables I/O
    var input: Input
    var output: Output?
    init(media: Any) {
        self.input = Input.init(media: media)
        if let comic = media as? Comic {
            self.output = Output.init(imageUrl: comic.thumbnail?.getImageUrl(),
                                      title: comic.name ?? "")
        } else if let serie = media as? Series {
            self.output = Output.init(
                imageUrl: serie.thumbnail?.getImageUrl(),
                title: serie.name ?? ""
            )
        }
    }
}
