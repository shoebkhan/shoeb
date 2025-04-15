//
//  TitleView.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 10/10/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class TitleView: UILabel {
    var title = "" {
        didSet {
            text = title
        }
    }
    func setupTitleView(title: String, subTitle: String) {
    
        let titleString = title + "\n" + subTitle
        
        let attrString = NSMutableAttributedString(string: titleString)
        
        let titleRange: NSRange = (titleString as NSString).range(of: title)
        attrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17.0), range: titleRange)
        attrString.addAttribute(.foregroundColor, value: UIColor.white, range: titleRange)
        
        let numberChatsRange: NSRange = (titleString as NSString).range(of: subTitle)
        attrString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13.0), range: numberChatsRange)
        attrString.addAttribute(.foregroundColor, value: UIColor.white.withAlphaComponent(0.6), range: numberChatsRange)
        
        numberOfLines = 2
        attributedText = attrString
        textAlignment = .center
        bounds.size.width = 200.0
    }
    override init(frame: CGRect) {
        super.init(frame: .zero)

        font = .systemFont(ofSize: 17.0, weight: .bold)
        textColor = .white
        textAlignment = .center
        lineBreakMode = .byTruncatingTail
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
