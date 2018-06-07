//
//  DispatchSubject.swift
//  Reflex
//
//  Created by Nate Kim on 21/05/2018.
//  Copyright © 2018 reflex. All rights reserved.
//

import RxSwift

final class DispatchSubject<Element>
    : ObservableType
    , SubjectType
    , ObserverType
    , Disposable {
    typealias E = Element
    typealias SubjectObserverType = DispatchSubject<Element>
    
    private let subject = PublishSubject<Element>()
    private let _lock = NSRecursiveLock()
    private var _queue = [Element]()
    
    func dispose() {
        subject.dispose()
        _lock.lock()
        _queue.removeAll()
        _lock.unlock()
    }
    
    func subscribe<O>(_ observer: O) -> Disposable where O : ObserverType, DispatchSubject.E == O.E {
        _lock.lock()
        defer { _lock.unlock() }
        for item in _queue {
            observer.on(.next(item))
        }
        _queue.removeAll()
        return subject.subscribe(observer)
    }
    
    func asObserver() -> DispatchSubject<Element> {
        return self
    }
    
    func on(_ event: Event<Element>) {
        _lock.lock()
        defer { _lock.unlock() }
        if subject.hasObservers {
            subject.on(event)
        } else {
            if case .next(let element) = event {
                _queue.append(element)
            }
        }
    }
}
