//
//  DispatcherType.swift
//  Reflex
//
//  Created by Nate Kim on 25/01/2018.
//  Copyright © 2018 reflex. All rights reserved.
//

import RxSwift

public enum Dispatch<Action> {
    init(_ action: Action) {
        self = .dispatch(action)
    }
    case dispatch(Action)
    case void
}

public protocol DispatcherType: ObserverType where Self : AnyObject {
    associatedtype Action
    
    var disposeBag: DisposeBag { get }
    func dispatch(from event: E) -> Observable<Dispatch<Action>>
}

private var eventPublisherContext: UInt8 = 0
private var dispatchPublisherContext: UInt8 = 0
extension DispatcherType {
    public func on(_ event: Event<E>) {
        _eventPublisher.on(event)
    }
    
    public func actor<O: ObservableType>(_ actionObservable: O) where O.E == Dispatch<Action> {
        actionObservable
            .compactMap{ (dispatch) -> Action? in
                if case .dispatch(let u) = dispatch {
                    return u
                }
                return nil
            }
            .subscribe(_dispatchPublisher)
            .disposed(by: disposeBag)
    }
    
    public func dispatch(_ action: Action) {
        self._dispatchPublisher.onNext(action)
    }
    
    public func bind<Actor: ActorType>(_ actor: Actor) -> (Self, Actor) where Actor.Action == Action {
        _dispatchPublisher.asObservable()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: actor.listenerQueue))
            .subscribe(actor)
            .disposed(by: actor.disposeBag)
        return (self, actor)
    }
    
    private var _eventPublisher: PublishSubject<E> {
        if let subject = objc_getAssociatedObject(self, &eventPublisherContext) as? PublishSubject<E> {
            return subject
        }
        let newSubject = PublishSubject<E>()
        objc_setAssociatedObject(self, &eventPublisherContext, newSubject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        bindEventToDispatchIfNeeded()
        return newSubject
    }
    
    private var _dispatchPublisher: DispatchSubject<Action> {
        if let subject = objc_getAssociatedObject(self, &dispatchPublisherContext) as? DispatchSubject<Action> {
            return subject
        }
        let newSubject = DispatchSubject<Action>()
        objc_setAssociatedObject(self, &dispatchPublisherContext, newSubject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        bindEventToDispatchIfNeeded()
        return newSubject
    }
    
    private func bindEventToDispatchIfNeeded() {
        if (objc_getAssociatedObject(self, &dispatchPublisherContext) != nil &&
            objc_getAssociatedObject(self, &eventPublisherContext) != nil ) {
            // Do nothing unless there is a dispatch publisher and an event publisher.
            return
        }
        _eventPublisher.asObservable()
            .flatMap { (e) -> Observable<Dispatch<Action>> in
                return self.dispatch(from: e)
            }
            .compactMap{ (dispatch) -> Action? in
                if case .dispatch(let u) = dispatch {
                    return u
                }
                return nil
            }
            .observeOn(MainScheduler.instance)
            .subscribe(_dispatchPublisher)
            .disposed(by: disposeBag)
    }
}
