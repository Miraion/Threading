//
//  LabelDispatch.swift
//  Threading
//
//  Created by Jeremy Schwartz on 2018-06-16.
//

import Foundation

internal class LabelDispatch {
    
    private static var nextId = 0
    
    internal static func get() -> Int {
        let id = nextId
        nextId += 1
        return id
    }
    
}
