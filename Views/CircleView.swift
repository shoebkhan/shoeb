//
//  CircleView.swift
//  EasyGolf
//
//  Created by TienNVan on 9/3/19.
//  Copyright © 2019 Minh Hop. All rights reserved.
//

import UIKit

class CircleView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = min(frame.width, frame.height)/2
        layer.cornerRadius = radius
    }

}

class CircleButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = min(frame.width, frame.height)/2
        layer.cornerRadius = radius
    }
}

class CircleImageViewPost: UIImageView {

    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius = min(frame.width, frame.height)/2
        layer.cornerRadius = radius
    }
    
    private func commonInit() {
        contentMode = .scaleAspectFill
        clipsToBounds = true
    }
}

class BorderImageView: CircleView {
    
    var imageView: CircleImageViewPost = {
        let imageView = CircleImageViewPost()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var borderColor: UIColor? {
        get {
            return self.backgroundColor
        } set {
            self.backgroundColor = newValue
        }
    }
    
    var borderWidth: CGFloat = 2 {
        didSet {
            imageViewAnchored.top?.constant = self.borderWidth
            imageViewAnchored.leading?.constant = self.borderWidth
            imageViewAnchored.trailing?.constant = -self.borderWidth
            imageViewAnchored.bottom?.constant = -self.borderWidth
        }
    }
    
    var image: UIImage? {
        get {
            return imageView.image
        } set {
            self.imageView.image = newValue
        }
    }
    
    var imagePlaceholder: String = "ic_avt_default"
    
    var imagePath: String? {
        didSet {
            guard let path = self.imagePath else {
                return
            }

            //imageView.loadImageWithUrl(urlString: path, cache: true, placeHolder: imagePlaceholder)
            imageView.sd_setImage(with: URL(string:( url.fileName + path)), placeholderImage: UIImage(named: imagePlaceholder), options: [], context: nil)
        }
    }
    
    private var imageViewAnchored: AnchoredConstraints!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupView()
        setupSubviews()
        setupConstraints()
    }
    
    private func setupView() {
        backgroundColor = borderColor
    }
    
    private func setupSubviews() {
        addSubview(imageView)
    }
    
    private func setupConstraints() {
        self.imageViewAnchored = imageView.fillSuperview(padding: .init(top: borderWidth, left: borderWidth, bottom: borderWidth, right: borderWidth))
    }
    
}
public struct AnchoredConstraints {
    public var top, leading, bottom, trailing, width, height: NSLayoutConstraint?
}
