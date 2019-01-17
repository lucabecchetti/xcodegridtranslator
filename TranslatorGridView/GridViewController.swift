///Users/frind/Desktop/TranslatorGridView/TranslatorGridView/GridViewController.swift
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
    @IBOutlet weak var trashItem: NSToolbarItem!
    @IBOutlet weak var androidIcon: NSToolbarItem!
    @IBOutlet weak var exportIcon: NSToolbarItem!
    
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
    
    @IBAction func trash(_ sender: Any) {
        
        delegate?.delete()
        
    }
    
    @IBAction func loadStrings(_ sender: Any) {
        
        delegate?.android()
        
    }
    
    @IBAction func export(_ sender: Any) {
        
        delegate?.export()
        
    }
    
    
    override func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        return item.isEnabled
    }

    
}
