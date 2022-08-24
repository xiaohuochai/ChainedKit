//
//  Popup.swift
//  ChainKit
//
//  Created by wangteng on 2022/8/23.
//

import UIKit

public protocol Popupable where Self: UIView {
    
    func beginAnimation(completion: @escaping ()->Void)
    
    func endAnimation(completion: @escaping ()->Void)

    var isShowMaskView: Bool { get }
    
    var maskViewUserInteractionEnabled: Bool { get }
}

public extension Popupable {
    
    var isShowMaskView: Bool { true }
    
    var maskViewUserInteractionEnabled: Bool { true }
}

public enum PopupMaskType: Int {
   case blackBlur
   case whiteBlur
   case white
   case clear
   case blackTranslucent
}

public enum PopupControlTouchType: Int {
    case maskView
    case contentView
}

open class Popup<T: Popupable> : NSObject, UIGestureRecognizerDelegate {
    
    public weak var contentView: T?
    
    public weak var superView: UIView?
    
    public var isAutoDismiss: Bool = false
    
    public var autoDismissDuration: TimeInterval = 3.0
    
    public var maskType: PopupMaskType
    
    /// MaskView Dismiss Callback Block
    /// 回调参数:
    /// 1.点击MaskView
    /// 2.点击ContentView
    public var dimissOfMaskViewBlock: ((PopupControlTouchType) -> Void)? = nil
    
    public var maskAlpha: CGFloat = 0.3 {
        didSet {
            if maskType == .blackTranslucent {
                maskView?.backgroundColor = UIColor(white: 0.0, alpha: maskAlpha)
            }
        }
    }
    
    public var maskView: UIView? {
        didSet {
            guard maskView != nil else { return }

            addBlurView(maskType: maskType, targetView: maskView)
      
            effectMaskViewBlur(maskView: maskView!)
        }
    }
    
    public init(maskType: PopupMaskType = .blackTranslucent,
                contentView: T,
                superView: UIView? = nil) {
        self.maskType = maskType
        self.maskView = nil
        self.superView = superView
        self.contentView = contentView
        super.init()
        setSuperView()
        setMaskView()
    }
    
    @discardableResult
    public func show() -> UIView? {
        
        guard let contentView = contentView else {
            return nil
        }
        
        if contentView.isShowMaskView { //Show MaskView 蒙层
            guard let mask = maskView,
                let sv = superView else { return nil }
            if !mask.subviews.contains(contentView) {
                mask.addSubview(contentView)
            }
            if !sv.subviews.contains(mask) {
                sv.addSubview(mask)
            }
            contentView.beginAnimation {}
            autoDismiss()
            
            return mask
        }
        else {
            guard let sv = superView else { return nil }

            if !sv.subviews.contains(contentView) {
                sv.addSubview(contentView)
            }
            contentView.beginAnimation {}
            autoDismiss()
            
            return maskView
        }
    }
    
    /// Dismiss MaskView
    public func dismiss(completion: ((Bool) -> Void)? = nil) {
        if let dismissBlock = self.dimissOfMaskViewBlock { dismissBlock(.contentView) }
        dismissMaskView(completion)
    }
    
    private func autoDismiss() {
        if self.isAutoDismiss {
            DispatchQueue.init(label: "PopupView-Dismiss").asyncAfter(wallDeadline: .now() + self.autoDismissDuration) {
                DispatchQueue.main.async {
                    self.dismiss()
                }
            }
        }
    }
    
    /// 设置 Superview
    private func setSuperView() {
        if let sv = superView {
            self.superView = sv
        }
        else {
            self.superView = frontWindow()
        }
    }
    
    /// 初始化 Maskview 并且 添加点击手势
    private func setMaskView() {
        maskView = UIView(frame: superView?.bounds ?? .zero)
        maskView?.isUserInteractionEnabled = true
        maskviewAddTapGesture()
    }
    
    /// Maskview 添加 点击手势
    private func maskviewAddTapGesture() {
        //MaskView 添加触碰手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(maskViewTapGesture))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        maskView?.addGestureRecognizer(tapGesture)
    }
    
    @objc private func maskViewTapGesture() {
        
        guard let contentView = contentView else { return }
        
        guard contentView.maskViewUserInteractionEnabled else { return }
        
        if let dismissBlock = self.dimissOfMaskViewBlock { dismissBlock(.maskView) }
        dismissMaskView()
    }
    
    /// 隐藏MaskView
    /// ContentView 使用调用
    private func dismissMaskView(_ completion: ((Bool) -> Void)? = nil) {
        contentView?.endAnimation { [weak self] in
            self?.maskView?.removeFromSuperview()
            self?.contentView?.removeFromSuperview()
            if let cmp = completion { cmp(true) }
        }
    }
    
    ///
    /// 找到当前Window
    ///
    private func frontWindow() -> UIWindow? {
        
        var enumerator: ReversedCollection<Array<UIWindow>>?
        if #available(iOS 15.0, *) {
            enumerator = UIApplication.shared.connectedScenes
                .map({ ($0 as? UIWindowScene)?.keyWindow })
                                   .compactMap({ $0 }).reversed()
        } else {
            enumerator = UIApplication.shared.windows.reversed()
        }
        guard let enumerator = enumerator else {
            return UIApplication.shared.delegate?.window ?? nil
        }
        for window in enumerator {
            let windowOnMainScreen = (window.screen == UIScreen.main)
            let windowIsVisible = (!window.isHidden && window.alpha > 0)
            if windowOnMainScreen && windowIsVisible && window.isKeyWindow {
                return window
            }
        }
        return UIApplication.shared.delegate?.window ?? nil
    }
    
    private func addBlurView(maskType: PopupMaskType,
                             targetView: UIView?) {
   
        if [PopupMaskType.blackBlur, PopupMaskType.whiteBlur].contains(maskType) {
            let visualEffectView = UIVisualEffectView()
            visualEffectView.effect = UIBlurEffect(style: .light)
            visualEffectView.frame = superView?.bounds ?? .zero
            if !(targetView?.subviews.first is UIVisualEffectView) {
                targetView?.insertSubview(visualEffectView, at: 0)
            }
        }
    }
    
    ///
    /// 根据MaskType 生效其蒙层
    ///
    private func effectMaskViewBlur(maskView: UIView) {
        switch maskType {
        case .blackTranslucent:
            maskView.backgroundColor = UIColor(white: 0.0, alpha: maskAlpha)
        case .blackBlur:
            let effectView = maskView.subviews.first as? UIVisualEffectView
            effectView?.effect = UIBlurEffect(style: .dark)
        case .clear:
            maskView.backgroundColor = .clear
        case .white:
            maskView.backgroundColor = .white
        case .whiteBlur:
            let effectView = maskView.subviews.first as? UIVisualEffectView
            effectView?.effect = UIBlurEffect(style: .light)
        }
    }
    
    //MARK: - UIGestureRecognizerDelegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        guard let contentView = contentView else { return true }
        
        if let state = (touch.view?.isDescendant(of: contentView)),
           state == true {
           return false
        }
        else {
            return true
        }
    }
}
