//
//  LoadingButton.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

struct LoadingButtonColorConstant {
    static let blueColor = #colorLiteral(red: 0.2235294118, green: 0.4713830948, blue: 0.9869660735, alpha: 1)
    static let greenColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
    static let grayColor = #colorLiteral(red: 0.6628920436, green: 0.7223827243, blue: 0.8180354238, alpha: 1)
}

class LoadingButton: UIButton {
    
    //MARK: - Properties
    lazy private var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        return shapeLayer
    }()
    
    lazy private var activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .gray)
        activity.color = .white
        activity.hidesWhenStopped = true
        return activity
    }()
    
    var isAnimating: Bool {
        return activity.isAnimating
    }
    
    private var currentText = "Login".localized
    
    override var isEnabled: Bool{
        didSet {
            if isEnabled == true {
                shapeLayer.fillColor = LoadingButtonColorConstant.blueColor.cgColor
                addShadowToButton(cornerRadius: 4)
            } else {
                shapeLayer.fillColor = LoadingButtonColorConstant.grayColor.cgColor
                removeShadowFromButton()
            }
        }
    }
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isEnabled = false
        setTitle(currentText, for: .normal)
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 5.0).cgPath
        layer.addSublayer(shapeLayer)
        activity.stopAnimating()
    }
    
    // MARK: - Public Methods
    func showLoading() {
        
        guard activity.isAnimating == false else {
            return
        }
        
        removeShadowFromButton()
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = UIBezierPath(roundedRect: bounds, cornerRadius: 5.0).cgPath
        animation.repeatCount = 1
        animation.duration = 0.15
        let cornerRadius = min(frame.size.height, frame.size.height)
        let roundedRect = CGRect(x: frame.size.width / 2.0 - cornerRadius / 2.0,
                                 y: 0.0, width: cornerRadius, height: cornerRadius)
        let path = (UIBezierPath(roundedRect: roundedRect,
                                 cornerRadius: cornerRadius)).cgPath
        animation.toValue = path
        shapeLayer.add(animation, forKey: "shapeAnimation")
        shapeLayer.path = path
        
        isUserInteractionEnabled = false
        activity.isHidden = false
        activity.startAnimating()
        activity.center = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        addSubview(activity)
        
        currentText = currentTitle ?? "Title"
        setTitle("", for: .normal)
        
        let fromColor = LoadingButtonColorConstant.blueColor
        let toColor = LoadingButtonColorConstant.greenColor
        
        let colorAnimation = CABasicAnimation(keyPath: "fillColor")
        colorAnimation.fromValue = fromColor.cgColor
        colorAnimation.toValue = toColor.cgColor
        colorAnimation.repeatCount = Float(NSIntegerMax)
        colorAnimation.duration = 1.0
        colorAnimation.autoreverses = true
        
        shapeLayer.add(colorAnimation, forKey: "color")
    }
    
    func hideLoading() {
        guard activity.isAnimating == true else {
            return
        }
        activity.stopAnimating()
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 5.0).cgPath
        shapeLayer.fillColor = LoadingButtonColorConstant.blueColor.cgColor
        
        isUserInteractionEnabled = true
        shapeLayer.removeAllAnimations()
        activity.removeFromSuperview()
        
        setTitle(currentText, for: .normal)
        currentText = ""
    }
}


class LoadMoreActivityIndicator {

    private let spacingFromLastCell: CGFloat
    private let spacingFromLastCellWhenLoadMoreActionStart: CGFloat
    private weak var activityIndicatorView: UIActivityIndicatorView?
    private weak var scrollView: UIScrollView?

    private var defaultY: CGFloat {
        guard let height = scrollView?.contentSize.height else { return 0.0 }
        return height + spacingFromLastCell
    }

    deinit { activityIndicatorView?.removeFromSuperview() }

    init (scrollView: UIScrollView, spacingFromLastCell: CGFloat, spacingFromLastCellWhenLoadMoreActionStart: CGFloat) {
        self.scrollView = scrollView
        self.spacingFromLastCell = spacingFromLastCell
        self.spacingFromLastCellWhenLoadMoreActionStart = spacingFromLastCellWhenLoadMoreActionStart
        let size:CGFloat = 40
        let frame = CGRect(x: (scrollView.frame.width-size)/2, y: scrollView.contentSize.height + spacingFromLastCell, width: size, height: size)
        let activityIndicatorView = UIActivityIndicatorView(frame: frame)
        if #available(iOS 13.0, *)
        {
            activityIndicatorView.color = .label
        }
        else
        {
            activityIndicatorView.color = .black
        }
        activityIndicatorView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        activityIndicatorView.hidesWhenStopped = true
        scrollView.addSubview(activityIndicatorView)
        self.activityIndicatorView = activityIndicatorView
    }

    private var isHidden: Bool {
        guard let scrollView = scrollView else { return true }
        return scrollView.contentSize.height < scrollView.frame.size.height
    }

    func start(closure: (() -> Void)?) {
        guard let scrollView = scrollView, let activityIndicatorView = activityIndicatorView else { return }
        let offsetY = scrollView.contentOffset.y
        activityIndicatorView.isHidden = isHidden
        if !isHidden && offsetY >= 0 {
            let contentDelta = scrollView.contentSize.height - scrollView.frame.size.height
            let offsetDelta = offsetY - contentDelta

            let newY = defaultY-offsetDelta
            if newY < scrollView.frame.height {
                activityIndicatorView.frame.origin.y = newY
            } else {
                if activityIndicatorView.frame.origin.y != defaultY {
                    activityIndicatorView.frame.origin.y = defaultY
                }
            }

            if !activityIndicatorView.isAnimating {
                if offsetY > contentDelta && offsetDelta >= spacingFromLastCellWhenLoadMoreActionStart && !activityIndicatorView.isAnimating {
                    activityIndicatorView.startAnimating()
                    closure?()
                }
            }

            if scrollView.isDecelerating {
                if activityIndicatorView.isAnimating && scrollView.contentInset.bottom == 0 {
                    UIView.animate(withDuration: 0.3) { [weak self] in
                        if let bottom = self?.spacingFromLastCellWhenLoadMoreActionStart {
                            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
                        }
                    }
                }
            }
        }
    }

    func stop(completion: (() -> Void)? = nil) {
        guard let scrollView = scrollView , let activityIndicatorView = activityIndicatorView else { return }
        let contentDelta = scrollView.contentSize.height - scrollView.frame.size.height
        let offsetDelta = scrollView.contentOffset.y - contentDelta
        if offsetDelta >= 0 {
            UIView.animate(withDuration: 0.3, animations: {
                scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }) { _ in completion?() }
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            completion?()
        }
        activityIndicatorView.stopAnimating()
    }
}
