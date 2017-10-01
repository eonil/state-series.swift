//
//  ObjectIdentifier.extension.swift
//  EonilStateSeries
//
//  Created by Hoon H. on 2017/10/01.
//
//

import Foundation

extension ObjectIdentifier {
    func makeAddress() -> String {
        let n = UInt(bitPattern: self)
        return "0x" + String(n, radix: 16, uppercase: false)
    }
}
