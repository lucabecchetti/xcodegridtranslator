//
//  StartView.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 11/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

class StartViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate{

    @IBOutlet weak var historyTableView: NSTableView!
    var pathToOpen:String?
    var pathHistory:[String] = [String]()
    var gridViewController:GridViewController?
    
    override func viewDidLoad() {
        self.title = "xCodeTranslator"
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
    }
    
    override func viewDidAppear() {
        // any additional code
        view.window!.styleMask.remove(NSWindowStyleMask.resizable)
        
        if let history_dt = appCore.defaults.object(forKey: "history") as? [String]{
            pathHistory = history_dt
            historyTableView.reloadData()
        }
        
        self.view.window?.center()
    }
    
    @IBAction func browseFile(_ sender: Any) {
        
        appCore.openDialog { (path) in
            if path != nil{
                pathToOpen = path
                
                openGrid(path: path!)
                
            }
        }
        
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 35
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return pathHistory.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.make(withIdentifier: "name", owner: self) as! NSTableCellView
        let field = pathHistory[row]
        cell.textField!.stringValue = " " + field
        return cell
    }

    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            
            // we create an [Int] array from the index set
            let selected = myTable.selectedRowIndexes.map { Int($0) }
            
            if let id = selected.first{
                let path = pathHistory[id]
                pathToOpen = path
                openGrid(path: path)
                historyTableView!.deselectAll(self)
            }
            
        }
    }
    
    func openGrid(path:String){
        if gridViewController == nil{
            // initialize new view controller and cast it as your view controller
            gridViewController = GridViewController.loadFromNib()
        }
        let splitViewController = gridViewController!.window!.contentViewController as! NSSplitViewController
        let list:ListsController = splitViewController.childViewControllers[0] as! ListsController
        let right:ViewController = splitViewController.childViewControllers[1] as! ViewController
        list.delegate = right
        list.pathToOpen = pathToOpen
        right.delegate = list
        appCore.currentEditor = right
        
        //Salvo nello user default
        
        if var saved_dt = appCore.defaults.object(forKey: "history") as? [String]{
            let id = saved_dt.index(of: pathToOpen!)
            if id == nil || id! < 0{
                saved_dt.append(pathToOpen!)
            }
            appCore.defaults.set(saved_dt, forKey: "history")
            appCore.defaults.synchronize()
        }else{
            appCore.defaults.set([pathToOpen!], forKey: "history")
            appCore.defaults.synchronize()
        }
        
        gridViewController?.window?.center()
        gridViewController?.showWindow(self)
        self.view.window?.close()
    }

    
}
