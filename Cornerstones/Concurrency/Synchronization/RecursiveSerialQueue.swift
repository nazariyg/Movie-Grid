// Copyright © 2019 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

/// Allows for non-blocking synchronous recursive operations on a serial queue.
public final class RecursiveSerialQueue {

    private let queue: DispatchQueue
    private let queueTag = DispatchSpecificKey<String>()
    private var suspendCount = 0

    // MARK: - Lifecycle

    public convenience init(qos: DispatchQoS, labelSuffix: String = "", filePath: String = #file) {
        let label = DispatchQueue.uniqueQueueLabel(labelSuffix: labelSuffix, filePath: filePath)
        self.init(qos: qos, label: label)
    }

    public init(qos: DispatchQoS, label: String) {
        queue = DispatchQueue(label: label, qos: qos)
        queue.setSpecific(key: queueTag, value: label)
    }

    deinit {
        queue.setSpecific(key: queueTag, value: nil)
    }

    // MARK: - Operations

    @discardableResult
    public func sync<ReturnType>(_ work: ThrowingReturningClosure<ReturnType>) rethrows -> ReturnType {
        if isRecursive {
            return try work()
        } else {
            return try queue.sync(execute: work)
        }
    }

    public func async(_ work: @escaping VoidClosure) {
        queue.async(execute: work)
    }

    public func asyncIfNeeded(_ work: @escaping VoidClosure) {
        if isRecursive {
            work()
        } else {
            queue.async(execute: work)
        }
    }

    public func suspend() {
        suspendCount += 1
        queue.suspend()
    }

    public func resume() {
        suspendCount -= 1
        queue.resume()
    }

    public func resumeIfSuspended() {
        guard suspendCount > 0 else { return }
        resume()
    }

    // MARK: - Private

    private var isRecursive: Bool {
        return DispatchQueue.getSpecific(key: queueTag) == queue.label
    }

}
