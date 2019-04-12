// Copyright © 2019 MovieGrid.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import ReactiveSwift
import Result
import ReactiveCocoa
import Cartography

// MARK: - Protocol

protocol HomeScreenViewProtocol {
    func wireIn(interactor: HomeScreenInteractorProtocol, presenter: HomeScreenPresenterProtocol)
    var eventSignal: Signal<HomeScreenView.Event, NoError> { get }
}

// MARK: - Implementation

final class HomeScreenView: UIViewControllerBase, HomeScreenViewProtocol, EventEmitter {

    enum Event {
        case someEvent
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .lightGray
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Content

    private func fill() {
        //
    }

    private func layout() {
        //
    }

    // MARK: - Requests

    func wireIn(interactor: HomeScreenInteractorProtocol, presenter: HomeScreenPresenterProtocol) {
        interactor.requestSignal
            .observe(on: UIScheduler())
            .observeValues { request in
                _ = request
            }

        presenter.requestSignal
            .observe(on: UIScheduler())
            .observeValues { request in
                _ = request
            }
    }

}
