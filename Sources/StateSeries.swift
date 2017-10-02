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
/// Each point has ordered unique ID which provide equality test and
/// order comparison.
///
/// Equalty of Point ID
/// -------------------
/// Point ID represents relative distance and order between two points.
/// Also point ID is pure value semantic. If you copy a state-series, and
/// append one new state, their point IDs are equal because they have
/// same relative distance from previous point.
/// Please take care that point ID keeps all instances alive between the
/// oldest one to the newest one in the chain. You should erase all
/// unnecessary old point IDs as soon as possible to save memory.
///
public struct StateSeries<Snapshot>: StateSeriesType, CustomDebugStringConvertible {
    fileprivate typealias RawPoint = (id: SequentialKey, state: Snapshot)
    private var rawPoints = [RawPoint]()
    private var rawPointIDSeed: SequentialKey

    public static var defaultMaxUnavailableKeySpaceCount: Int { return 1024 * 1024 }
    public typealias Point = (id: PointID, state: Snapshot)

    ///
    /// - Parameter capacity:
    ///     Hard limit of total number of points.
    ///
    public init(capacity: Int = .max) {
        let ps = SequentialKeyParameters(
            maxInstanceCount: capacity,
            maxUnavailableOrderNumberCount: StateSeries.defaultMaxUnavailableKeySpaceCount)
        rawPointIDSeed = SequentialKey.first(ps)
    }
    public var points: PointCollection {
        return PointCollection(rawPoints)
    }
    public mutating func append(_ state: Snapshot) {
        precondition(points.count < rawPointIDSeed.parameters.maxInstanceCount, "Exceeds hard capacity limit.")
        if rawPointIDSeed.length > rawPoints.count + 128 { StateSeriesWatchDog.cast(.tooManyDeadPointIDInstancesAreAlive) }
        let p = (rawPointIDSeed, state)
        rawPoints.append(p)
        rawPointIDSeed = rawPointIDSeed.continuation()
    }
    public mutating func append<S>(contentsOf states: S) where S: Sequence, S.Element == Snapshot {
        states.forEach({ append($0) })
    }
    public mutating func removeFirst() {
        rawPoints.removeFirst()
    }
    public mutating func removeFirst(_ n: Int) {
        rawPoints.removeFirst(n)
    }
    public var debugDescription: String {
        let c = points.map({ "\t(id: \($0.id.debugDescription), state: \($0.state))," }).joined(separator: "\n")
        return "StateSeries(points: [\n\(c)\n])"
    }
}
public extension StateSeries {
    public struct PointID: Comparable, CustomDebugStringConvertible {
        let rawKey: SequentialKey
        fileprivate init(_ raw: SequentialKey) {
            rawKey = raw
        }
        public static func == (_ a: PointID, _ b: PointID) -> Bool {
            return a.rawKey == b.rawKey
        }
        public static func < (_ a: PointID, _ b: PointID) -> Bool {
            return a.rawKey < b.rawKey
        }
        public var debugDescription: String {
            let a = ObjectIdentifier(rawKey).makeAddress()
            return "PointID(identity: \(a), order: \(rawKey.order))"
        }
    }
    public struct PointCollection: RandomAccessCollection {
        private let rawPoints: [RawPoint]
        fileprivate init(_ ps: [RawPoint]) {
            rawPoints = ps
        }
        public typealias Index = Int
        public var startIndex: Index { return rawPoints.startIndex }
        public var endIndex: Int { return rawPoints.endIndex }
        public subscript(position: Int) -> Point {
            let raw = rawPoints[position]
            let pid = PointID(raw.id)
            let ps = raw.state
            return (pid, ps)
        }
    }
}
extension StateSeries: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Snapshot...) {
        self = StateSeries()
        append(contentsOf: elements)
    }
}
