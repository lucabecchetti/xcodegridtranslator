//
//  EditingProtocol.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 12/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

protocol EditingDelegate {
    
    func userIsEditing(path:String)
    func userDidEdit(path:String)
    func userEditDidError(path:String)
    
}
