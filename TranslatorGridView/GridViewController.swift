//
//  GridViewController.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 12/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

class GridViewController: NSWindowController {
    
    @IBOutlet weak var toolBar: NSToolbar!
    @IBOutlet weak var searchItem: NSToolbarItem!
    
    var delegate:ToolbarDelegate?
    
    
    /**
     Load from nib
    */
    class func loadFromNib() -> GridViewController{
        
        let vc = NSStoryboard(name: "Grid", bundle: nil).instantiateController(withIdentifier: "GridViewController") as! GridViewController
        return vc
        
    }
    
    @IBAction func search(_ sender: Any) {
        
        delegate?.search()
        
    }
    
    override func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        return item.isEnabled
    }
    
    
}
