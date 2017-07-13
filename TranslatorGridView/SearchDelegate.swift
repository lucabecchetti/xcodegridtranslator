//
//  AddNewProtocol.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 12/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

protocol SearchDelegate {
    
    
    /// user is looking for a string
    ///
    /// - Parameter string: the string to search
    func searchString(string:String)

}
