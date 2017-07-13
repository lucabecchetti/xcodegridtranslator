//
//  AppCore.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 11/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

class AppCore: NSObject {
    
    var currentEditor:ViewController?
    let defaults = UserDefaults.standard
    
    func openDialog(completition: (_ path:String?) -> Void){
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose Folder";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseFiles          = false;
        
        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                completition(path)
            }
        } else {
            // User clicked on "Cancel"
            completition(nil)
        }
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    static func positionWindowAtCenter(sender: NSWindow?){
        if let window = sender {
            let xPos = NSWidth((window.screen?.frame)!)/2 - NSWidth(window.frame)/2
            let yPos = NSHeight((window.screen?.frame)!)/2 - NSHeight(window.frame)/2
            let frame = NSMakeRect(xPos, yPos, NSWidth(window.frame), NSHeight(window.frame))
            window.setFrame(frame, display: true)
        }
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = NSAlertStyle.warning
        alert.addButton(withTitle: "OK")
        return alert.runModal() == NSAlertFirstButtonReturn
    }
    
}

let appCore = AppCore()


