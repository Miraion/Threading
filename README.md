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

## Installation

To install using Swift Package Manager, simply include the following line in your `Package.swift` file under dependencies. Don't forget to add the dependency `"Threading"` to any targets that require the library.

``` swift
.package(url: "https://github.com/Miraion/Threading.git", from: "0.0.0"),
```

Then simply add the following import statement to your source files.

``` swift
import Threading
```

## Usage

### Common

Most threaded objects take an optional `ThreadingType` enum parameter in their initializers. This parameter tells the object how it  should behave when being interacted with. There are two options: `ThreadingType.serial` where only one thread can use the object at a time, and `ThreadingType.concurrent` (default) where multiple threads can read from the object at a time, but when being mutated, only one thread can have access.

All threaded objects extend the generic `ThreadedObject<T>` base class which wraps around an object and provides thread-safe interfaces for interacting with said object. These two methods, `async` and `sync`, act as the interfaces through which the underlying (threaded) object may be viewed.

The `async` method acts as a mutable interface for the theaded object. The theaded object is passed as an `inout` parameter to a given closure which is executed concurrently along side the calling thread. Any actions that mutate the threaded object should be done asyncronously to ensure that no other thread is trying to access the threaded object at the same time.

``` swift
async(_ callback: @escaping (inout T) -> Void)
```
<br/>

The `sync` method is a readonly interface for the threaded object. This method is executed within the calling thread which allows values to be returned from this method. Only non-mutating methods may be called from within this method as there is no guarentee that the calling thread is the only viewer of the threaded object.

``` swift
sync<ReturnType>(_ callback: @escaping (T) -> ReturnType) -> ReturnType
```

<br/>

A third interface, `mutatingSync`, is a mutable interface that is executed within the calling thread. This interface is only available to threaded objects that are configured to be `serial` during their initialization. Calling the `mutatingSync` method on a `concurrent` object will force the program to terminate. 

**Important**: only call this method on threaded objects that you know are configured to be `serial`.

``` swift
mutatingSync<ReturnType>(_ callback: @escaping (inout T) -> ReturnType) -> ReturnType
```

### Atomic

The `Atomic<T>` class is a thread-safe container that holds a single object. The object can be interacted with using the `sync` and `async` methods described above or special `load` and `store` methods that are built specifically for this class.

`load` is a syncronous read method that returns a copy of the threaded object.

``` swift
load() -> T
```

`store` is an asyncronous write method that stores a brand new value in the atomic object.

``` swift
store(_ newElement: T)
```

**Example**

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
