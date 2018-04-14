//
//  UIScrollView.swift
//  Wardah
//
//  Created by Nour  on 3/11/18.
//  Copyright © 2018 AlphaApps. All rights reserved.
//

import Foundation
import UIKit


extension UIScrollView {
    
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        setContentOffset(bottomOffset, animated: true)
    }
    
    func scrollToTop() {
        let TopOffset = CGPoint(x: 0, y: 0)
        setContentOffset(TopOffset, animated: true)
    }
}
