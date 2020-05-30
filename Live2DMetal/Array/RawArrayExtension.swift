//
//  RawArrayExtension.swift
//  Live2DMetal
//
//  Copyright (c) 2020-2020 Ian Wang
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

/// Convert array from unsafe pointer to swift array.
public func ArrayFromPointer<T>(_ pointer: UnsafePointer<T>?, count: Int) -> [T]? {
    guard let pointer = pointer else {
        return nil
    }
    
    return Array(UnsafeBufferPointer(start: pointer, count: count))
}

extension RawIntArray {
    /// Convert C array into swift `Int32` array.
    public func intArray() -> [Int32] {
        return ArrayFromPointer(self.ints, count: Int(self.count)) ?? []
    }
}

extension RawFloatArray {
    /// Convert C array into swift `Float` array.
    public func intArray() -> [Float] {
        return ArrayFromPointer(self.floats, count: Int(self.count)) ?? []
    }
}

extension RawUShortArray {
    /// Convert C array into swift `UInt16` array.
    public func ushortArray() -> [UInt16] {
        return ArrayFromPointer(self.ushorts, count: Int(self.count)) ?? []
    }
}
