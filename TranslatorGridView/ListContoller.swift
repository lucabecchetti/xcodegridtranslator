//
//  ViewController.swift
//  TranslatorGridView
//
//  Created by Luca Becchetti on 07/07/17.
//  Copyright © 2017 Luca Becchetti. All rights reserved.
//

import Cocoa

class ListsController: NSViewController,NSTableViewDataSource,NSTableViewDelegate,EditingDelegate {

    @IBOutlet weak var tableView: NSTableView!
    
    var dict:[String:[String]]? = [String:[String]] ()
    var delegate:SplitViewDelegate?
    var pathToOpen:String?
    var currentEditPath:String = ""
    let fileWatcher = SwiftFSWatcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableColumns[0].headerCell.title = NSLocalizedString("FILES", comment: "FILES DI TRADUZIONE")
        //queue = SKQueue(delegate: self)
    }

    override func viewWillAppear() {
        
        self.tableView.backgroundColor = NSColor(red:0.93, green:0.93, blue:0.93, alpha:1.00)
        
        if pathToOpen != nil && pathToOpen! != ""{
            dict = extractAllFile(atPath: pathToOpen!, withExtension: "strings")
            appCore.dict = dict
            tableView.reloadData()
        }
    }
    
    func userEditDidError(path: String) {
        
    }
    
    func userDidEdit(path: String) {
        
    }
    
    func userIsEditing(path: String) {
        print("Editing: \(path)")
        currentEditPath = path.replacingOccurrences(of: "file://", with: "")

    }

    /**
     Costruisco array dei files per le traduzioni
    */
    func extractAllFile(atPath path: String, withExtension fileExtension:String) -> [String:[String]] {
        let pathURL = NSURL(fileURLWithPath: path, isDirectory: true)
        var allFiles: [String:[String]] = [String:[String]]()
        let fileManager = FileManager.default
        let pathString = path.replacingOccurrences(of: "file:", with: "")
        if let enumerator = fileManager.enumerator(atPath: pathString) {
            var pathToMonitor:[String] = [String]()
            
            for file in enumerator {
                
                if "\(file)".hasPrefix("Pods") || "\(file)".contains(".bundle") || "\(file)".hasPrefix("."){
                    continue
                }
                let path = path.appending("/\(file)")
                
                if path.hasSuffix(".swift"){
                   // queue?.addPath(path)
                    pathToMonitor.append(path)
                }

                if #available(iOS 9.0, *) {
                    
                    if let path = NSURL(fileURLWithPath: file as! String, relativeTo: pathURL as URL).path, path.hasSuffix(".\(fileExtension)"){
                        let dirs = (path as NSString).components(separatedBy: "/")
                        let fileNameArray = (path as NSString).lastPathComponent.components(separatedBy: ".")
                        if let _ = allFiles[dirs[dirs.count-3]+"/"+fileNameArray.first!]{
                            allFiles[dirs[dirs.count-3]+"/"+fileNameArray.first!]!.append(path)
                        }else{
                            allFiles[dirs[dirs.count-3]+"/"+fileNameArray.first!] = [path]
                        }
                    }
                } else {
                    // Fallback on earlier versions
                    print("Not available, #available iOS 9.0 & above")
                }
            }
            
            // setup and listen second watcher events on files only
            fileWatcher.watchingPaths = pathToMonitor
            fileWatcher.watch { changeEvents in
                for ev in changeEvents {
                
                    _ = appCore.findString(inPath: ev.eventPath)
                
                }
            }
            
        }
        return allFiles
    }
    
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 35
    }

    
    func numberOfRows(in tableView: NSTableView) -> Int {

        return dict!.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cell = tableView.make(withIdentifier: "name", owner: self) as! ListCell
        let field = Array(dict!)[row]
        cell.textField!.backgroundColor = .red
        cell.textField!.stringValue = "\(field.key.components(separatedBy: "/").last!) (\(field.value.count))"
        cell.subTitle!.stringValue = "\(field.key.components(separatedBy: "/").first!)"
        return cell
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let myCustomView = MyRowView()
        return myCustomView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let myTable = notification.object as? NSTableView {
            
            // we create an [Int] array from the index set
            let selected = myTable.selectedRowIndexes.map { Int($0) }
            print(selected)
            if let id = selected.first{
                let field = Array(dict!)[id]
                delegate?.didSelectedFile(atPaths: field.value)
            }
            
        }
    }
    
    class MyRowView: NSTableRowView {
        
        override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)
            
            if isSelected == true {
                NSColor(red:0.45, green:0.72, blue:0.96, alpha:1.00).set()
                NSRectFill(dirtyRect)
            }
        }
    }

    
}

