//
//  ThreadedArray.swift
//  Threading
//
//  Created by Jeremy Schwartz on 2018-06-17.
//

import Foundation

public class ThreadedArray<T> : ThreadedObject<Array<T>> {
    
    public typealias InternalCollectionType = Array<T>
    public typealias Index = InternalCollectionType.Index
    public typealias Element = InternalCollectionType.Element
    
    /// Constructs from an existing array and a threading type.
    ///
    /// - parameters:
    ///     - array: An array who's elements will be copied to the new array.
    ///
    ///     - type: The threading type which defines how this array should act.
    public override init(_ array: [Element], type: ThreadingType) {
        super.init(array, type: type)
    }
    
    /// Initializes this array with a blank base array and concurrent type.
    public convenience init() {
        self.init([Element](), type: .concurrent)
    }
    
    /// Constructs from an existing array.
    ///
    /// - parameters:
    ///     - array: An array who's elements will be copied to the new array.
    ///
    /// Threading type is set to concurrent.
    public convenience init(_ array: [Element]) {
        self.init(array, type: .concurrent)
    }
    
}

// MARK: - Mutating Methods

public extension ThreadedArray {
    
    /// Appends a new element to the end of the array.
    ///
    /// - parameters:
    ///     - newElement: The element to add to the array.
    public func append(_ newElement: Element) {
        async { collection in
            collection.append(newElement)
        }
    }
    
    /// Appends the contents of a sequence to the end of the array.
    ///
    /// - parameters:
    ///     - sequence: The sequence who's elements should be added.
    ///
    /// `Sequence.Elmement` must be the same as `Self.Element`.
    ///
    /// - complexity: _O(n)_, where n is the length of the resulting array.
    public func append<S: Sequence>(contentsOf sequence: S)
        where S.Element == Element
    {
        async { collection in
            collection.append(contentsOf: sequence)
        }
    }
    
    /// Removes the element at a given index.
    ///
    /// - parameters:
    ///     - index: The position at which to remove an element.
    ///
    ///     - callback: An optional closure which is passed the element that was
    ///                 just removed. This closure, if not `nil`, will be called
    ///                 asyncronously on the main thread once the removal is
    ///                 complete.
    ///
    /// - complexity: _O(n)_, where n is the size of the collection.
    public func remove(at index: Index, callback: ((Element) -> Void)? = nil) {
        async { collection in
            let value = collection.remove(at: index)
            if let function = callback {
                DispatchQueue.main.async {
                    function(value)
                }
            }
        }
    }
    
    /// Removes the first element in the array.
    ///
    /// - parameters:
    ///     - callback: An optional closure which is passed the element that was
    ///                 just removed. This closure, if not `nil`, will be called
    ///                 asyncronously on the main thread once the removal is
    ///                 complete.
    ///
    /// The collection must not be empty.
    ///
    /// - complexity: _O(n)_, where n in the size of the collection.
    public func removeFirst(callback: ((Element) -> Void)? = nil) {
        async { collection in
            let value = collection.removeFirst()
            if let function = callback {
                DispatchQueue.main.async {
                    function(value)
                }
            }
        }
    }
    
    /// Removes the element element in the array.
    ///
    /// - parameters:
    ///     - callback: An optional closure which is passed the element that was
    ///                 just removed. This closure, if not `nil`, will be called
    ///                 asyncronously on the main thread once the removal is
    ///                 complete.
    ///
    /// The collection must not be empty.
    ///
    /// - complexity: _O(1)_
    public func removeLast(callback: ((Element) -> Void)? = nil) {
        async { collection in
            let value = collection.removeLast()
            if let function = callback {
                DispatchQueue.main.async {
                    function(value)
                }
            }
        }
    }
    
}

// MARK: - Threaded Collection Conformance

extension ThreadedArray : ThreadedCollection {
    
    /// Returns an unmanaged version of the underlying object.
    public var unthreaded: Array<Element> {
        return sync { collection in
            return collection
        }
    }
    
}

// MARK: - Swift Collection Conformance

extension ThreadedArray : MutableCollection, RandomAccessCollection {
    
    /// The position of the first element in a non-empty array.
    public var startIndex: Int {
        return sync { collection in
            return collection.startIndex
        }
    }
    
    /// The collection's "past the end" position – that is the position one
    /// past the last valid subscript argument.
    public var endIndex: Int {
        return sync { collection in
            return collection.endIndex
        }
    }
    
    /// Provides random access to any element located in the collection.
    ///
    /// - parameters:
    ///     - position: The zero-indexed location of the element to access.
    ///                 `position` must be witin the range
    ///                 `startIndex..<endIndex`, otherwise a fatal, uncatchable
    ///                  exception will be thrown.
    public subscript(position: Int) -> Element {
        get {
            return sync { collection in
                return collection[position]
            }
        }
        set {
            async { collection in
                collection[position] = newValue
            }
        }
    }
    
    /// Returns the position immediately after a given index.
    ///
    /// - parameters:
    ///     - i: A valid position in the collection,
    ///          i must be less than `endIndex`,
    public func index(after i: Index) -> Index {
        return sync { collection in
            return collection.index(after: i)
        }
    }
    
}
