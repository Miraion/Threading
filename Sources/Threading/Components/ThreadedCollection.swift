//
//  ThreadedCollection.swift
//  Threading
//
//  Created by Jeremy Schwartz on 2018-06-17.
//

import Foundation

public protocol ThreadedCollection {
    
    associatedtype InternalCollectionType
    
    /// Returns an unmanaged version of the underlying object.
    var unthreaded: InternalCollectionType { get }
    
}
