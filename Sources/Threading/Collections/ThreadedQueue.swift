//
//  ThreadedQueue.swift
//  Threading
//
//  Created by Jeremy Schwartz on 2018-06-17.
//

import Foundation

public class ThreadedQueue<T> : ThreadedObject<LinkedQueue<T>> {
    
    public typealias InternalCollectionType = LinkedQueue<T>
    public typealias Element = InternalCollectionType.Element
    
    /// Initailizes with a given threading type from an existing queue.
    ///
    /// - parameters:
    ///     - queue: An existing queue to copy elements from.
    ///
    ///     - type: The threading type which defines ho this queue should act.
    public override init(_ queue: LinkedQueue<T>, type: ThreadingType) {
        super.init(queue, type: type)
    }
    
    /// Initializes as a blank queue and concurrent type.
    public convenience init() {
        self.init(LinkedQueue<T>(), type: .concurrent)
    }
    
    /// Initializes from an existing queue with concurrent type.
    ///
    /// - parameters:
    ///     - queue: An existing queue to copy elements from.
    public convenience init(_ queue: LinkedQueue<T>) {
        self.init(queue, type: .concurrent)
    }
    
}

// MARK: - Computed Properties

public extension ThreadedQueue {
    
    /// Number of elements in the queue.
    public var count: Int {
        return sync { queue in
            return queue.count
        }
    }
    
    /// Returns `true` if there are no elements in the queue, `false` otherwise.
    public var isEmpty: Bool {
        return sync { queue in
            return queue.isEmpty
        }
    }
    
    /// First element of the queue if any.
    public var front: Element? {
        return sync { queue in
            return queue.front
        }
    }
    
    /// Last element ofthe queue if any.
    public var back: Element? {
        return sync { queue in
            return queue.back
        }
    }
    
}

// MARK: - Mutating Methods

public extension ThreadedQueue {
    
    /// Adds an item to the end of the queue.
    ///
    /// - parameters:
    ///     - newElement: The element to add to the queue.
    ///
    /// - complexity: _O(1)_
    func enqueue(_ newElement: Element) {
        async { queue in
            queue.enqueue(newElement)
        }
    }
    
    /// Removes and returns the first element of the queue.
    ///
    /// - complexity: _O(1)_
    ///
    /// - warning: Do not call this method on an empty queue; method will throw
    ///     a fatal error. If multiple threads are removing items at the same
    ///     time, use of `safeDequeue` is recommended.
    @discardableResult
    func dequeue() -> Element {
        return mutatingSync { queue in
            return queue.dequeue()
        }
    }
    
    /// Removes and returns the first element of the queue if the queue is not
    /// empty; otherwise, `nil` is returned.
    ///
    /// This is a safer version of `dequeue` and should be used instead of it
    /// when multiple threads are removing items from the queue.
    ///
    /// - complexity: _O(1)_
    @discardableResult
    func safeDequeue() -> Element? {
        return mutatingSync { queue in
            if !queue.isEmpty {
                return queue.dequeue()
            } else {
                return nil
            }
        }
    }
    
}

// MARK: - Non-mutating methods

public extension ThreadedQueue {
    
    /// Performs an action for each element in the queue.
    ///
    /// - parameters:
    ///     - callback: The function to call on every element.
    ///
    /// - complexity: _O(n * x)_ where n is the size of the queue and x is the
    ///     complexity of `callback`
    func forEach(_ callback: @escaping (Element) -> Void) {
        return sync { queue in
            queue.forEach(callback)
        }
    }
    
    /// Returns an array whose elements are the result of a transformation done
    /// to each element of the queue.
    ///
    /// - parameters:
    ///     - transform: A function called on each element in the queue to
    ///         change the element into the desired type.
    func map<U>(_ transform: @escaping (Element) -> U) -> [U] {
        return sync { queue in
            return queue.map(transform)
        }
    }
    
}

// MARK: - Threaded Collection Conformance

extension ThreadedQueue : ThreadedCollection {
    
    /// Returns the underlying object.
    public var unthreaded: InternalCollectionType {
        return sync { queue in
            return queue
        }
    }
    
}
