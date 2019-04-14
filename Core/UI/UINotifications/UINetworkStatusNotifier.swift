// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import ReactiveSwift
import Cartography

// MARK: - Protocol

public protocol UINetworkStatusNotifierProtocol {}

// MARK: - Implementation

public final class UINetworkStatusNotifier: UINetworkStatusNotifierProtocol, SharedInstance {

    public typealias InstanceProtocol = UINetworkStatusNotifierProtocol
    public static let defaultInstance: InstanceProtocol = UINetworkStatusNotifier()

    private static let messageFontSize: CGFloat = 18
    private static let slideAnimationDuration: TimeInterval = 0.33
    private static let reconnectedAnimationDuration: TimeInterval = 0.33
    private static let reconnectedKeepDuration: TimeInterval = 1
    private static let offlineNotificationBackgroundColor = Config.shared.appearance.defaultErrorBackgroundColor
    private static let onlineNotificationBackgroundColor = UIColor("#41754f")
    private static let extraShownHeight: CGFloat = 44  // no metrics, aimed to cover the navigation bar exactly, if any
    private static let messageLabelBottomPadding: CGFloat = s(4)

    private var notificationView: NotificationView?
    private var messageLabel: UIStyledLabel?
    private var slidingConstraintGroup: ConstraintGroup?
    private var isHiding = false
    private var showAgain = false

    // MARK: - Lifecycle

    private init() {
        wireInNetwork()
    }

    // MARK: - Notifications

    private func showIfNeeded() {
        guard notificationView == nil else {
            if isHiding {
                showAgain = true
            }
            return
        }

        // Notification components.

        notificationView = NotificationView()
        with(notificationView!) {
            $0.backgroundColor = Self.offlineNotificationBackgroundColor
            containerView.addSubview($0)
        }

        messageLabel = UIStyledLabel()
        with(messageLabel!) {
            $0.numberOfLines = 0
            $0.text = "network_offline_notification".localized
            $0.font = .main(Self.messageFontSize)
            $0.textColor = .white
            $0.textAlignment = .center
            notificationView!.addSubview($0)
        }

        // Layout.

        constrain(messageLabel!, notificationView!) { view, superview in
            view.leading == superview.leading
            view.trailing == superview.trailing
            view.bottom == superview.bottom - Self.messageLabelBottomPadding
        }

        constrain(notificationView!, containerView) { view, superview in
            view.leading == superview.leading
            view.trailing == superview.trailing
            view.top == superview.top
        }

        slidingConstraintGroup =
            constrain(notificationView!, containerView) { view, superview in
                view.bottom == superview.top
        }

        guard
            let notificationView = notificationView,
            let slidingConstraintGroup = slidingConstraintGroup
        else { return }

        // Show.

        notificationView.postLayoutSubviewsAction = {
            DispatchQueue.main.executeAsync { [weak self] in
                guard let strongSelf = self else { return }

                strongSelf.slidingConstraintGroup =
                    constrain(notificationView, strongSelf.containerView, replace: slidingConstraintGroup) { view, superview in
                        view.bottom == superview.safeAreaLayoutGuide.top + Self.extraShownHeight
                    }

                UIView.animate(withDuration: Self.slideAnimationDuration, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.containerView.layoutIfNeeded()
                }, completion: nil)
            }
        }

        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.reactive.stateChanged
            .observeValues { [weak self] gestureRecognizer in
                guard let strongSelf = self else { return }
                if gestureRecognizer.state == .recognized {
                    strongSelf.hideIfNeeded(isOnline: nil)
                }
        }
        notificationView.addGestureRecognizer(tapGestureRecognizer)
    }

    private func hideIfNeeded(isOnline: Bool?) {
        guard
            let notificationView = notificationView,
            let messageLabel = messageLabel,
            let slidingConstraintGroup = slidingConstraintGroup
        else { return }

        if isOnline == true {
            messageLabel.text = "network_online_notification".localized
        }

        // Hide.

        isHiding = true
        showAgain = false

        let hide = { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.slidingConstraintGroup =
                constrain(notificationView, strongSelf.containerView, replace: slidingConstraintGroup) { view, superview in
                    view.bottom == superview.top
                }

            let delay = isOnline == true ? Self.reconnectedKeepDuration : 0
            UIView.animate(
                withDuration: Self.slideAnimationDuration, delay: delay, options: .curveEaseIn,
                animations: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.containerView.layoutIfNeeded()
                }, completion: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.notificationView = nil
                    strongSelf.messageLabel = nil
                    strongSelf.slidingConstraintGroup = nil

                    strongSelf.isHiding = false
                    if strongSelf.showAgain {
                        strongSelf.showAgain = false
                        if let isOnline = Network.shared.isOnline.value, !isOnline {
                            strongSelf.showIfNeeded()
                        }
                    }
                })
        }

        if isOnline == true {
            UIView.animate(withDuration: Self.reconnectedAnimationDuration, delay: 0, options: [], animations: {
                notificationView.backgroundColor = Self.onlineNotificationBackgroundColor
            }, completion: { _ in
                hide()
            })
        } else {
            hide()
        }
    }

    private lazy var containerView: UIView = {
        return UIRootViewControllerContainer.shared.containerView(forKey: fullStringType(UINetworkStatusNotifier.self), isUserInteractionEnabled: true)
    }()

    // MARK: - Network

    private func wireInNetwork() {
        SignalProducer.combineLatest(
            UI.shared.isInitialized.producer.filter({ $0 }),
            Network.shared.isOnline.producer
                .observe(on: UIScheduler())
                .skipNil())
                .startWithValues { [weak self] _, isOnline in
                    guard let strongSelf = self else { return }
                    if !isOnline {
                        DispatchQueue.main.executeAsync {
                            strongSelf.showIfNeeded()
                        }
                    } else {
                        strongSelf.hideIfNeeded(isOnline: isOnline)
                    }
                }
    }

    private typealias `Self` = UINetworkStatusNotifier

}

private final class NotificationView: UIView {

    var postLayoutSubviewsAction: VoidClosure?

    override func layoutSubviews() {
        super.layoutSubviews()
        postLayoutSubviewsAction?()
        postLayoutSubviewsAction = nil
    }

}
