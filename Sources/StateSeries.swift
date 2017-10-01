//
//  StateSeries.swift
//  EonilStateSeries
//
//  Created by Hoon H. on 2017/10/01.
//
//

///
/// A series of states.
///
/// This is analogue of time-series data.
/// State-series is built with multiple state-points.
/// Each point has unique ID, and provide equality test and order comparison.
///
public struct StateSeries<Snapshot>: StateSeriesType, CustomDebugStringConvertible {
    public typealias Point = (id: PointID, state: Snapshot)
    private var ssimpl = SSImpl<Snapshot>()

    public init() {
    }
    ///
    /// Provides a tool to perform content equality test quicky (O(1)).
    ///
    /// If two different versions are equal, content of two series are
    /// guaranteed to be equal. Inequality cannot be tested due to
    /// implementation details.
    ///
    public var version: Version {
        return Version(selfRef: ssimpl)
    }
    public var points: PointCollection {
        return PointCollection(ssimpl: ssimpl)
    }
    public mutating func append(_ state: Snapshot) {
        cloneImplIfNeeded()
        ssimpl.appendPoint(state)
    }
    public mutating func append<S>(contentsOf states: S) where S: Sequence, S.Element == Snapshot {
        states.forEach({ append($0) })
    }
    public mutating func removeFirst() {
        removeFirst(1)
    }
    public mutating func removeFirst(_ n: Int) {
        ssimpl.removeFirstPoints(n)
    }

    internal var baseIndex: Int {
        return ssimpl.baseIndex
    }

    ///
    /// Always O(n)
    ///
    public mutating func compact() {
        cloneImplIfNeeded()
        ssimpl.compactKeySpace()
    }
    private mutating func cloneImplIfNeeded() {
        if isKnownUniquelyReferenced(&ssimpl) == false {
            ssimpl = ssimpl.clone()
        }
    }
    public var debugDescription: String {
        return ssimpl.debugDescription
    }
}
public extension StateSeries {
    ///
    /// Identity of a state-series.
    ///
    /// If two `StateSeries.Version`s are equal, they are equal, which means the
    /// two `StateSeries` for the Versions contain completely same dataset. It
    /// is guaranteed.
    ///
    /// You CANNOT perform inequality test on two `StateSeries.Version`s.
    /// Due to nature of weak-reference, there's no good way to perform
    /// inequality test referentially transparently. (result can be vary at
    /// the point of query) Result is same with `ObjectIdentifier` because
    /// the derived value is just another form of same value
    /// (object pointer address).
    ///
    public struct Version: Equatable, CustomDebugStringConvertible {
        fileprivate weak var selfRef: SSImpl<Snapshot>?
        public static func == (_ a: Version, _ b: Version) -> Bool {
            guard let a1 = a.selfRef else { return false }
            guard let b1 = b.selfRef else { return false }
            return a1 === b1
        }
        @available(*, unavailable, message: "Inequality test cannot be defined betweem two `PointID`s. See implementation of `PImpl` class for details.")
        public static func != (_ a: Version, _ b: Version) -> Bool {
            fatalError("Inequality test cannot be defined betweem two `PointID`s. See implementation of `PImpl` class for details.")
        }
        public var debugDescription: String {
            guard let selfRef = selfRef else { return "(Version: nil)" }
            let ssoid = ObjectIdentifier(selfRef).makeAddress()
            return "(Version: \(ssoid))"
        }
    }
    ///
    /// Defines relative unique order in a series.
    ///
    /// A `PointID` is an opaque value. Its representation has been hidden
    /// intentionally. You can know only equality and relative order of two
    /// `PointID`s.
    ///
    public struct PointID: Comparable, CustomDebugStringConvertible {
        fileprivate let pimpl: PImpl<Snapshot>
        public static func == (_ a: PointID, _ b: PointID) -> Bool {
            return a.pimpl == b.pimpl
        }
        public static func < (_ a: PointID, _ b: PointID) -> Bool {
            return a.pimpl < b.pimpl
        }
        public var debugDescription: String {
            return pimpl.debugDescription
        }
    }
    public struct PointCollection: RandomAccessCollection, CustomDebugStringConvertible {
        fileprivate let ssimpl: SSImpl<Snapshot>
        public typealias Element = (id: PointID, state: Snapshot)
        public typealias SubSequence = PointCollection
        public typealias Index = Int
        public var startIndex: Int { return ssimpl.points.startIndex }
        public var endIndex: Int { return ssimpl.points.endIndex }
        public subscript(position: Int) -> Element {
            let pimpl = ssimpl.points[position]
            let pid = PointID(pimpl: pimpl)
            let ps = pimpl.state
            return (pid, ps)
        }
        public func index(before i: Index) -> Index { return ssimpl.points.index(before: i) }
        public var debugDescription: String {
            let c = map({ "\t(id: \($0.id.debugDescription), state: \($0.state))," }).joined(separator: "\n")
            return "[\n\(c)\n]"
        }
    }
}
