//
//  CompactMap.swift
//  Reflex
//
//  Created by Nate Kim on 07/06/2018.
//  Copyright © 2018 reflex. All rights reserved.
//

import RxSwift

extension ObservableType {
    
    func compactMap<T>(_ transform: @escaping (E) -> T?) -> Observable<T> {
        return Observable.create { observer in
            return self.subscribe { event in
                switch event {
                case .next(let element):
                    if let e = transform(element) {
                        observer.onNext(e)
                    }
                case .completed: observer.onCompleted()
                case .error(let error): observer.onError(error)
                }
            }
        }
    }
}
