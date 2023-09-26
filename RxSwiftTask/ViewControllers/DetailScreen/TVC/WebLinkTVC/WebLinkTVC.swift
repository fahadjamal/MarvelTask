//
//  CharacterDetailTVC.swift

import UIKit

class WebLinkTVC: UITableViewCell {
    // MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImgView: UIImageView!
    override func prepareForReuse() {
        titleLabel.text = ""
    }
    func setup(component: LinkComponentProtocol) {
        self.titleLabel.text = (component.output?.type)?.capitalized
    }
}
