//
//  UIViewEx.swift

import UIKit

public enum UIButtonBorderSide {
    case top, bottom, left, right
}
final class ClickListener: UITapGestureRecognizer {
    private var action: () -> Void

    init(_ action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }

    @objc private func execute() {
        action()
    }
}
extension UIView {
    func addTapGesture(_ action: @escaping () -> Void) {
        self.isUserInteractionEnabled = true
        let click = ClickListener(action)
        self.addGestureRecognizer(click)
    }
}
// MARK: UIView -
extension UIView {
    func addRoundedCorners() {
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = self.frame.size.width/2
        self.layer.masksToBounds = true
    }
    func addRoundedCornersWithColor(borderColor: UIColor) {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = self.frame.size.width/2
        self.layer.masksToBounds = true
    }
    func addRoundedCornersWithGrayBorder() {
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = self.frame.size.width/2
        self.layer.masksToBounds = true
    }
    func addShadowToView() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
    }
    func addShadowToTableViewCell() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.20).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
    }
    func customizedUIViewWithRedBorder() {
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.masksToBounds = true
    }
    func customizedUIViewWithNoBGColor() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
    }
    func customizedViewWithRoundedCorners(borderColor: UIColor) {
        self.backgroundColor = UIColor.clear
        self.layer.borderWidth = 1.0
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
    }
    func customizedViewWithNoBGColor(borderColor: UIColor) {
        self.layer.borderWidth = 2.0
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
    }
    func customziedRoundCorner(radius: CGFloat) {
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    func customziedRoundCornerWithBorder(radius: CGFloat,
                                         borderColor: UIColor) {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    func customziedRoundCornerWithBorderWidth(radius: CGFloat,
                                              borderColor: UIColor,
                                              borderWidth: CGFloat) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius,
                                                        height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
    public func addBorder(side: UIButtonBorderSide,
                          color: UIColor,
                          width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        switch side {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: width)
        case .bottom:
            border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        case .right:
            border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        }
        self.layer.addSublayer(border)
    }
}

extension StringProtocol where Self: RangeReplaceableCollection {
    var removingAllWhitespaces: Self {
        filter { !$0.isWhitespace }
    }
    mutating func removeAllWhitespaces() {
        removeAll(where: \.isWhitespace)
    }
}

extension UIView {
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }

    fileprivate typealias Action = (() -> Void)?

    fileprivate var tapGestureRecognizerAction: Action? {
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self,
                                         &AssociatedObjectKeys.tapGestureRecognizer,
                                         newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self,
                                                                              &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }

    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
}

extension UIView {
    func rotate(degrees: CGFloat) {
        rotate(radians: CGFloat.pi * degrees / 180.0)
    }
    func rotate(radians: CGFloat) {
        self.transform = CGAffineTransform(rotationAngle: radians)
    }
    func setGradientBackground(colorTop: UIColor,
                               colorBottom: UIColor) {
        let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            gradientLayer.locations = [0, 1]
            gradientLayer.frame = bounds

        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
