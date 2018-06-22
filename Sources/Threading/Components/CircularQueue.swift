//
//  CircularQueue.swift
//  Threading
//
//  Created by Jeremy Schwartz on 2018-06-17.
//

import Foundation

fileprivate let circularQueueDefaultCapacity = 16

public struct CircularQueue<T> {
    
    public typealias Element = T
    public typealias Index = Int
    
    fileprivate var buffer: UnsafeMutablePointer<T>
    
    public fileprivate(set) var capacity: Int
    
    public fileprivate(set) var count: Int = 0
    
    public var startIndex: Index = 0
    
    public var endIndex: Index = 0
    
    public init() {
        buffer = UnsafeMutablePointer<T>.allocate(
            capacity: circularQueueDefaultCapacity
        )
        capacity = circularQueueDefaultCapacity
    }
    
    public init(capacity: Int) {
        buffer = UnsafeMutablePointer<T>.allocate(capacity: capacity)
        self.capacity = capacity
    }
    
}


// MARK: - Computed Properties

public extension CircularQueue {
    
    var isEmpty: Bool {
        return count == 0
    }
    
}

// MARK: - Mutating Methods

public extension CircularQueue {
    
    /// Adds a new element to the end of the queue.
    mutating func push(_ newElement: Element) {
        if !isFull {
            buffer.advanced(by: endIndex).initialize(to: newElement)
            endIndex = index(after: endIndex)
            count += 1
        } else {
            // Create new buffer that is twice the size.
            let newBuffer = UnsafeMutablePointer<T>.allocate(
                capacity: capacity * 2
            )
            // Copy over elements.
            var i = startIndex
            var j = 0
            while index(after: i) != endIndex {
                newBuffer.advanced(by: j).initialize(
                    to: buffer.advanced(by: i).pointee
                )
                j += 1
                i = index(after: i)
            }
            startIndex = 0
            endIndex = j
            // Destroy old buffer.
            buffer.deinitialize(count: capacity)
            buffer.deallocate()
            capacity = capacity * 2
            buffer = newBuffer
            
            // Recusivly add new element.
            push(newElement)
        }
    }
    
    mutating func shrinkToFix() {
        
    }
    
}

// MARK: - Non-mutating Methods

public extension CircularQueue {

    func index(after i: Index) -> Index {
        return (i + 1) % capacity
    }
    
}

// MARK: - Private Helper Methods And Properties

fileprivate extension CircularQueue {
    
    /// Returns true if the queue is currently full.
    var isFull: Bool {
        return count == capacity
    }
    
    /// Returns true if `i` is a valid index.
    func checkBounds(_ i: Index) -> Bool {
        if endIndex >= startIndex {
            return i >= startIndex && i < endIndex
        } else {
            return (i >= startIndex && i < capacity) || (i < endIndex && i >= 0)
        }
    }
    
}
