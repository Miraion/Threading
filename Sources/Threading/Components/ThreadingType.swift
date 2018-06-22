//
//  ThreadingType.swift
//  Threading
//
//  Created by Jeremy Schwartz on 2018-06-16.
//

/// Enumeration of threading types for threaded objects. Depending on the case
/// supplied to the threaded object, the object will behave differently.
public enum ThreadingType {
    
    /// Allows concurrent reads on threaded objects.
    /// When writting, concurrency is disabled.
    case concurrent
    
    /// All operations, reads and writes, are executed sequentially.
    case serial
    
}
