//
//  XUILabel.swift
//  Wardah
//
//  Created by Nour  on 12/22/17.
//  Copyright © 2017 AlphaApps. All rights reserved.
//


import UIKit

class XUIButton:UIButton{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
            self.titleLabel?.font = AppFonts.normal
            let currentTitle = self.currentTitle
            self.setTitle(currentTitle?.localized, for: .normal)
        
        if self.tag == -1 {
            self.makeRounded()
//            self.backgroundColor = AppColors.primary
//            self.setTitleColor(.white, for: .normal)
        }
        
        self.perform(#selector(setImageWithRTL), with: nil, afterDelay: 0.3)
    }
    
    @objc func setImageWithRTL(){
        self.imageView?.image = self.imageView?.image?.imageFlippedForRightToLeftLayoutDirection()
        
        
    }
    
}
