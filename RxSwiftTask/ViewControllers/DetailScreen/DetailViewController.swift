//
//  DetailViewController.swift
//  RxSwiftTask

import UIKit

import RxSwift
import RxCocoa
import RxGesture
import CryptoSwift
import RxDataSources

class DetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var viewModel: DetailViewModal!
    var dataSource: RxTableViewSectionedReloadDataSource<MultipleSectionModel>?
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = nil
        self.tableView.delegate = self
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }
        self.rxSetup()
        self.setupDataSource()
        self.bindData()
        self.setup()
    }
    func rxSetup() {
        if let viewModel = self.viewModel {
            self.tableView.register(UINib(nibName: viewModel.characterDetailTVCID, bundle: nil),
                                    forCellReuseIdentifier: viewModel.characterDetailTVCID)
            self.tableView.register(UINib(nibName: viewModel.mediaItemTVCID, bundle: nil),
                                    forCellReuseIdentifier: viewModel.mediaItemTVCID)
            self.tableView.register(UINib(nibName: viewModel.webLinkTVCID, bundle: nil),
                                    forCellReuseIdentifier: viewModel.webLinkTVCID)
        }
    }
    private func setupDataSource() {
        dataSource =
            RxTableViewSectionedReloadDataSource<MultipleSectionModel>(
                configureCell: { dataSource, table, idxPath, _ in
                    switch dataSource[idxPath] {
                    case let .headerSectionItem(component):
                        guard let cell = table.dequeueCell(withType: CharacterDetailTVC.self)
                                as? CharacterDetailTVC else {
                            return UITableViewCell()
                        }
                        cell.setup(component: component)
                        return cell
                    case .mediaSectionItem(components: let medias):
                        guard let cell = table.dequeueCell(withType: MediaItemTVC.self)
                                as? MediaItemTVC else {
                            return UITableViewCell()
                        }
                        cell.setup(medias: medias)
                        return cell
                    case .webSectionItem(components: let component):
                        print("\(component)")
                        guard let cell = table.dequeueCell(withType: WebLinkTVC.self)
                                as? WebLinkTVC else {
                            return UITableViewCell()
                        }
                        cell.setup(component: component)
                        return cell
                    }
                },
                titleForHeaderInSection: { dataSource, index in
                    let section = dataSource[index]
                    return section.title
                }
            )
    }
    private func bindData() {
        guard let dataSource = dataSource else { return }
        tableView.dataSource = nil
        viewModel?.rxDataSource
            .asDriver(onErrorJustReturn: [])
            .map { $0 }
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    private func setup() {
        viewModel?.setup()
    }
}

extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        if let dataSource = self.viewModel.dataSource {
            let dataItem = dataSource[section]
            let title = dataItem.title
            return title
        }
        return ""
    }
    // Customize the appearance of section headers using viewForHeaderInSection method
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let dataSource = self.viewModel.dataSource {
            let dataItem = dataSource[section]
            let title = dataItem.title
            if title.count > 0 {
                let headerLabel = UILabelPadded()
                headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
                headerLabel.textColor = .red // Set the title color here
                headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
                return headerLabel
            } else {
                return UIView(frame: .zero)
            }
        } else {
            return UIView(frame: .zero)
        }
    }
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .black
    }
}

class UILabelPadded: UILabel {
     override func drawText(in rect: CGRect) {
         let insets = UIEdgeInsets.init(top: 0, left: 5, bottom: 0, right: 5)
         super.drawText(in: rect.inset(by: insets))
    }
}
