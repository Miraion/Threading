//
//  Atomic.swift
//  Threading
//
//  Created by Jeremy Schwartz on 2018-06-16.
//

import Foundation

public class Atomic<Element> : ThreadedObject<Element> {
    
    /// Initializes this atomic element from a normal element.
    ///
    /// - parameters:
    ///     - value: Value to store.
    ///
    ///     - type: The access type for this attomic element.
    public override init(_ value: Element, type: ThreadingType) {
        super.init(value, type: type)
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
        return sync { value in
            return value
        }
    }
    
    /// Performs an asynchronous action on the internal value.
    ///
    /// - parameters:
    ///     - action: A closure containing code that which may access the
    ///               internal value of this atomic object.
    ///
    /// _Asynchronous Method_
    public func loading(_ action: @escaping (inout Element) -> Void) {
        async { value in
            action(&value)
        }
    }
    
    /// Stores a given value in this atomic object.
    ///
    /// - parameters:
    ///     - newValue: The value to store.
    ///
    /// _Asynchronous Method_
    public func store(_ newValue: Element) {
        async { value in
            value = newValue
        }
    }
}


extension Atomic : CustomStringConvertible
    where Element : CustomStringConvertible
{
    public var description: String {
        return load().description
    }
}

extension Atomic : CustomDebugStringConvertible
    where Element : CustomDebugStringConvertible
{
    public var debugDescription: String {
        return load().debugDescription
    }
}
