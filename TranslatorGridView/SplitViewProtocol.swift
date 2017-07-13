//
//  SplitViewProtocol.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 07/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Foundation

protocol SplitViewDelegate {

    
    /// Called when user has been select a file
    ///
    /// - Parameter paths: file paths selected
    func didSelectedFile(atPaths paths:[String])

}
