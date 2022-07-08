//
//  UIButton+.swift
//  iOSSystemSounds
//
//  Created by Wayne Yeh on 2017/9/25.
//  Copyright © 2017年 Wayne Yeh. All rights reserved.
//

import UIKit

extension UIButton.ButtonType {
    func image() -> UIImage? {
        let infoButton = UIButton(type: self)
        return infoButton.currentImage
    }
}
