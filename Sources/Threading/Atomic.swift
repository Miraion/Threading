//
//  Atomic.swift
//  Threading
//
//  Created by Jeremy Schwartz on 2018-06-16.
//

import Foundation

public class Atomic<Element> {
    
    fileprivate let queue: DispatchQueue
    
    fileprivate var value: Element
    
    fileprivate let threadingType: ThreadingType
    
    /// Initializes this atomic element from a normal element.
    ///
    /// - parameters:
    ///     - value: Value to store.
    ///
    ///     - type: The access type for this attomic element.
    public init(_ value: Element, type: ThreadingType) {
        self.value = value
        self.threadingType = type
        if type == .concurrent {
            self.queue = DispatchQueue(
                label: "com.threading.atomic.\(LabelDispatch.get())",
                attributes: .concurrent
            )
        } else {
            self.queue = DispatchQueue(
                label: "com.threading.atomic.\(LabelDispatch.get())"
            )
        }
    }
    
    /// Initializes this atomic element from a normal element using a concurrent
    /// threading type.
    ///
    /// - parameters:
    ///     - value: Value to store.
    public convenience init(_ value: Element) {
        self.init(value, type: .concurrent)
    }
    
    /// Performs a synchronous access to the internal value and returns its
    /// state.
    ///
    /// - returns: The value stored in the atomic object.
    ///
    /// _Synchronous Method_
    public func load() -> Element {
        return queue.sync { return self.value }
    }
    
    /// Performs an asynchronous action on the internal value.
    ///
    /// - parameters:
    ///     - action: A closure containing code that which may access the
    ///               internal value of this atomic object.
    ///
    /// _Asynchronous Method_
    public func loading(_ action: @escaping (Element) -> Void) {
        queue.async { action(self.value) }
    }
    
    /// Stores a given value in this atomic object.
    ///
    /// - parameters:
    ///     - newValue: The value to store.
    ///
    /// _Asynchronous Method_
    public func store(_ newValue: Element) {
        queue.async { self.value = newValue }
    }
    
}
