//
//  DFTableView.swift
//  EasyGolf
//
//  Created by TienNVan on 21/12/2020.
//  Copyright © 2020 Minh Hop. All rights reserved.
//

import Foundation
import UIKit

class DFTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            contentInset.bottom = max(keyboardHeight, 56)
            horizontalScrollIndicatorInsets.bottom = max(keyboardHeight, 56)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            contentInset.bottom = max(keyboardHeight, 56)
            horizontalScrollIndicatorInsets.bottom = max(keyboardHeight, 56)
        }
    }
}
