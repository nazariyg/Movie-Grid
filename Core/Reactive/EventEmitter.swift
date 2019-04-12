// Copyright © 2018 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import ReactiveSwift
import Result
import ReactiveCocoa

/// It's sufficient for conforming classes to contain a nested `Event` type, without the need of typealiasing. Events can be listened on
/// through `eventSignal` property and emitted through `eventEmitter` property.
public protocol EventEmitter: StoredProperties {
    associatedtype Event
}

private struct StoredPropertyKeys {
    static let eventEmitterIsInitialized = "eventEmitterIsInitialized"
    static let eventSignal = "eventSignal"
    static let eventEmitter = "eventEmitter"
}

public extension EventEmitter {

    var eventSignal: Signal<Event, NoError> {
        let (signal, _) = initializeOrGetPipe()
        return signal
    }

    var eventEmitter: Signal<Event, NoError>.Observer {
        let (_, emitter) = initializeOrGetPipe()
        return emitter
    }

    private func initializeOrGetPipe() -> (signal: Signal<Event, NoError>, emitter: Signal<Event, NoError>.Observer) {
        return synchronized(self) {
            if let isInitialized = sp.bool[StoredPropertyKeys.eventEmitterIsInitialized], isInitialized {
                let signal = sp.any[StoredPropertyKeys.eventSignal] as! Signal<Event, NoError>
                let emitter = sp.any[StoredPropertyKeys.eventEmitter] as! Signal<Event, NoError>.Observer
                return (signal, emitter)
            } else {
                let (newSignal, newEmitter) = Signal<Event, NoError>.pipe()
                sp.any[StoredPropertyKeys.eventSignal] = newSignal
                sp.any[StoredPropertyKeys.eventEmitter] = newEmitter
                sp.bool[StoredPropertyKeys.eventEmitterIsInitialized] = true
                return (newSignal, newEmitter)
            }
        }
    }

}
