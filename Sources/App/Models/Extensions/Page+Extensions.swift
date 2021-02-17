//
//  Page+Extensions.swift
//  
//
//  Created by Jing Wei Li on 2/16/21.
//

import Foundation
import Fluent

extension Page {
    static var empty: Page {
        Page(items: [], metadata: PageMetadata(page: 0, per: 0, total: 0))
    }
}

func addPages<T>(lhs: Page<T>, rhs: Page<T>) -> Page<T> {
    return Page(
        items: lhs.items + rhs.items,
        metadata: PageMetadata(
            page: lhs.metadata.page,
            per: lhs.metadata.per + rhs.metadata.per,
            total: lhs.metadata.total + rhs.metadata.total
        )
    )
}
