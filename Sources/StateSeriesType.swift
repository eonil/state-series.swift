//
//  StateSeriesType.swift
//  EonilStateSeries
//
//  Created by Hoon H. on 2017/10/02.
//
//

///
/// Version is not required. Because ID of last point
/// is the version.
///
public protocol StateSeriesType {
    associatedtype PointID: Comparable
    associatedtype Snapshot
    associatedtype PointCollection: RandomAccessCollection

    typealias Point = (id: PointID, state: Snapshot)

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

