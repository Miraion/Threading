//
//  LinkedQueue.swift
//  Threading
//
//  Created by Jeremy Schwartz on 2018-06-23.
//

import Foundation

/// Linked list implementation of a first-in first-out queue. Insertion and
/// extraction operators are O(1). This collection does not provide random
/// access to its elements.
public struct LinkedQueue<T> {
    
    public typealias Element = T
    
    /// Linked list node class.
    internal class LinkedNode {
        internal var element: Element
        internal var next: LinkedNode?
        
        init(_ element: Element, _ next: LinkedNode? = nil) {
            self.element = element
            self.next = next
        }
    }
    
    fileprivate var root: LinkedNode? = nil
    fileprivate var tail: LinkedNode? = nil
    
    /// Number of elements in the queue.
    public fileprivate(set) var count: Int = 0
    
}

// MARK: Computed Properties

public extension LinkedQueue {
    
    /// First element of the queue if any.
    public var front: Element? {
        return root?.element
    }
    
    /// Last element ofthe queue if any.
    public var back: Element? {
        return tail?.element
    }
    
    /// Returns `true` if there are no elements in the queue, `false` otherwise.
    public var isEmpty: Bool {
        return count == 0
    }
    
}

// MARK: Mutating Methods

public extension LinkedQueue {
    
    /// Adds an item to the end of the queue.
    ///
    /// - parameters:
    ///     - newElement: The element to add to the queue.
    ///
    /// - complexity: _O(1)_
    public mutating func enqueue(_ newElement: Element) {
        if let t = tail {
            t.next = LinkedNode(newElement)
            tail = t.next
        } else {
            root = LinkedNode(newElement)
            tail = root
        }
        count += 1
    }
    
    /// Removes and returns the first element of the queue.
    ///
    /// - complexity: _O(1)_
    ///
    /// - warning: Do not call this method on an empty queue; method will throw
    ///     a fatal error.
    @discardableResult
    public mutating func dequeue() -> Element {
        if root == nil {
            fatalError("dequeue called on empty queue")
        }
        let element = root!.element
        root = root?.next
        count -= 1
        return element
    }
    
}

// MARK: Non-mutating Methods

public extension LinkedQueue {
    
    /// Performs an action for each element in the queue.
    ///
    /// - parameters:
    ///     - callback: The function to call on every element.
    ///
    /// - complexity: _O(n * x)_ where n is the size of the queue and x is the
    ///     complexity of `callback`
    public func forEach
        (_ callback: @escaping (Element) throws -> Void) rethrows
    {
        var node = root
        while node != nil {
            try callback(node!.element)
            node = node!.next
        }
    }
    
    /// Returns an array whose elements are the result of a transformation done
    /// to each element of the queue.
    ///
    /// - parameters:
    ///     - transform: A function called on each element in the queue to
    ///         change the element into the desired type.
    func map<U>(_ transform: @escaping (Element) throws -> U) rethrows -> [U] {
        var result = [U]()
        try forEach { element in
            result.append(try transform(element))
        }
        return result
    }
    
}
