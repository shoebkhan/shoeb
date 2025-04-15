//
//  ChatAttachmentOutgoingCell.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatLocationOutgoingCell: ChatAttachmentCell {
    @IBOutlet weak var statusImageView: UIImageView!
    
    func setupStatusImage(_ image: UIImage) {
        statusImageView.image = image
    }
}
