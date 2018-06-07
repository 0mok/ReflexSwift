//
//  ActorType.swift
//  Reflex
//
//  Created by Nate Kim on 17/05/2018.
//  Copyright © 2018 reflex. All rights reserved.
//

import RxSwift

public protocol ActorType: ObserverType where E == Action {
    associatedtype Action
    func onDispatch(_ action: Action)
}

extension ActorType {
    private func on(_ event: Event<Action>) {
        if case .next(let action) = event {
            onDispatch(action)
        }
    }
}

private var listenerQueueContext: UInt8 = 0
private var disposeBagContext: UInt8 = 0
extension ActorType {
    public var disposeBag: DisposeBag {
        if let subject = objc_getAssociatedObject(self, &disposeBagContext) as? DisposeBag {
            return subject
        }
        let newSubject = DisposeBag()
        objc_setAssociatedObject(self, &disposeBagContext, newSubject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return newSubject
    }
    
    public var listenerQueue: DispatchQueue {
        get {
            if let subject = objc_getAssociatedObject(self, &listenerQueueContext) as? DispatchQueue {
                return subject
            }
            let newSubject = DispatchQueue.main
            objc_setAssociatedObject(self, &listenerQueueContext, newSubject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newSubject
        }
        set {
            objc_setAssociatedObject(self, &listenerQueueContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
