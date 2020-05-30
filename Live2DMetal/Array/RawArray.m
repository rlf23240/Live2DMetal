//
//  RawFloatArray.m
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

#import "RawArray.h"

// Float array.
@implementation RawFloatArray

- (instancetype)initWithCArray: (const float*)floats count: (int)count {
    if (self = [super init]) {
        _floats = floats;
        _count = count;
    }
    
    return self;
}

- (NSArray*)floatArray {
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < _count; ++i) {
        [array addObject: [NSNumber numberWithFloat: _floats[i]]];
    }
    
    return array;
}

- (float)objectAtIndexedSubscript: (NSUInteger)index {
    return _floats[index];
}

@end

// Int array.
@implementation RawIntArray

- (instancetype)initWithCArray: (const int*)ints count: (int)count {
    if (self = [super init]) {
        _ints = ints;
        _count = count;
    }
    
    return self;
}

- (NSArray*)intArray {
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < _count; ++i) {
        [array addObject: [NSNumber numberWithFloat: _ints[i]]];
    }
    
    return array;
}

- (int)objectAtIndexedSubscript: (NSUInteger)index {
    return _ints[index];
}

@end

// Unsigned short array.
@implementation RawUShortArray

- (instancetype)initWithCArray: (const unsigned short*)ushorts count: (int)count {
    if (self = [super init]) {
        _ushorts = ushorts;
        _count = count;
    }
    
    return self;
}

- (NSArray*)ushortArray {
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < _count; ++i) {
        [array addObject: [NSNumber numberWithUnsignedShort: _ushorts[i]]];
    }
    
    return array;
}

- (unsigned short)objectAtIndexedSubscript: (NSUInteger)index {
    return _ushorts[index];
}

@end
