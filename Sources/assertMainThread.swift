//
//  assertMainThread.swift
//  EonilStateSeries
//
//  Created by Hoon H. on 2017/10/02.
//
//

import Foundation

func assertMainThread() {
    assert(Thread.isMainThread)
}
