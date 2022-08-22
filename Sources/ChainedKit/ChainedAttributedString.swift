//
//  ChainedAttributedString.swift
//  ChainKit
//
//  Created by wangteng on 2022/8/22.
//

import UIKit

extension NSMutableAttributedString : Chainable {}

public extension Chained where T == NSMutableAttributedString {

    func font(_ font: UIFont) -> Self {
        self.base.addAttribute(.font, value: font,
                               range: NSRange(location: 0, length: self.base.length))
        return self
    }
    
    func foregroundColor(_ color: UIColor) -> Self {
        self.base.addAttribute(.foregroundColor,
                               value: color,
                               range: NSRange(location: 0, length: self.base.length))
        return self
    }
    
    func image(_ image: UIImage?) -> Self {
        guard let image = image else { return self }
        var font = UIFont.systemFont(ofSize: 14)
        let range = NSRange(location: 0, length: self.base.length)
        self.base.enumerateAttributes(in: range) { attributes, _, _ in
            if let attfont = attributes[.font]  as? UIFont {
                font = attfont
            }
        }
        let imageAttachment = NSTextAttachment()
        let mid = font.descender + font.capHeight
        imageAttachment.image = image
        imageAttachment.bounds = CGRect(x: 0,
                                        y: font.descender - image.size.height / 2 + mid + 2,
                                        width: image.size.width,
                                        height: image.size.height).integral
        self.base.append(NSAttributedString(attachment: imageAttachment))
        return self
    }
    
    func spacing(_ length: Int) -> Self {
        self.base.append(NSAttributedString(string: String(repeating: " ", count: length)))
        return self
    }
    
    func hightLight(_ text: String, font: UIFont, color: UIColor) -> Self {
        let hightLightRange = (self.base.string as NSString).range(of: text)
        guard hightLightRange.location != NSNotFound else { return self }
        self.base.addAttribute(.font,
                     value: font,
                     range: hightLightRange)
        self.base.addAttribute(.foregroundColor,
                     value: color,
                     range: hightLightRange)
        return self
    }
    
    func underLine(_ color: UIColor) -> Self {
        self.base.addAttributes(
            [.underlineColor: color,
             .underlineStyle: NSUnderlineStyle.single.rawValue],
            range: NSRange(location: 0, length: self.base.length)
        )
        return self
    }
    
    func strikethroughStyle(_ color: UIColor) -> Self {
        self.base.addAttributes(
            [.underlineColor: color,
             .strikethroughStyle: NSUnderlineStyle.single.rawValue],
            range: NSRange(location: 0, length: self.base.length)
        )
        return self
    }
}
