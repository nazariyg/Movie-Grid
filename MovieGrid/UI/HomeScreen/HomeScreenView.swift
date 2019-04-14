// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import ReactiveSwift
import Result
import ReactiveCocoa
import Cartography
import DeepDiff

// MARK: - Protocol

protocol HomeScreenViewProtocol {
    func wireIn(interactor: HomeScreenInteractorProtocol, presenter: HomeScreenPresenterProtocol)
    var eventSignal: Signal<HomeScreenView.Event, NoError> { get }
}

// MARK: - Implementation

final class HomeScreenView: UIViewControllerBase, HomeScreenViewProtocol, EventEmitter {

    enum Event {
        case scrolledToEnd
        case startedRefresh
        case tappedMovie(movieID: Int)
    }

    private var moviesCollectionView: NowPlayingMoviesCollectionView!
    private var isLoading: ReactiveSwift.Property<Bool>?
    private let loadingIndicatorIsHidden = MutableProperty<Bool>(false)
    private var movieViewModels: [NowPlayingMovieCollectionItemViewModel] = []
    private var refreshControl: UIRefreshControl!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Config.shared.appearance.defaultBackgroundColor

        fill()
        layout()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Content

    private func fill() {
        reactive
            .viewWillAppear
            .observe(on: UIScheduler())
            .take(first: 1)
            .observeValues { [weak self] in
                self?.fillNavigationBar()
            }

        moviesCollectionView = NowPlayingMoviesCollectionView()
        with(moviesCollectionView!) {
            $0.registerCell(NowPlayingMoviesCollectionViewCell.self)
            $0.registerFooter(NowPlayingMoviesCollectionViewLoadingIndicatorFooter.self)
            $0.dataSource = self
            $0.delegate = self
            $0.contentInsetAdjustmentBehavior = .automatic
            view.addSubview($0)
        }

        refreshControl = UIRefreshControl()
        with(refreshControl!) {
            $0.tintColor = .lightGray
            moviesCollectionView.addSubview($0)

            $0.reactive.controlEvents(.valueChanged)
                .observeValues { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.updateMovies(with: [])
                    strongSelf.eventEmitter.send(value: .startedRefresh)
                }
        }
    }

    private func layout() {
        constrain(moviesCollectionView, view) { view, superview in
            view.edges == superview.edges
        }
    }

    private func fillNavigationBar() {
        guard let navigationController = navigationController else { return }
        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.navigationBar.tintColor = Config.shared.appearance.defaultNavigationBarTextColor

        let navigationBarLabel = UIStyledLabel()
        navigationBarLabel.text = "latest_movies".localized
        navigationBarLabel.font = .main(20)
        navigationBarLabel.textColor = Config.shared.appearance.defaultNavigationBarTextColor
        navigationItem.titleView = navigationBarLabel
    }

    // MARK: - Requests

    func wireIn(interactor: HomeScreenInteractorProtocol, presenter: HomeScreenPresenterProtocol) {
        presenter.requestSignal
            .observe(on: UIScheduler())
            .observeValues { [weak self] request in
                guard let strongSelf = self else { return }
                switch request {
                case let .initView(isLoading):
                    strongSelf.isLoading = isLoading
                    strongSelf.moviesCollectionView.reloadData()
                case let .showMovies(movieViewModels):
                    strongSelf.updateMovies(with: movieViewModels)
                case .stopRefreshControlIfNeeded:
                    if strongSelf.refreshControl.isRefreshing {
                        strongSelf.refreshControl.endRefreshing()
                    }
                }
            }
    }

    private func updateMovies(with newMovieViewModels: [NowPlayingMovieCollectionItemViewModel]) {
        // Compute the difference between the old and the new collections of movies and insert, replace, or delete items with animation.
        let changes = diff(old: movieViewModels, new: newMovieViewModels)
        loadingIndicatorIsHidden.value = true
        moviesCollectionView.reload(changes: changes, updateData: {
            movieViewModels = newMovieViewModels
        }, completion: { [weak self] _ in
            self?.loadingIndicatorIsHidden.value = false
        })
    }

}

extension HomeScreenView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieViewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = moviesCollectionView.dequeueCell(NowPlayingMoviesCollectionViewCell.self, forIndexPath: indexPath)
        guard let movie = movieViewModels[safe: indexPath.row] else { return cell }
        cell.update(movie: movie, onTapped: { [weak self] movieID in
            self?.eventEmitter.send(value: .tappedMovie(movieID: movieID))
        })
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let view = moviesCollectionView.dequeueFooter(NowPlayingMoviesCollectionViewLoadingIndicatorFooter.self, forIndexPath: indexPath)
        if let isLoading = isLoading {
            view.update(isLoading: isLoading, isHidden: ReactiveSwift.Property(loadingIndicatorIsHidden))
        }
        return view
    }

}

extension HomeScreenView: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String,
        at indexPath: IndexPath) {

        guard
            elementKind == UICollectionView.elementKindSectionFooter,
            moviesCollectionView.numberOfItems(inSection: 0) > 0
        else { return }

        eventEmitter.send(value: .scrolledToEnd)
    }

}
