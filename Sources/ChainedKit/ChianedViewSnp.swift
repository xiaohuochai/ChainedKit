//
//  ChianedViewSnp.swift
//  ChainKit
//
//  Created by wangteng on 2022/8/22.
//

import UIKit
import SnapKit

public extension Chained where T : UIView {
    
    @discardableResult
    func remakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> Self {
        self.base.snp.remakeConstraints(closure)
        self.updateLayers()
        return self
    }
    
    @discardableResult
    func makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> Self {
        self.base.snp.makeConstraints(closure)
        self.updateLayers()
        return self
    }
    
    @discardableResult
    func updateConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> Self {
        self.base.snp.updateConstraints(closure)
        self.updateLayers()
        return self
    }
    
    @discardableResult
    func removeConstraints() -> Self {
       self.base.snp.removeConstraints()
       return self
    }
    
    @discardableResult
    func contentHuggingHorizontalPriority(_ priority: Float) -> Self {
        self.base.snp.contentHuggingHorizontalPriority = priority
        return self
    }
  
    @discardableResult
    func contentHuggingVerticalPriority(_ priority: Float) -> Self {
        self.base.snp.contentHuggingVerticalPriority = priority
        return self
    }
    
    @discardableResult
    func contentCompressionResistanceHorizontalPriority(_ priority: Float) -> Self {
        self.base.snp.contentCompressionResistanceHorizontalPriority = priority
        return self
    }
    
    @discardableResult
    func contentCompressionResistanceVerticalPriority(_ priority: Float) -> Self {
        self.base.snp.contentCompressionResistanceVerticalPriority = priority
        return self
    }
}


