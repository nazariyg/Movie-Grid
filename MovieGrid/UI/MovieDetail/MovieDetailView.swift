// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import ReactiveSwift
import Result
import ReactiveCocoa
import Cartography

// MARK: - Protocol

protocol MovieDetailViewProtocol {
    func wireIn(interactor: MovieDetailInteractorProtocol, presenter: MovieDetailPresenterProtocol)
    func setParameters(_ parameters: MovieDetailScene.Parameters)
}

// MARK: - Implementation

final class MovieDetailView: UIViewControllerBase, MovieDetailViewProtocol {

    private var backgroundImageView: UIImageView!
    private var backgroundBlurView: UIVisualEffectView!
    private var contentTableView: UITableView!
    private var tableRowViewModels: [MovieDetailTableRowViewModel] = []

    // MARK: - Lifecycle

    func setParameters(_ parameters: MovieDetailScene.Parameters) {
        setNavigationBarTitle(parameters.movieTitle)
    }

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
        backgroundImageView = UIImageView()
        with(backgroundImageView!) {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            view.addSubview($0)
        }

        backgroundBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        with(backgroundBlurView!) {
            view.addSubview($0)
        }

        contentTableView = UITableView()
        with(contentTableView!) {
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.indicatorStyle = .white
            $0.dataSource = self
            $0.registerCell(MovieDetailTableViewSpaceCell.self)
            $0.registerCell(MovieDetailTableViewSeparatorCell.self)
            $0.registerCell(MovieDetailTableViewHeaderCell.self)
            $0.registerCell(MovieDetailTableViewTitleCell.self)
            $0.registerCell(MovieDetailTableViewOverviewCell.self)
            view.addSubview($0)
        }
    }

    private func layout() {
        constrain(backgroundImageView, view) { view, superview in
            view.leading == superview.leading
            view.trailing == superview.trailing
            view.top == superview.safeAreaLayoutGuide.top
            view.bottom == superview.bottom
        }

        constrain(backgroundBlurView, backgroundImageView) { view, reference in
            view.edges == reference.edges
        }

        constrain(contentTableView, view) { view, superview in
            view.leading == superview.leading
            view.trailing == superview.trailing
            view.top == superview.safeAreaLayoutGuide.top
            view.bottom == superview.bottom
        }
    }

    private func setNavigationBarTitle(_ title: String?) {
        let navigationBarLabel = UIStyledLabel()
        navigationBarLabel.text = title
        navigationBarLabel.font = .main(20)
        navigationBarLabel.textColor = Config.shared.appearance.defaultNavigationBarTextColor
        navigationItem.titleView = navigationBarLabel
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateRowHeights()
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.contentTableView.reloadData()
        }, completion: { [weak self] _ in
            self?.updateRowHeights()
        })
    }

    private func updateRowHeights() {
        UIView.setAnimationsEnabled(false)
        contentTableView.beginUpdates()
        contentTableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }

    // MARK: - Requests

    func wireIn(interactor: MovieDetailInteractorProtocol, presenter: MovieDetailPresenterProtocol) {
        presenter.requestSignal
            .observe(on: UIScheduler())
            .observeValues { [weak self] request in
                switch request {
                case let .fillContent(movieViewModel, tableRowViewModels):
                    self?.fillContent(movieViewModel: movieViewModel, tableRowViewModels: tableRowViewModels)
                }
            }
    }

    // MARK: - Content

    private func fillContent(movieViewModel: MovieDetailViewModel, tableRowViewModels: [MovieDetailTableRowViewModel]) {
        backgroundImageView.kf.setImage(with: movieViewModel.posterURL)
        self.tableRowViewModels = tableRowViewModels
        contentTableView.reloadData()
    }

}

extension MovieDetailView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableRowViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = tableRowViewModels[indexPath.row]
        switch viewModel {

        case .space:
            return contentTableView.dequeueCell(MovieDetailTableViewSpaceCell.self, forIndexPath: indexPath)

        case .separator:
            return contentTableView.dequeueCell(MovieDetailTableViewSeparatorCell.self, forIndexPath: indexPath)

        case let .header(posterURL, voteAverage, releaseDate):
            let cell = contentTableView.dequeueCell(MovieDetailTableViewHeaderCell.self, forIndexPath: indexPath)
            cell.update(posterURL: posterURL, voteAverage: voteAverage, releaseDate: releaseDate)
            return cell

        case let .title(text):
            let cell = contentTableView.dequeueCell(MovieDetailTableViewTitleCell.self, forIndexPath: indexPath)
            cell.update(title: text)
            return cell

        case let .overview(text):
            let cell = contentTableView.dequeueCell(MovieDetailTableViewOverviewCell.self, forIndexPath: indexPath)
            cell.update(overview: text)
            return cell

        }
    }

}
