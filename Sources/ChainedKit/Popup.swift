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
    
    var customAnimation: Bool { get }
}

public extension Popupable {
    
    func beginAnimation(completion: @escaping ()->Void) {}
    
    func endAnimation(completion: @escaping ()->Void) {}
    
    var isShowMaskView: Bool { true }
    
    var maskViewUserInteractionEnabled: Bool { true }
    
    var customAnimation: Bool { false }
}

open class Popup<T: Popupable> : NSObject, UIGestureRecognizerDelegate {
    
    public enum PopupMaskType: Int {
       case blackBlur
       case whiteBlur
       case white
       case clear
       case blackTranslucent
    }

    public enum PopupDirection: Int {
       case left
       case top
       case right
       case bottom
       case center
    }

    public enum PopupControlTouchType: Int {
        case maskView
        case contentView
    }
    
    public weak var contentView: T?
    
    public weak var superView: UIView?
    
    public var isAutoDismiss: Bool = false
    
    public var autoDismissDuration: TimeInterval = 3.0
    
    public var maskType: PopupMaskType
    
    public var direction: PopupDirection = .bottom
    
    public var dimissOfMaskViewBlock: ((PopupControlTouchType) -> Void)? = nil
    
    public var maskAlpha: CGFloat = 0.4 {
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
    
    /// 设置 Superview
    private func setSuperView() {
        if let sv = superView {
            self.superView = sv
        }
        else {
            self.superView = frontWindow()
        }
    }
 
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
 
    
    //MARK: - UIGestureRecognizerDelegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let contentView = contentView else { return true }
        if let state = (touch.view?.isDescendant(of: contentView)), state == true {
           return false
        }
        else {
            return true
        }
    }
    
    @objc private func maskViewTapGesture() {
        guard let contentView = contentView else { return }
        guard contentView.maskViewUserInteractionEnabled else { return }
        if let dismissBlock = self.dimissOfMaskViewBlock { dismissBlock(.maskView) }
        dismissMaskView()
    }
    
}

// MARK: show&dismiss
extension Popup {
    
    @discardableResult
    public func show(_ direction: PopupDirection = .bottom) -> UIView? {
        guard let _ = contentView else {
            return nil
        }
        self.direction = direction
        addComponts()
        showAnimated()
        autoDismiss()
        return maskView
    }
    
    private func addComponts() {
        guard let contentView = contentView else { return }
        if contentView.isShowMaskView {
            guard let mask = maskView, let sv = superView else { return }
            if !mask.subviews.contains(contentView) {
                mask.addSubview(contentView)
            }
            if !sv.subviews.contains(mask) {
                sv.addSubview(mask)
            }
        } else {
            guard let sv = superView else { return }
            if !sv.subviews.contains(contentView) {
                sv.addSubview(contentView)
            }
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
    
    private func destory() {
        self.maskView?.removeFromSuperview()
        self.contentView?.removeFromSuperview()
    }
}

// MARK: mask
extension Popup {
    
    /// 初始化 Maskview 并且 添加点击手势
    private func setMaskView() {
        maskView = UIView(frame: superView?.bounds ?? .zero)
        maskView?.isUserInteractionEnabled = true
        maskViewAddTapGesture()
    }
    
    /// Maskview 添加 点击手势
    private func maskViewAddTapGesture() {
        //MaskView 添加触碰手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(maskViewTapGesture))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        maskView?.addGestureRecognizer(tapGesture)
    }

    /// 隐藏MaskView
    /// ContentView 使用调用
    private func dismissMaskView(_ completion: ((Bool) -> Void)? = nil) {
        self.hideAnimated { [weak self] _ in
            guard let self = self else { return }
            self.destory()
            completion?(true)
        }
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
}

// MARK: animated
extension Popup {
    
    private func hideAnimated(_ completion: ((Bool) -> Void)? = nil) {
        
        guard let contentView = contentView else { return }
        
        if contentView.customAnimation {
            contentView.endAnimation { completion?(true) }
            return
        }
        
        switch self.direction {
        case .left:
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                contentView.chained.frame(.left(-contentView.bounds.width))
                self.maskView?.alpha = 0
            } completion: { _ in
                completion?(true)
            }
        case .top:
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                contentView.chained.frame(.top(-contentView.bounds.height))
                self.maskView?.alpha = 0
            } completion: { _ in
                completion?(true)
            }
        case .right:
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                contentView.chained.frame(.left(UIScreen.main.bounds.width))
                self.maskView?.alpha = 0
            } completion: { _ in
                completion?(true)
            }
        case .bottom:
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                contentView.chained.frame(.top(UIScreen.main.bounds.height))
                self.maskView?.alpha = 0
            } completion: { _ in
                completion?(true)
            }
        case .center:
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                contentView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.maskView?.alpha = 0
            } completion: { _ in
                completion?(true)
            }
        }
    }
    
    private func showAnimated(_ completion: ((Bool) -> Void)? = nil) {
        guard let contentView = contentView else { return }
        if contentView.customAnimation {
            contentView.beginAnimation {
                completion?(true)
            }
            return
        }
        
        switch self.direction {
        case .left:
            self.maskView?.alpha = 0
            contentView.chained.frame(.left(-contentView.bounds.width))
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                contentView.chained.frame(.left(0))
                self.maskView?.alpha = 1
            } completion: { _ in
                completion?(true)
            }
        case .top:
            self.maskView?.alpha = 0
            contentView.chained.frame(.top(-contentView.bounds.height))
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                contentView.chained.frame(.top(0))
                self.maskView?.alpha = 1
            } completion: { _ in
                completion?(true)
            }
        case .right:
            self.maskView?.alpha = 0
            contentView.chained.frame(.left(UIScreen.main.bounds.width))
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                contentView.chained.frame(.left(contentView.bounds.width))
                self.maskView?.alpha = 1
            } completion: { _ in
                completion?(true)
            }
        case .bottom:
            self.maskView?.alpha = 0
            contentView.chained.frame(.top(UIScreen.main.bounds.height))
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                contentView.chained.frame(.top(UIScreen.main.bounds.height-contentView.bounds.height))
                self.maskView?.alpha = 1
            } completion: { _ in
                completion?(true)
            }
        case .center:
            
            self.maskView?.alpha = 0
            contentView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                contentView.transform = CGAffineTransform.identity
                self.maskView?.alpha = 1
            } completion: { _ in
                completion?(true)
            }
        }
    }
}
