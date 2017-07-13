//
//  AddNewController.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 12/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

class AddNewController: NSViewController{
    
    @IBOutlet weak var nameVar: NSTextField!
    var pathToOpen:String?
    var delegate:AddNewDelegate?
    
    override func viewDidLoad() {
        self.title = "Aggiungi"
    }
    
    @IBAction func save(_ sender: Any) {
        
        delegate?.newItemDidAdded(name: nameVar.stringValue)
        self.dismiss(self)
        
    }
    
    
    @IBAction func close(_ sender: Any) {
        
        self.dismiss(self)
        
    }

    
}
