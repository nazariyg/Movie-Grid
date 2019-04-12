// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import ReactiveSwift
import Result
import ReactiveCocoa

/// It's sufficient for conforming classes to contain a nested `Request` type, without the need of typealiasing. Requests can be listened on
/// through `requestSignal` property and emitted through `requestEmitter` property.
public protocol RequestEmitter: StoredProperties {
    associatedtype Request
}

private struct StoredPropertyKeys {
    static let requestEmitterIsInitialized = "requestEmitterIsInitialized"
    static let requestSignal = "requestSignal"
    static let requestEmitter = "requestEmitter"
}

public extension RequestEmitter {

    var requestSignal: Signal<Request, NoError> {
        let (signal, _) = initializeOrGetPipe()
        return signal
    }

    var requestEmitter: Signal<Request, NoError>.Observer {
        let (_, emitter) = initializeOrGetPipe()
        return emitter
    }

    private func initializeOrGetPipe() -> (signal: Signal<Request, NoError>, emitter: Signal<Request, NoError>.Observer) {
        return synchronized(self) {
            if let isInitialized = sp.bool[StoredPropertyKeys.requestEmitterIsInitialized], isInitialized {
                let signal = sp.any[StoredPropertyKeys.requestSignal] as! Signal<Request, NoError>
                let emitter = sp.any[StoredPropertyKeys.requestEmitter] as! Signal<Request, NoError>.Observer
                return (signal, emitter)
            } else {
                let (newSignal, newEmitter) = Signal<Request, NoError>.pipe()
                sp.any[StoredPropertyKeys.requestSignal] = newSignal
                sp.any[StoredPropertyKeys.requestEmitter] = newEmitter
                sp.bool[StoredPropertyKeys.requestEmitterIsInitialized] = true
                return (newSignal, newEmitter)
            }
        }
    }

}
