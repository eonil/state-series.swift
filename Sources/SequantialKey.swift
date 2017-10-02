//
//  SequentialKey.swift
//  EonilStateSeries
//
//  Created by Hoon H. on 2017/10/02.
//
//

///
/// A serial key.
///
/// Never diverge.
///
/// If you have an oldest key in series,
/// all the keys to newest one will be alive
/// even your program does not keep a strong
/// reference to intermediate objects.
/// Therefore, once established key series
/// won't be broken into multiple parts.
///
/// Due to its management style, you must be
/// sure to remove all strong reference to
/// unnecessary old keys.
///
/// For now, this is available only on main
/// thread.
///
final class SequentialKey: Comparable {
    fileprivate(set) var order: UInt64
    private let series: SequentialKeySeries
    private(set) weak var prev: SequentialKey?
    private(set) var next: SequentialKey?

    static func first(_ params: SequentialKeyParameters) -> SequentialKey {
        assertMainThread()
        let s = SequentialKeySeries()
        let k = SequentialKey(order: 1, in: s)
        s.params = params
        s.first = k
        s.last = k
        s.length = 1
        return k
    }
    private init(order: UInt64, in series: SequentialKeySeries) {
        assertMainThread()
        self.order = order
        self.series = series
    }
    deinit {
        assertMainThread()
        assert(series.length > 0)
        series.first = next
        series.length -= 1
        next?.prev = nil
        if series.length > 0 && isKnownUniquelyReferenced(&next) == false {
            series.compactOrderNumberSpaceIfNeeded()
        }
    }
    var parameters: SequentialKeyParameters {
        return series.params
    }
    var length: Int {
        return series.length
    }
    func continuation() -> SequentialKey {
        assertMainThread()
        precondition(series.length < series.params.maxInstanceCount, "Too many sequential ID instances are alive.")
        let n = next ?? SequentialKey(order: order + 1, in: series)
        n.prev = self
        next = n
        series.last = n
        series.length += 1
        return n
    }
    static func == (_ a: SequentialKey, _ b: SequentialKey) -> Bool {
        assertMainThread()
        return a === b
    }
    static func < (_ a: SequentialKey, _ b: SequentialKey) -> Bool {
        assertMainThread()
        return a.order < b.order
    }
}

struct SequentialKeyParameters {
    var maxInstanceCount = Int.max
    var maxUnavailableOrderNumberCount = 0
}

final class SequentialKeySeries {
    var params = SequentialKeyParameters()
    weak var first: SequentialKey?
    weak var last: SequentialKey?
    var length: Int = 0
    deinit {
        assertMainThread()
        assert(length == 0)
    }
    func compactOrderNumberSpaceIfNeeded() {
        assertMainThread()
        assert(length > 0)
        assert(first != nil)
        guard let k = first else { return }
        guard k.order > params.maxUnavailableOrderNumberCount else { return }
        compactOrderNumberSpace()
    }
    func compactOrderNumberSpace() {
        assertMainThread()
        assert(first != nil)
        var i = UInt64(0)
        var k = first
        while let k1 = k {
            i += 1
            k1.order = i
            k = k1.next
        }
    }
}
