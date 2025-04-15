//
//  XibCell.swift
//  EasyGolf
//
//  Created by TienNVan on 7/31/19.
//  Copyright © 2019 Minh Hop. All rights reserved.
//

import UIKit

protocol XibCell {
    static var xibName: String { get }
    static var nib: UINib { get }
}

extension XibCell where Self: UIView {
    static var xibName: String {
        return "\(self)"
    }
    static var nib: UINib {
        return UINib(nibName: self.xibName, bundle: .main)
    }
}

protocol Nibable {
    var contentView: UIView! { get set }
    var nibNamed: String { get }
    
    /// Must call after `super.init(_:CGRect)`
    func commonInit()
    func setupView()
}

extension Nibable where Self: UIView {
    
    var nibNamed: String {
        return String(describing: type(of: self))
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(nibNamed, owner: self)
        
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        setupView()
    }
    
    func setupView() {
        fatalError("override me")
    }
}
