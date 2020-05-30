//
//  RawFloatArray.h
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

#import <Foundation/Foundation.h>

/// A float c array wrapper for fast calculations.
@interface RawFloatArray: NSObject

/// C array. Unsafe pointer in swift.
@property (nonatomic, readonly) const float* floats;

/// Array length. In number of floats.
@property (nonatomic, readonly) int count;

/// Init with C array and lengh in number of floats.
- (instancetype)initWithCArray: (const float*)floats count: (int)count;

/// Index access.
- (float)objectAtIndexedSubscript: (NSUInteger)index;

@end

@interface RawIntArray: NSObject

/// C array. Unsafe pointer in swift.
@property (nonatomic, readonly) const int* ints;

/// Array length. In number of ints.
@property (nonatomic, readonly) int count;

/// Init with C array and lengh in number of ints.
- (instancetype)initWithCArray: (const int*)ints count: (int)count;

/// Index access.
- (int)objectAtIndexedSubscript: (NSUInteger)index;

@end

@interface RawUShortArray: NSObject

/// C array. Unsafe pointer in swift.
@property (nonatomic, readonly) const unsigned short* ushorts;

/// Array length. In number of ushorts.
@property (nonatomic, readonly) int count;

/// Init with C array and lengh in number of ushorts.
- (instancetype)initWithCArray: (const unsigned short*)ushorts count: (int)count;

/// Index access.
- (unsigned short)objectAtIndexedSubscript: (NSUInteger)index;

@end
