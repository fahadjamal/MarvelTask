//
//  UIImageViewExt.swift

import Foundation
import Kingfisher

extension UIImageView {
    func setImage(with urlString: String) {
        let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let url = URL.init(string: escapedString ?? "") else {
            return
        }
        let resource = ImageResource(downloadURL: url,
                                     cacheKey: urlString)
        self.kf.indicatorType = .activity
        self.kf.setImage(with: resource)
    }
}
