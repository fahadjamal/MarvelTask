//
//  CharacterComponent.swift

import UIKit
import RxSwift
import RxCocoa

class CharacterComponentTVC: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet weak var viewComponent: UIView!
    @IBOutlet weak var titleBackgroundView: UIView!
    @IBOutlet weak var imageViewBackground: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    private let disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        imageViewBackground.image = nil
    }
    // MARK: - Setup
    func setup(component: Character) {
        setupView()
        self.titleLabel.text = component.name
        guard let thumbnail = component.thumbnail,
        let url = thumbnail.getImageUrl() else {
            imageViewBackground.image = nil
            return
        }
        self.imageViewBackground.setImage(with: url)
    }
    // MARK: - Setup View
    func setupView() {
        /// Views
        contentView.backgroundColor = .clear
        viewComponent.layer.cornerRadius = Constants.cornerRadius
        viewComponent.clipsToBounds = true
        titleBackgroundView.backgroundColor = .black.withAlphaComponent(Constants.alpha)
        /// Label
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: Constants.fontSize)
    }
}

// MARK: - Corner Radius
struct Constants {
    static let fontSize = CGFloat(14)
    static let cornerRadius = CGFloat(0)
    static let alpha = CGFloat(0.5)
}
