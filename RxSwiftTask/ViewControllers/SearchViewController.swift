//
//  SearchViewController.swift

import UIKit

import RxSwift
import RxCocoa
import RxGesture
import CryptoSwift

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBarBGView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var spinnerView: UIView!
    fileprivate var viewModel: SearchViewModal!
    fileprivate let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        let schedulers = MarvelAppSchedulers()
        let repository = NetworkRepository.init(appSchedulers: schedulers)
        self.viewModel = SearchViewModal(repository: repository, schedulers: schedulers)

        // Do any additional setup after loading the view.
//        self.searchBar.delegate = self
        self.navigationItem.title = "Marvel"
        self.searchBar.searchTextField.placeholder = "Search Here"
        self.searchBar.searchTextField.clearButtonMode = .never
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = nil
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        }
        self.rxSetup()
        self.setupPager()
        self.loadCharactersList()
    }
    func loadCharactersList() {
        self.viewModel.setup()
        let loadingViewController = LoadingViewController()

        viewModel
            .state
            .subscribe(onNext: { [weak self] state in
                /// Evaluate state of view
                switch state {
                case .loading:
                    self?.add(loadingViewController)
                case .nextPage:
                    self?.tableView.addLoading() {}
                case .loaded:
                    loadingViewController.remove()
                    self?.tableView.stopLoading()
                case .error(let error):
                    self?.showErrorAlert(error)
                }
            }).disposed(by: bag)
    }
    func rxSetup(_ isSearch: Bool = false) {
        self.tableView.rx.setDelegate(self).disposed(by: bag)
        self.tableView.register(UINib(nibName: "CharacterComponentTVC", bundle: nil),
                                forCellReuseIdentifier: "CharacterComponentTVC")
        self.viewModel.items.bind(to: tableView.rx.items(cellIdentifier: SearchViewModal.cellID,
                                         cellType: CharacterComponentTVC.self)) { (row, element, cell) in
                // Configure your cell here
                cell.setup(component: element)
            }
            .disposed(by: bag)
        self.tableView.rx.modelSelected(Character.self).subscribe(onNext: { [weak self] item in
            if let detailVC = DetailViewController.instantiate(storyboardName: Storyboard.main.name),
               let repository = self?.viewModel.repository,
               let schedulers = self?.viewModel.schedulers {
                let detailViewModel = DetailViewModal(selectedData: item,
                                                      repository: repository,
                                                      schedulers: schedulers)
                detailVC.viewModel = detailViewModel
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }
        }).disposed(by: bag)
        self.viewModel.showLoadingSpinner.subscribe { [weak self] isAvaliable in
            guard let isAvaliable = isAvaliable.element else { return }
            if isAvaliable {
                self?.showCustomLoading()
            } else {
                self?.dismissCustomLoading()
            }
        }
        .disposed(by: bag)
//        searchBar
//            .rx.text // Observable property thanks to RxCocoa
//            .orEmpty // Make it non-optional
//            .debounce(RxTimeInterval.milliseconds(500),
//                      scheduler: MainScheduler.instance) // Wait 0.5 for changes.
//            .distinctUntilChanged() // If they didn't occur, check if the new value is the same as old.
//            .filter { !$0.isEmpty } // If the new value is really new, filter for non-empty query.
//            .subscribe(onNext: { [unowned self] query in
//                print("query is \(query)")// Here we subscribe to every new value, that is not empty (thanks to filter above).
////                self.viewModel.items = self.viewModel.items.filter { $0.name(query) } // We now do our "API Request" to find cities.
////                self.tableView.reloadData() // And reload table view data.
//            })
//            .disposed(by: bag)

    }
    private func setupPager() {
        let loadNextPage = tableView
            .rx
            .reachedBottom()
            .skip(1)
        loadNextPage
            .asObservable()
            .throttle(.milliseconds(500),
                      latest: false,
                      scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                if self?.tableView
                    .visibleCells
                    .isEmpty == false {
                    self?.viewModel?.loadNextPage()
                }
            }).disposed(by: bag)
    }
    func showCustomLoading() {
        spinnerView = UIView().customActivityIndicator(view: self.view,
                                                       backgroundColor: UIColor.clear)
        self.view.addSubview(spinnerView)
    }

    func dismissCustomLoading() {
        if let spinnerView  = spinnerView {
            spinnerView.removeFromSuperview()
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// extension SearchViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if (searchText == "") {
//            var array = self.viewModel.filtereditems.value
//                array.removeAll()
//            self.viewModel.filtereditems.accept(self.viewModel.items.value)
//        }
//        else {
//            var array = self.viewModel.filtereditems.value
//                array.removeAll()
//            self.viewModel.filtereditems.accept(array)
//
//            // you can do any kind of filtering here based on user input
//            let searchedItem: [Character] = self.viewModel.items.value.filter {
//                (($0.name)?.lowercased().contains(searchText.lowercased()) ?? false)
//            }
//
//            var filteredArray = self.viewModel.filtereditems.value
//                filteredArray.removeAll()
//            self.viewModel.filtereditems.accept(searchedItem)
//        }
//
////        self.tableView.dataSource = nil
////        self.rxSetup(false)
//    }
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.searchTextField.resignFirstResponder()
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        DispatchQueue.main.async {
//            searchBar.resignFirstResponder()
//            searchBar.setShowsCancelButton(false, animated: true)
//        }
//    }
//
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.setShowsCancelButton(true, animated: true)
//    }
//
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        searchBar.setShowsCancelButton(false, animated: true)
//    }
//}

extension UITableView {
    func indicatorView() -> UIActivityIndicatorView {
        var activityIndicatorView = UIActivityIndicatorView()
        if self.tableFooterView == nil {
            let indicatorFrame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 40)
            activityIndicatorView = UIActivityIndicatorView(frame: indicatorFrame)
            activityIndicatorView.isHidden = false
            activityIndicatorView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
            activityIndicatorView.isHidden = true
            self.tableFooterView = activityIndicatorView
            return activityIndicatorView
        } else {
            return activityIndicatorView
        }
    }
    func addLoading(closure: @escaping (() -> Void)) {
        if let _ = self.indexPathsForVisibleRows?.last {
            indicatorView().startAnimating()
            indicatorView().isHidden = false
            closure()
        }
    }

    func stopLoading() {
        indicatorView().stopAnimating()
        indicatorView().isHidden = true
        self.tableFooterView = nil
    }
}

// MARK: - UITableView Rx Extensions
extension Reactive where Base: UITableView {
    var nearBottom: Signal<()> {
        func isNearBottomEdge(tableView: UITableView, edgeOffset: CGFloat = 20.0) -> Bool {
            return tableView.contentOffset.y + tableView.frame.size.height + edgeOffset > tableView.contentSize.height
        }
        return self.contentOffset.asSignal(onErrorSignalWith: .empty())
            .flatMap { _ in
                return isNearBottomEdge(tableView: self.base)
                    ? .just(())
                   : .empty()
            }
    }
}

extension Reactive where Base: UIScrollView {
    /**
     Shows if the bottom of the UIScrollView is reached.
     - parameter offset: A threshhold indicating the bottom of the UIScrollView.
     - returns: ControlEvent that emits when the bottom of the base UIScrollView is reached.
     */
    func reachedBottom(offset: CGFloat = 0.0) -> ControlEvent<Void> {
        let source = contentOffset.map { contentOffset in
            let visibleHeight = self.base.frame.height - self.base.contentInset.top - self.base.contentInset.bottom
            let yOffSet = contentOffset.y + self.base.contentInset.top
            let threshold = max(offset, self.base.contentSize.height - visibleHeight)
            return yOffSet >= threshold
        }
        .distinctUntilChanged()
        .filter { $0 }
        .map { _ in () }
        return ControlEvent(events: source)
    }
}
