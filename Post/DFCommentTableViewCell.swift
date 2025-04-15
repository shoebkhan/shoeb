//
//  DFCommentTableViewCell.swift
//  EasyGolf
//
//  Created by TienNVan on 17/12/2020.
//  Copyright © 2020 Minh Hop. All rights reserved.
//

import UIKit

class DFCommentTableViewCell: UITableViewCell, XibCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var link_image: UIImageView!
    @IBOutlet weak var link_title: UILabel!
    @IBOutlet weak var link_desc: UILabel!
    @IBOutlet weak var backVw: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var linkPreviewHeight: NSLayoutConstraint!
    //    @IBOutlet weak var replyLabel: UILabel!
    


    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code


        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        
//        avatarView.rx.tapGesture().when(.recognized).subscribe({ [weak self](_) in
//            guard let strongSelf = self else {
//                return
//            }
//            strongSelf.sendAction(strongSelf, .avatar)
//        }).disposed(by: stepBag)
        
//        nameLabel.rx.tapGesture().when(.recognized).subscribe { [weak self](_) in
//            guard let strongSelf = self else {
//                return
//            }
//            strongSelf.sendAction(strongSelf, .username)
//        }.disposed(by: stepBag)
        
//        likeLabel.text = "Like"
        configuareFonts()
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleContentSizeCategoryDidChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    @objc func handleContentSizeCategoryDidChange() {
        configuareFonts()
    }
    
    func configuareFonts() {
        let isBold = UIAccessibility.isBoldTextEnabled
        let fontMetrics = UIFontMetrics(forTextStyle: .footnote)
        nameLabel.font = fontMetrics.scaledFont(for: UIFont(name: "HelveticaNeue-bold", size: 14.0)!)
        commentLabel.font = fontMetrics.scaledFont(for: UIFont(name: "HelveticaNeue", size: 14.0)!)
        timeLabel.font = fontMetrics.scaledFont(for: UIFont(name: "HelveticaNeue", size: 11.0)!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarView.layer.cornerRadius = avatarView.frame.width/2
    }
    

}
