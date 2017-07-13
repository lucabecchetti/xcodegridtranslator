//
//  GridViewController.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 12/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

class StartWindowController: NSWindowController {
    
    /**
     Load from nib
     */
    class func loadFromNib() -> StartWindowController{
        
        let vc = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "StartWindowController") as! StartWindowController
        return vc
        
    }
    
}
