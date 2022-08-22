//
//  LabelChainable.swift
//  ChainKit
//
//  Created by wangteng on 2022/8/22.
//

import UIKit

public extension UILabel {
    
   convenience init( _ content: String) {
        self.init()
        self.text = content
    }
}

public extension Chained where T : UILabel {
    
    /// The font of the text.
    @discardableResult
    func font(_ font: UIFont?) -> Self {
        self.base.font = font
        return self
    }
    
    /// The technique for aligning the text.
    @discardableResult
    func alignment(_ alignment: NSTextAlignment) -> Self {
        self.base.textAlignment = alignment
        return self
    }
    
    /// The color of the text.
    @discardableResult
    func foregroundColor(_ color: UIColor) -> Self {
        self.base.textColor = color
        return self
    }
    
    /// The text that the label displays.
    @discardableResult
    func text(_ content: String) -> Self {
        self.base.text = content
        return self
    }
    
    /// The maximum number of lines for rendering text.
    /// The default is `0`
    @discardableResult
    func lineLimit(_ number: Int? = nil) -> Self {
        self.base.numberOfLines = number ?? 0
        return self
    }
    
    /// The technique for wrapping and truncating the label’s text.
    @discardableResult
    func truncationMode(_ mode: NSLineBreakMode) -> Self {
        self.base.lineBreakMode = mode
        return self
    }
    
    /// Applies an underline to the text.
    ///
    /// - Parameters:
    ///   - active: A Boolean value that indicates whether the text has an
    ///     underline.
    ///   - color: The color of the underline. If `color` is `nil`, the
    ///     underline uses the default foreground color.
    ///
    /// - Returns: The invoke instace object.
    @discardableResult
    func textLine(_ active: Bool = true,
                  color: UIColor? = nil,
                  lineStyle: NSAttributedString.Key = .strikethroughStyle) -> Self {
        
        guard active else {
            let text = self.base.text
            self.base.attributedText = nil
            self.base.text = text
            return self
        }
        
        if let text = self.base.text, !text.isEmpty {
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttributes(
                [.font: self.base.font!,
                 .foregroundColor: self.base.textColor!,
                 .underlineColor: color ?? self.base.textColor!,
                lineStyle: NSUnderlineStyle.single.rawValue],
                range: NSRange(location: 0, length: text.count)
            )
            self.base.attributedText = attributedText
        }
        return self
    }
    
    @discardableResult
    func fixedSize(horizontal: Bool = false, vertical: Bool = true) -> Self {
        var fitsSize = self.base.bounds.size
        if horizontal {
            fitsSize.width = CGFloat.greatestFiniteMagnitude
        }
        if vertical {
            fitsSize.height = CGFloat.greatestFiniteMagnitude
        }
        let size = self.base.sizeThatFits(fitsSize)
        
        /*
        if paddingEdgeInsets != .zero {
            size.width += paddingEdgeInsets.left + paddingEdgeInsets.right
            size.height += paddingEdgeInsets.top + paddingEdgeInsets.bottom
        }*/
         
        self.frame(.size(width: size.width, height: size.height))
        return self
    }
}
