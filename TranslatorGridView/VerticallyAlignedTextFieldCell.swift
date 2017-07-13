//
//  VerticallyAlignedTextFieldCell.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 11/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

class VerticallyAlignedTextFieldCell: NSTextFieldCell {
    
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        let newRect = NSRect(x: 0, y: (rect.size.height - 22) / 2, width: rect.size.width, height: 22)
        return super.drawingRect(forBounds: newRect)
    }
    
}
