//
//  ViewController.swift
//  ImageClassifier
//
//  Created by Robert Renecker on 2019/04/29.
//  Copyright © 2019 Practice. All rights reserved.
//

import UIKit
import CoreML
import YPImagePicker
import Hero

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
    }
    
}

