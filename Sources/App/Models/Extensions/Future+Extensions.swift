//
//  Future+Extensions.swift
//  
//
//  Created by Jing Wei Li on 2/14/21.
//

import Foundation
import Vapor
import Fluent

/// Wait for 2 different futures to fulfill
func zip2<T1, T2>(
    _ future1: EventLoopFuture<T1>,
    _ future2: EventLoopFuture<T2>
) -> EventLoopFuture<(T1, T2)> {
    future1.and(future2)
}

/// Wait for 3 different futures to fulfill
func zip3<T1, T2, T3>(
    _ future1: EventLoopFuture<T1>,
    _ future2: EventLoopFuture<T2>,
    _ future3: EventLoopFuture<T3>
) -> EventLoopFuture<(T1, T2, T3)> {
    zip2(future1, future2)
        .and(future3)
        .map { first2, third -> (T1,T2,T3) in
            (first2.0, first2.1, third)
        }
}
