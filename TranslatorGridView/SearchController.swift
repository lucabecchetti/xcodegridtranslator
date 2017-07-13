//
//  AddNewController.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 12/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

class SearchController: NSViewController{
    
    @IBOutlet weak var nameVar: NSTextField!
    var pathToOpen:String?
    var delegate:SearchDelegate?
    var initialSearchString = ""
    
    override func viewDidLoad() {
        
        self.title = NSLocalizedString("SEARCH", comment: "")
        nameVar.stringValue = initialSearchString
        
    }
    
    @IBAction func search(_ sender: Any) {
        
        delegate?.searchString(string: nameVar.stringValue)
        self.dismiss(self)
        
    }
    
    
    @IBAction func close(_ sender: Any) {
        
        self.dismiss(self)
        
    }
    
    
}
