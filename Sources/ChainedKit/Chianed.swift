//
//  Chained.swift
//  ChainKit
//
//  Created by wangteng on 2022/8/22.
//

public struct Chained<T> {
    
    /// Base object to extend.
    public var base: T

    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    public init(_ base: T) {
        self.base = base
    }
}

/// A type that has reactive extensions.
public protocol Chainable {
    associatedtype T
    
    static var chained: Chained<T>.Type { get set }
    
    var chained: Chained<T> { get set }
}

extension Chainable {
   
    public static var chained: Chained<Self>.Type {
        get { Chained<Self>.self }
        set { }
    }

    public var chained: Chained<Self> {
        get { Chained(self) }
        set { }
    }
}

import UIKit

extension UIView: Chainable { }
