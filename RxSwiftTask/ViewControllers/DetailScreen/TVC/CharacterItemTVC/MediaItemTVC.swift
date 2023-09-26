//
//  MediaComponent.swift

import UIKit
import RxSwift

class MediaItemTVC: UITableViewCell {
    // MARK: - Outlets
    @IBOutlet private var collectionView: UICollectionView!
    // MARK: - Variables
    var dataSource = PublishSubject<[MediaComponentProtocol]>()
    var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        dataSource = PublishSubject<[MediaComponentProtocol]>()
        disposeBag = DisposeBag()
    }
    // MARK: - Setup
    func setup(medias: [MediaComponentProtocol]) {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        collectionView?.registerCell(
            type: MediaItemCVC.self
        )
        dataSource.bind(to: collectionView.rx.items) { [weak self] collectionView, index, component in
            guard let cell = collectionView.dequeueCell(
                    withType: MediaItemCVC.self,
                    for: IndexPath(index: index)) as? MediaItemCVC
            else {
                return UICollectionViewCell()
            }

            cell.setup(component: component)
            return cell

        }.disposed(by: disposeBag)

        dataSource.onNext(medias)
    }
}
