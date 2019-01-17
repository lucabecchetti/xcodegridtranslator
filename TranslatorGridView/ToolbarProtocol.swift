//
//  ToolbarProtocol.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 13/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

protocol ToolbarDelegate {
    
    
    /// User click search
    func search()
    /// User click delete
    func delete()
    /// User tap android
    func android()
    /// User export android
    func export()
    
}
