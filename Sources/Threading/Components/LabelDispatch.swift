//
//  LabelDispatch.swift
//  Threading
//
//  Created by Jeremy Schwartz on 2018-06-16.
//

internal class LabelDispatch {
    
    private static var nextId = 0
    
    internal static func get() -> String {
        let id = nextId
        nextId += 1
        return "com.threading.dispatchqueue_\(id)"
    }
    
}
