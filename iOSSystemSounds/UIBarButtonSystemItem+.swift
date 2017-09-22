//
//  UIBarButtonSystemItem+.swift
//  iOSSystemSounds
//
//  Created by Wayne Yeh on 2017/9/22.
//  Copyright © 2017年 Wayne Yeh. All rights reserved.
//

import UIKit

extension UIBarButtonSystemItem {
    func image() -> UIImage? {
        let tempItem = UIBarButtonItem(barButtonSystemItem: self,
                                       target: nil,
                                       action: nil)
        
        // add to toolbar and render it
        let bar = UIToolbar()
        bar.setItems([tempItem],
                     animated: false)
        bar.snapshotView(afterScreenUpdates: true)
        
        // got image from real uibutton
        let itemView = tempItem.value(forKey: "view") as! UIView
        for view in itemView.subviews {
            if let button = view as? UIButton,
                let image = button.imageView?.image {
                return image.withRenderingMode(.alwaysTemplate)
            }
        }
        
        return nil
    }
}
