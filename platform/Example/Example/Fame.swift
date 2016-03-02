//
//  UIViewExtension.swift
//  Example
//
//  Created by Alexander Schuch on 20/11/14.
//  Copyright (c) 2014 Alexander Schuch. All rights reserved.
//

import UIKit

extension NSObject {
    @IBInspectable
    var i18n_enabled: Bool {
        get { return false; }
        set { /* do nothing */ }
    }
    
    @IBInspectable
    var i18n_comment: String? {
        get { return nil; }
        set { /* do nothing */ }
    }
    
//    @IBInspectable
//    var fame_Identifier: String? {
//        get { return nil; }
//        set { /* do nothing */ }
//    }
//    
//    @IBInspectable
//    var fame_Description: String? {
//        get { return nil; }
//        set { /* do nothing */ }
//    }
}