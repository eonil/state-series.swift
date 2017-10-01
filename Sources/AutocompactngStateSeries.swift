//
//  AutocompactngStateSeries.swift
//  EonilStateSeries
//
//  Created by Hoon H. on 2017/10/02.
//
//

public struct AutocompactingStateSeries<Snapshot>: StateSeriesType {
    private let maxUnavailableKeyCount: Int
    private var mcs = StateSeries<Snapshot>()

    public typealias Version = StateSeries<Snapshot>.Version
    public typealias PointCollection = StateSeries<Snapshot>.PointCollection
    public typealias PointID = StateSeries<Snapshot>.PointID

    ///
    /// - Parameter maxUnavailableKeyCount:
    ///     Hard limit of wasted key count.
    ///     If wasted key count becomes larger than this number,
    ///     this will compact every time you call `removeFirst`.
    ///     Please note that this is not the only condition to trigger
    ///     compaction. Compaction also can be triggered by another conditions.
    ///
    public init(maxUnavailableKeyCount c: Int = 1024 * 1024) {
        maxUnavailableKeyCount = c
    }
    public var version: Version {
        return mcs.version
    }
    public var points: PointCollection {
        return mcs.points
    }
    public mutating func append(_ state: Snapshot) {
        mcs.append(state)
    }
    ///
    /// Remove and compact point key space if needed.
    ///
    public mutating func removeFirst(_ n: Int) {
        mcs.removeFirst(n)
        if needsCompacting {
            mcs.compact()
        }
    }
    private var needsCompacting: Bool {
        if (mcs.points.count * 2) / mcs.baseIndex > 0 { return true }
        if mcs.baseIndex > maxUnavailableKeyCount { return true }
        return false
    }
}
