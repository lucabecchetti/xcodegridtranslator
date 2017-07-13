//
//  AppDelegate.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 07/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    /// Pointer to main window controller
    var mainWindow:StartWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        //Center the window
        NSApplication.shared().mainWindow?.center()
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    /// Called when user click openFile
    ///
    /// - Parameter sender:
    @IBAction func openFile(_ sender: Any) {
        
    }

    
    /// Called when user click addNew button
    ///
    /// - Parameter sender:
    @IBAction func addNew(_ sender: Any) {
        if appCore.currentEditor != nil{
            appCore.currentEditor?.addNew()
        }else{
            if mainWindow == nil{
                mainWindow = StartWindowController.loadFromNib()
            }
            mainWindow?.showWindow(self)
            mainWindow?.window?.center()
        }
    }
}

