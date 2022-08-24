//
//  ChianedView.swift
//  ChainKit
//
//  Created by wangteng on 2022/8/22.
//

import UIKit


public extension Chained where T : UIView {
    
    /// The frame rectangle, which describes the view’s location and
    /// size in its superview’s coordinate system.
    @discardableResult
    func frame(_ frame: ChainedViewKeys.FrameFamily) -> Self {
        switch frame {
        case let .origin(x, y):
            self.base.frame = .init(origin: CGPoint.init(x: x, y: y),
                                         size: self.base.frame.size)
        case .left(let left):
            self.base.frame = .init(origin: CGPoint(x: left, y: self.base.frame.origin.y),
                                         size: self.base.frame.size)
        case .top(let top):
            self.base.frame = .init(origin: CGPoint(x: self.base.frame.origin.x, y: top),
                               size: self.base.frame.size)
        case .width(let width):
            self.base.frame = .init(origin: self.base.frame.origin,
                               size:
                 .init( width: width, height: self.base.frame.size.height))
        case .height(let height):
            self.base.frame = CGRect(x: self.base.frame.origin.x,
                                          y: self.base.frame.origin.y,
                                          width: self.base.frame.size.width,
                                height: height)
        case let .size(width, height):
            self.base.frame = .init(origin: self.base.frame.origin, size: .init(width: width, height: height))
        case .frame(let rect):
            self.base.frame = rect
        }
        self.updateLayers()
        return self
    }
    
    var screenBounds: CGRect {
        UIScreen.main.bounds
    }
    
    /// Adds a view to the end of the receiver’s list of subviews.
    @discardableResult
    func addSubview(_ view: UIView) -> Self {
        base.addSubview(view)
        return self
    }
    
    /// Adds a view to the begin of the receiver’s list of subviews.
    @discardableResult
    func addSuperview(_ view: UIView) -> Self {
        view.addSubview(self.base)
        return self
    }
    
    /// Appends the layer to the layer’s list of sublayers.
    @discardableResult
    func addSubLayer(_ layer: CALayer) -> Self {
        base.layer.addSublayer(layer)
        return self
    }
    
    /// A Boolean indicating whether sublayers are clipped to the layer’s bounds. Animatable.
    @discardableResult
    func clipped(_ activiy: Bool = true) -> Self {
        base.layer.masksToBounds = activiy
        return self
    }
    
    /// The radius to use when drawing rounded corners for the layer’s background. Animatable.
    @discardableResult
    func cornerRadius(_ radius: CGFloat) -> Self {
        base.layer.cornerRadius = radius
        base.layer.masksToBounds = radius > 0
        return self
    }
    
    /// The view’s background color
    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        self.base.backgroundColor = color
        return self
    }
    
    /// Adds an action to perform when this view recognizes a tap gesture.
    ///
    /// Use this method to perform a specific `action` when the user clicks or
    /// taps on the view or container `count` times.
    ///
    /// - Parameters:
    ///    - count: The number of taps or clicks required to trigger the action
    ///      closure provided in `action`. Defaults to `1`.
    ///    - action: The action to perform.
    @discardableResult
    func onTapGesture(count: Int = 1, perform action: @escaping () -> Void) -> Self {
        let tapGesture = UITapGestureRecognizer(target: self.base, action: #selector(self.base.onTapGestureAction))
        tapGesture.numberOfTapsRequired = count
        self.base.isUserInteractionEnabled = true
        self.base.addGestureRecognizer(tapGesture)
        self.base.onTapPerform = action
        return self
    }
    
    /// The property of layer.mask
    /// - Parameters:
    ///   - radius: CGFloat
    ///   - byRoundingCorners: UIRectCorner
    /// - Returns: The invoker instance object
    @discardableResult
    func cornerRadius(_ radius: CGFloat, byRoundingCorners: UIRectCorner) -> Self {
        let cornerRadiusLayer = ChainedViewKeys.CornerRadiusLayer(radius: radius, roundingCorners: byRoundingCorners)
        self.base.cornerRadiusLayer = cornerRadiusLayer
        self.updateCornerRadiusLayer()
        return self
    }
    
    /// The property of layer.mask
    /// - Parameters:
    ///   - radius: CGFloat
    ///   - byRoundingCorners: UIRectCorner
    /// - Returns: The invoker instance object
    @discardableResult
    func gradient(_ colors: [UIColor], direction: ChainedViewKeys.GradientLayer.Direction = .horizontal) -> Self {
        let gradientLayer = ChainedViewKeys.GradientLayer.init(colors: colors, direction: direction)
        self.base.gradientLayer = gradientLayer
        self.updateGradientLayer()
        return self
    }
    
    /// The layer’s border. Animatable
    /// - Parameter shape: ViewChainbleEnum.BorderShape
    /// - Returns: The invoke instance object
    @discardableResult
    func border(_ shape: ChainedViewKeys.BorderStyle) -> Self {
        switch shape {
        case .normal(let color, let width):
            self.base.layer.borderColor = color.cgColor
            self.base.layer.borderWidth = width
        case let .lineDash(strokeColor,fillColor, lineWidth, cornerRadii, lineDashPattern):
            let lineDashLayer = ChainedViewKeys.LineDashLayer(strokeColor: strokeColor,
                                         fillColor: fillColor,
                                         name: "CAShapeLayerLineDash",
                                         lineWidth: lineWidth,
                                         lineDashPattern:lineDashPattern,
                                         cornerRadii: cornerRadii)
            self.base.lineDashLayer = lineDashLayer
            self.updateLineDashLayer()
        }
        return self
    }
    
    @discardableResult
    func animation(_ animation: ChainedViewKeys.Animation, completion: ((Bool) -> Void)? = nil) -> Self {
        switch animation {
        case let .easeIn(duration):
            if self.base.isHidden {
                self.base.isHidden = false
            }
            UIView.animate(withDuration: duration, animations: {
                self.base.alpha = 1
            }, completion: completion)
        case let .easeOut(duration):
            if self.base.isHidden {
                self.base.isHidden = false
            }
            UIView.animate(withDuration: duration, animations: {
                self.base.alpha = 0
            }, completion: completion)
        }
        return self
    }
    
    /// Add shadow to view.
    ///
    /// - Parameters:
    ///   - color: shadow color (default is #137992).
    ///   - radius: shadow radius (default is 3).
    ///   - offset: shadow offset (default is .zero).
    ///   - opacity: shadow opacity (default is 0.5).
    @discardableResult
    func shadow(color: UIColor = UIColor(red: 0.07, green: 0.47, blue: 0.57, alpha: 1.0),
                radius: CGFloat = 3,
                offset: CGSize = .zero,
                opacity: Float = 0.5) -> Self {
        self.base.layer.shadowColor = color.cgColor
        self.base.layer.shadowOffset = offset
        self.base.layer.shadowRadius = radius
        self.base.layer.shadowOpacity = opacity
        self.base.layer.masksToBounds = true
        return self
    }
    
    @discardableResult
    func updateLayers() -> Self {
        updateGradientLayer()
        updateCornerRadiusLayer()
        updateLineDashLayer()
        return self
    }
    
    @discardableResult
    func updateGradientLayer() -> Self {
        guard var gradientLayer = self.base.gradientLayer else {
            return self
        }
        self.base.layoutIfNeeded()
        self.base.setNeedsLayout()
        
        if self.base.bounds != .zero {
            gradientLayer.roundedRect = self.base.bounds
            deleteLayer(from: gradientLayer.name)
            self.base.layer.insertSublayer(gradientLayer.makeLayer(), at: 0)
        }
        return self
    }
    
    @discardableResult
    func updateCornerRadiusLayer() -> Self {
        guard var cornerRadiusLayer = self.base.cornerRadiusLayer else {
            return self
        }
        self.base.layoutIfNeeded()
        self.base.setNeedsLayout()
        
        if self.base.bounds != .zero {
            cornerRadiusLayer.roundedRect = self.base.bounds
            self.base.layer.mask = cornerRadiusLayer.makeLayer()
        }
     
        return self
    }
    
    @discardableResult
    func updateLineDashLayer() -> Self {
        guard var lineDashLayer = self.base.lineDashLayer else {
            return self
        }
        self.base.layoutIfNeeded()
        self.base.setNeedsLayout()
        lineDashLayer.pathBounds = self.base.bounds
        deleteLayer(from: lineDashLayer.name)
        self.base.layer.addSublayer(lineDashLayer.makeLayer())
        return self
    }
    
    @discardableResult
    func deleteLayer(from name: String?) -> Self {
        guard let name = name, !name.isEmpty
        else {
            return self
        }
        self.base.layer.sublayers?
            .filter({ $0.name == name})
            .first?
            .removeFromSuperlayer()
        return self
    }
    
    /// Get view's parent view controller
    var parentViewController: UIViewController? {
        weak var parentResponder: UIResponder? = self.base
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    /// Take screenshot of view (if applicable).
    var screenshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.base.layer.frame.size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        self.base.layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

private var kTapCallBlock = "kTapCallBlock"
private var kLineDashLayer = "kLineDashLayer"
private var kCornerRadiusLayer = "kCornerRadiusLayer"
private var kGradientLayer = "kGradientLayer"


extension UIView {
    
    @objc func onTapGestureAction() {
        onTapPerform?()
    }
    
    var onTapPerform: (() -> Void)? {
        get {
            objc_getAssociatedObject(self, &kTapCallBlock) as? () -> Void
        }
        set {
            objc_setAssociatedObject(self, &kTapCallBlock, newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var lineDashLayer: ChainedViewKeys.LineDashLayer? {
        get {
            objc_getAssociatedObject(self, &kLineDashLayer) as? ChainedViewKeys.LineDashLayer
        } set {
            objc_setAssociatedObject(self, &kLineDashLayer, newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var cornerRadiusLayer: ChainedViewKeys.CornerRadiusLayer? {
        get {
            objc_getAssociatedObject(self, &kCornerRadiusLayer) as? ChainedViewKeys.CornerRadiusLayer
        } set {
            objc_setAssociatedObject(self, &kCornerRadiusLayer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var gradientLayer: ChainedViewKeys.GradientLayer? {
        get {
            objc_getAssociatedObject(self, &kGradientLayer) as? ChainedViewKeys.GradientLayer
        } set {
            objc_setAssociatedObject(self, &kGradientLayer, newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public struct ChainedViewKeys {
    
    public enum FrameFamily {
        case left(CGFloat)
        case top(CGFloat)
        case width(CGFloat)
        case height(CGFloat)
        case origin(x: CGFloat, y:CGFloat)
        case size(width: CGFloat, height:CGFloat)
        case frame(CGRect)
    }
    
    public enum BorderStyle {
        case normal(color: UIColor, width: CGFloat = 0.5)
        case lineDash(strokeColor: UIColor,
                      fillColor: UIColor = .clear,
                      lineWidth: CGFloat = 0.5,
                      cornerRadii: CGFloat,
                      lineDashPattern: [NSNumber] = [NSNumber(4.0),NSNumber(3.0)])
    }
    
    public struct LineDashLayer {
        
        var strokeColor: UIColor?
        var fillColor: UIColor?
        var name = ""
        var lineWidth: CGFloat = 0
        var lineDashPattern: [NSNumber] = []
        var pathBounds: CGRect = .zero
        var cornerRadii: CGFloat = 0
        
        public func makeLayer() -> CAShapeLayer  {
            let path = UIBezierPath(roundedRect: self.pathBounds,
                                    byRoundingCorners: .allCorners,
                                    cornerRadii: CGSize(width: cornerRadii, height: cornerRadii))
            let shapeLayer = CAShapeLayer()
            shapeLayer.name = "CAShapeLayerLineDash"
            shapeLayer.strokeColor = strokeColor?.cgColor
            shapeLayer.fillColor = fillColor?.cgColor
            shapeLayer.lineWidth = lineWidth
            shapeLayer.path = path.cgPath
            shapeLayer.lineDashPattern = lineDashPattern
            return shapeLayer
        }
    }
    
    public struct GradientLayer {
        
        public enum Direction {
        case horizontal, vertical
        }
        
        var colors: [UIColor] = []
        var direction: Direction = .horizontal
        var roundedRect: CGRect = .zero
        var name = "GradientLayer"
        
        public func makeLayer() -> CAGradientLayer {
            let gradientLayer = CAGradientLayer()
            gradientLayer.name = name
            gradientLayer.frame = self.roundedRect
            gradientLayer.colors = colors.map { $0.cgColor }
            switch direction {
            case .horizontal:
                gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
                gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            case .vertical:
                break
            }
            return gradientLayer
        }
    }
    
    public struct CornerRadiusLayer {
        var radius: CGFloat = 0
        var roundingCorners: UIRectCorner = .allCorners
        var roundedRect: CGRect = .zero
        public func makeLayer() -> CAShapeLayer {
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(roundedRect: roundedRect,
                                          byRoundingCorners: roundingCorners,
                                          cornerRadii: .init(width: radius, height: radius)).cgPath
            return maskLayer
        }
    }
    
    public enum Animation {
        case easeIn(duration: Double)
        case easeOut(duration: Double)
    }
}
