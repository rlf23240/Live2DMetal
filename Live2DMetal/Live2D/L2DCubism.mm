//
//  L2DCubism.m
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

#import "CubismFramework.hpp"

#import "L2DCubism.h"

using namespace Csm;

/// Cubism allocator.
class Allocator: public ICubismAllocator {
    void* Allocate(const csmSizeType size) {
        return malloc(size);
    }
    
    void Deallocate(void* memory) {
        free(memory);
    }
    
    void* AllocateAligned(const csmSizeType size, const csmUint32 alignment) {
        size_t offset, shift, alignedAddress;
        void* allocation;
        void** preamble;

        offset = alignment - 1 + sizeof(void*);

        allocation = Allocate(size + static_cast<csmUint32>(offset));

        alignedAddress = reinterpret_cast<size_t>(allocation) + sizeof(void*);

        shift = alignedAddress % alignment;

        if (shift) {
            alignedAddress += (alignment - shift);
        }

        preamble = reinterpret_cast<void**>(alignedAddress);
        preamble[-1] = allocation;

        return reinterpret_cast<void*>(alignedAddress);
    }
    
    void DeallocateAligned(void* alignedMemory) {
        void** preamble;

        preamble = static_cast<void**>(alignedMemory);

        Deallocate(preamble[-1]);
    }
};

static Allocator allocator;

@implementation L2DCubism

+ (void)initialize {
    CubismFramework::StartUp(&allocator, NULL);
    CubismFramework::Initialize();
}

+ (void)dispose {
    CubismFramework::Dispose();
}

@end
