//
//  ChainedButton.swift
//  ChainKit
//
//  Created by wangteng on 2022/8/22.
//

import UIKit

public extension Chained where T : UIButton {
    
    enum ImagePlacement: Int, CaseIterable {
        case top, left, bottom, right
    }
    
    /// Sets the title to use for the specified state.
    @discardableResult
    func setTitle(_ title: String?, for state: UIControl.State = .normal) -> Self {
        self.base.setTitle(title, for: state)
        return self
    }

    /// Sets the image to use for the specified state.
    @discardableResult
    func setImage(_ image: UIImage?, for state: UIControl.State = .normal) -> Self {
        self.base.setImage(image, for: state)
        return self
    }

    /// The color of the text.
    @discardableResult
    func foregroundColor(_ color: UIColor) -> Self {
        self.base.titleLabel?.textColor = color
        return self
    }
    
    /// The font of the text.
    @discardableResult
    func font(_ font: UIFont?) -> Self {
        self.base.titleLabel?.font = font
        return self
    }
    
    /// A Boolean value indicating whether the control is in the selected state.
    @discardableResult
    func toggle() -> Self {
        self.base.isSelected = !self.base.isSelected
        return self
    }
    
    /// The inset or outset margins for the rectangle around the button’s title text and image.
    @discardableResult
    func imagePosition(_ space: CGFloat = 10 , _ imagePlacement: ImagePlacement) -> Self {
    
        let imageSize = (self.base.imageView?.frame.size ?? .zero)
        
        let imageWith = imageSize.width
        let imageHeight = imageSize.height
           
        let intrinsicContentSize = self.base.titleLabel?.intrinsicContentSize ?? .zero
        let labelWidth = intrinsicContentSize.width
        let labelHeight = intrinsicContentSize.height

        var imageEdgeInsets: UIEdgeInsets = UIEdgeInsets()
        var labelEdgeInsets: UIEdgeInsets = UIEdgeInsets()
             
        switch imagePlacement {
        case .top:
            imageEdgeInsets = .init(top: -labelHeight - space/2.0, left: 0, bottom: 0, right:  -labelWidth)
            labelEdgeInsets = .init(top:0, left: -imageWith, bottom: -imageHeight-space/2.0, right: 0)
        case .left:
            imageEdgeInsets = .init(top:0, left:-space/2.0, bottom: 0, right:space/2.0)
            labelEdgeInsets = .init(top:0, left:space/2.0, bottom: 0, right: -space/2.0)
        case .bottom:
            imageEdgeInsets = .init(top:0, left:0, bottom: -labelHeight-space/2.0, right: -labelWidth)
            labelEdgeInsets = .init(top:-imageHeight-space/2.0, left:-imageWith, bottom: 0, right: 0)
        case .right:
            imageEdgeInsets = .init(top:0, left:labelWidth+space/2.0, bottom: 0, right: -labelWidth-space/2.0)
            labelEdgeInsets = .init(top:0, left:-imageWith-space/2.0, bottom: 0, right:imageWith+space/2.0)
        }
        
        self.base.titleEdgeInsets = labelEdgeInsets
        self.base.imageEdgeInsets = imageEdgeInsets
        
        return self
    }
}
