//
//  StateSeriesType.swift
//  EonilStateSeries
//
//  Created by Hoon H. on 2017/10/02.
//
//

public protocol StateSeriesType {
    associatedtype Version: Equatable
    associatedtype PointID: Comparable
    associatedtype Snapshot
    associatedtype PointCollection: RandomAccessCollection

    typealias Point = (id: PointID, state: Snapshot)

    ///
    /// Provides a tool to perform content equality test quicky (O(1)).
    ///
    /// If two different versions are equal, content of two series are
    /// guaranteed to be equal. Inequality cannot be tested due to
    /// implementation details.
    ///
    var version: Version { get }
    var points: PointCollection { get }

    mutating func append(_ state: Snapshot)
    mutating func removeFirst(_ n: Int)
}
public extension StateSeriesType {
    public mutating func append<S>(contentsOf states: S) where S: Sequence, S.Element == Snapshot {
        states.forEach({ append($0) })
    }
    public mutating func removeFirst() {
        removeFirst(1)
    }
}
//struct StateSeriesStatistics {
//    var unavailableKeyCount: Int
//    var usingKeyCount: Int
//    var availableKeyCount: Int
//}

