//
//  SplitViewProtocol.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 07/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Foundation

protocol SplitViewDelegate {
    func didSelectedFile(atPaths paths:[String])
}
