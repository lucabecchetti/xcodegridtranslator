//
//  AddNewProtocol.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 12/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

protocol AddNewDelegate {
    
    
    /// called when new item has been added from user
    ///
    /// - Parameter name: name of new item
    func newItemDidAdded(name:String)

}
