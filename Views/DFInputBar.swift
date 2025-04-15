//
//  DFInputBar.swift
//  EasyGolf
//
//  Created by TienNVan on 17/12/2020.
//  Copyright © 2020 Minh Hop. All rights reserved.
//

import UIKit

class DFInputBar: UIView {
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if let window = self.window {
            self.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: window.safeAreaLayoutGuide.bottomAnchor, multiplier: 1).isActive = true
        }
    }
}
