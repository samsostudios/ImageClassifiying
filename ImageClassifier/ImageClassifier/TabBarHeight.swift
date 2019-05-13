//
//  TabBarHeight.swift
//  ImageClassifier
//
//  Created by Sam Henry on 5/1/19.
//  Copyright © 2019 Practice. All rights reserved.
//

import UIKit

class CustomTabBar : UITabBar {
    @IBInspectable var height: CGFloat = 0.0
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        if height > 0.0 {
            sizeThatFits.height = height
        }
        return sizeThatFits
    }
}

