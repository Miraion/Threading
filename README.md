# Threading

Threading provides a collection of thread-safe objects implemented purly in Swift. The objects are designed to be as easy to use as the native swift objects, but with an underlying implementation that is designed for concurrent reading and writing. 

This library was inspired by [this](http://basememara.com/creating-thread-safe-arrays-in-swift/) blog post by Basem Emara.

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
  - [Common](#common)
  - [Atomic](#atomic)
  - [ThreadedArray](#threadedarray)
  - [ThreadedDictionary](#threadeddictionary)
  - [ThreadedQueue](#threadedqueue)

## Installation

To install using Swift Package Manager, simply include the following line in your `Package.swift` file under dependencies. Don't forget to add the dependency `"Threading"` to any targets that require the library.

``` swift
.package(url: "https://github.com/Miraion/Threading.git", from: "1.0.0"),
```

Then simply add the following import statement to your source files.

``` swift
import Threading
```

## Usage

### Common

Most threaded objects take an optional `ThreadingType` enum parameter in their initializers. This parameter tells the object how it  should behave when being interacted with. There are two options: `ThreadingType.serial` where only one thread can use the object at a time, and `ThreadingType.concurrent` (default) where multiple threads can read from the object at a time, but when being mutated, only one thread can have access.

All threaded objects extend the generic `ThreadedObject<T>` base class which wraps around an object and provides thread-safe interfaces for interacting with said object. These three methods, `async`, `sync` and `mutableSync`, act as the interfaces through which the underlying (threaded) object may be viewed.

The `async` method acts as a mutable interface for the theaded object. The theaded object is passed as an `inout` parameter to a given closure which is executed concurrently along side the calling thread. Any actions that mutate the threaded object should be done asynchronously to ensure that no other thread is trying to access the threaded object at the same time.

``` swift
async(_ callback: @escaping (inout T) -> Void)
```
<br/>

The `sync` method is a readonly interface for the threaded object. This method is executed within the calling thread which allows values to be returned from this method. Only non-mutating methods may be called from within this method as there is no guarentee that the calling thread is the only viewer of the threaded object.

``` swift
sync<ReturnType>(_ callback: @escaping (T) -> ReturnType) -> ReturnType
```

<br/>

A third interface, `mutatingSync`, is a mutable interface that is executed within the calling thread. This method should be used when an action needs to both write and return a value from the underlying object: for example, the 'pop' action of a stack.

``` swift
mutatingSync<ReturnType>(_ callback: @escaping (inout T) -> ReturnType) -> ReturnType
```

### Atomic

The `Atomic<T>` class is a thread-safe container that holds a single object. The object can be interacted with using the `sync` and `async` methods described above or special `load` and `store` methods that are built specifically for this class.

#### Methods

-----

``` swift
func load() -> T
```

A synchronous read method that returns a copy of the threaded object.

-----

``` swift
func store(_ newElement: T)
```

An asynchronous write method that stores a brand new value in the atomic object.

-----

``` swift
func loading(_ action: @escaping (inout T) -> Void)
```

Performs an action on the underlying value asynchronously.

-----

#### Example

``` swift
let atomicFlag = Atomic<Bool>(true)

DispatchQueue.main.async {
    while atomicFlag.load() {
        print("From Async Thread")
        sleep(1)
    }
}

sleep(5)
atomicFlag.store(false)
```

### ThreadedArray

`ThreadedArray<T>`, as the name implies, is a thread-safe, random access array. A majority of Swift's standard array methods are incorperated into this object to make it as easy to use as possible.

`ThreadedArray` conforms to the `Collection` protocol; meaning that can be used in `for in` loops.

#### Types

``` swift
typealias InternalCollectionType = [T]
````

``` swift
typealias Element = InternalCollectionType.Element
```

``` swift
typealias Index = InternalCollectionType.Index
```

#### Methods

-----

``` swift
subscript(position: Int) -> T { get, set }
```

Random read/write access to any element in the array. Gets are performed synchronously while sets are performed asynchronously.

-----

``` swift
func append(_ newElement: T)
```

Asynchronously appends a new element to the end of the array.

-----

``` swift
func remove(at position: Int, callback: ((T) -> Void)? = nil)
```

Removes an element at a given position and passes that element to an optional closure which is executed asynchronously on the main thread after the element is removed.

-----

### ThreadedDictionary

`ThreadedDictionary<K, V>` is a thread-safe wrapper class for Swift's standard dictionary. A majority of the methods present in the standard dictionary are present in `ThreadedDictionary`.

`ThreadedDictionary` conforms to the `Collection` protocol; meaning that it can be used in `for in` loops.

#### Types

``` swift
typealias InternalCollectionType = [K : V]
```

``` swift
typealias Index = InternalCollectionType.Index
```

``` swift
typealias Element = InternalCollectionType.Element
```

``` swift
typealias Keys = InternalCollectionType.Keys
```

``` swift
typealias Values = InternalCollectionType.Values
```

#### Methods

-----

``` swift
subscript(key: K) -> V? { get, set }
```

Key style subscript. Gets are performed synchronously while sets are perfomed asynchronously.

-----

``` swift
var keys: Keys { get }
```

``` swift
var values: Values { get }
```

Returns the keys/values of the dictionary as a collection.

-----

### ThreadedQueue

`ThreadedQueue<T>` is a thread-safe wrapper for the `LinkedQueue<T>` class which comes with this library. It is a linked list style implementation of a queue which provides insertions and removals that are *O(1)*.

#### Types

``` swift
typealias InternalCollectionType = LinkedQueue<T>
```

``` swift
typealias Element = InternalCollectionType.Element
```

#### Methods

-----

``` swift
func enqueue(_ newElement: T)
```

Asynchronously adds an element to the end of the queue.

-----

``` swift
func dequeue() -> Element
```

Synchronously removes and returns the first element of the queue. This method should **not** be called on an empty queue.

Uses the `mutatingSync` interface.

-----

``` swift
func safeDequeue() -> Element?
```

A safe version of `dequeue` that can be called on an empty queue. This method should be used of the regular `dequeue` when multiple threads are simultaneously removing elements from the queue.

-----

``` swift
var isEmpty: Bool { get }
```

Returns `true` if the queue is empty, `false` otherwise.

-----

``` swift
var count: Int { get }
```

Returns the number of elements in the queue.

-----
